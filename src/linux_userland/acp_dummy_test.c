#include <stdio.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

// AX_CACHE value
#define AX_CACHE 0xF
// AX_USER value
#define AX_USER  0x2
// from where in the DDR should data be read by the AXI-Master
#define SOURCE_ADDRESS 0x21000000UL
// to which location in the DDR should the AXI-Master write
#define TARGET_ADDRESS 0x28000000UL
// to whcih and from which address should the AXI-Master write in the BRAM
#define BRAM_ADDRESS 1024
// how many consecutive bursts should be executed
#define NUM_BURSTS 3
// how many 128 Bit values should be transmitted in each burst
#define BURST_LENGTH 4

#define SLV_AXI_BASE_ADDR 0x80000000UL

#define SLV_REG0_OFFSET  (0*4)
#define SLV_REG1_OFFSET  (1*4)
#define SLV_REG2_OFFSET  (2*4)
#define SLV_REG3_OFFSET  (3*4)
#define SLV_REG4_OFFSET  (4*4)
#define SLV_REG5_OFFSET  (5*4)
#define SLV_REG6_OFFSET  (6*4)
#define SLV_REG7_OFFSET  (7*4)
#define SLV_REG8_OFFSET  (8*4)
#define SLV_REG9_OFFSET  (9*4)
#define SLV_REG10_OFFSET (10*4)
#define SLV_REG11_OFFSET (11*4)
#define SLV_REG12_OFFSET (12*4)
#define SLV_REG13_OFFSET (13*4)
#define SLV_REG14_OFFSET (14*4)
#define SLV_REG15_OFFSET (15*4)
#define SLV_REG16_OFFSET (16*4)
#define SLV_REG17_OFFSET (17*4)
#define SLV_REG18_OFFSET (18*4)
#define SLV_REG19_OFFSET (19*4)
#define SLV_REG20_OFFSET (20*4)
#define SLV_REG21_OFFSET (21*4)
#define SLV_REG22_OFFSET (22*4)
#define SLV_REG23_OFFSET (23*4)
#define SLV_REG24_OFFSET (24*4)
#define SLV_REG25_OFFSET (25*4)
#define SLV_REG26_OFFSET (26*4)
#define SLV_REG27_OFFSET (27*4)
#define SLV_REG28_OFFSET (28*4)
#define SLV_REG29_OFFSET (29*4)
#define SLV_REG30_OFFSET (30*4)
#define SLV_REG31_OFFSET (31*4)

#define SLV_MAP_SIZE 128UL // = 32*4
#define SLV_MAP_MASK (SLV_MAP_SIZE - 1)

#define DATA_SOURCE_BASE_ADDR SOURCE_ADDRESS
#define DATA_SOURCE_MAP_SIZE 4096UL // = 4kB (upper +0x1000)
#define DATA_SOURCE_MAP_MASK (DATA_SOURCE_MAP_SIZE - 1)

#define DATA_TARGET_BASE_ADDR TARGET_ADDRESS
#define DATA_TARGET_MAP_SIZE 4096L // = 4kB  (upper +0x1000)
#define DATA_TARGET_MAP_MASK (DATA_TARGET_MAP_SIZE - 1)

static int memfd;

static void * slv_mapped_base, *slv_mapped_dev_base;
static off_t slv_dev_base;

static void * data_source_mapped_base, *data_source_mapped_dev_base;
static off_t data_source_dev_base;

static void * data_target_mapped_base, *data_target_mapped_dev_base;
static off_t data_target_dev_base;


static void write_to_slv_reg(uint32_t reg_offset, uint32_t value) {
    *((volatile uint32_t *) (slv_mapped_dev_base + reg_offset)) = value;
}

static uint32_t read_from_slv_reg(uint32_t reg_offset) {
    return *((volatile uint32_t *) (slv_mapped_dev_base + reg_offset));
}


static void write_uint64_t_to_data_source(uint32_t offset, uint64_t value) {
    *((volatile uint64_t *) (data_source_mapped_dev_base  + offset)) = value;
}

static uint64_t read_uint64_t_from_data_source(uint64_t offset) {
    return *((volatile uint64_t *) (data_source_mapped_dev_base + offset));
}


static void write_uint64_t_to_data_target(uint32_t offset, uint64_t value) {
    *((volatile uint64_t *) (data_target_mapped_dev_base  + offset)) = value;
}

static uint64_t read_uint64_t_from_data_target(uint64_t offset) {
    return *((volatile uint64_t *) (data_target_mapped_dev_base + offset));
}


void initSourceMemory(uint32_t start_offset, uint32_t length) {
	int i;
	for(i = 0; i < length; i++) {
		write_uint64_t_to_data_source(start_offset + i*sizeof(uint64_t), (uint64_t) (i*2+1) << 32 | (uint64_t) (i*2));
	}
}

void printSourceMemory(uint32_t start_offset, uint32_t length) {
	int i;

    printf("DDR\n");
	for(i = 0; i < length; i++) {
        printf("%08x : 0x%016lx\n\r", (uint32_t) (SOURCE_ADDRESS + start_offset + i*sizeof(uint64_t)), read_uint64_t_from_data_source(start_offset + i*sizeof(uint64_t)));	
	}
}

void printTargetMemory(uint32_t start_offset, uint32_t length) {
	int i;

    printf("DDR\n");
	for(i = 0; i < length; i++) {
        printf("%08x : 0x%016lx\n\r", (uint32_t) (TARGET_ADDRESS + start_offset + i*sizeof(uint64_t)), read_uint64_t_from_data_target(start_offset + i*sizeof(uint64_t)));	
	}
}



int main() {

    printf("START\n");

    int i;

    slv_dev_base = SLV_AXI_BASE_ADDR;
    data_source_dev_base = DATA_SOURCE_BASE_ADDR;
    data_target_dev_base = DATA_TARGET_BASE_ADDR;

	// setup

	// open /dev/mem
    memfd = open("/dev/mem", O_RDWR | O_SYNC);
    if (memfd == -1) {
        printf("Can't open /dev/mem.\n");
        return 1;
    }

	// get AXI slave memory map
    // Map one page of memory into user space such that the device is in that page, but it may not
    // be at the start of the page.
    slv_mapped_base = mmap(0, SLV_MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, memfd, slv_dev_base & ~SLV_MAP_MASK);
        if (slv_mapped_base == (void *) -1) {
        printf("Can't map the AXI-slave to user space.\n");
        return 1;
    }

    //printf("AXI slave memory mapped at address %p.\n", slv_mapped_base);

    // get the address of the device in user space which will be an offset from the base
    // that was mapped as memory is mapped at the start of a page
    slv_mapped_dev_base = slv_mapped_base + (slv_dev_base & SLV_MAP_MASK);


	// get data memory map
    data_source_mapped_base = mmap(0, DATA_SOURCE_MAP_SIZE, PROT_READ | PROT_WRITE, MAP_SHARED, memfd, data_source_dev_base & ~DATA_SOURCE_MAP_MASK);
        if (data_source_mapped_base == (void *) -1) {
        printf("Can't map the data source to user space.\n");
        return 1;
    }

    //printf("Data source mapped at address %p.\n", data_source_mapped_base);

    // get the address of the device in user space which will be an offset from the base
    // that was mapped as memory is mapped at the start of a page
    data_source_mapped_dev_base = data_source_mapped_base + (data_source_dev_base & DATA_SOURCE_MAP_MASK);


    // get data memory map
    data_target_mapped_base = mmap(0, DATA_TARGET_MAP_SIZE, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_SHARED, memfd, data_target_dev_base & ~DATA_TARGET_MAP_MASK);
        if (data_target_mapped_base == (void *) -1) {
        printf("Can't map the data target to user space.\n");
        return 1;
    }

    //printf("Data target mapped at address %p.\n", data_target_mapped_base);

    // get the address of the device in user space which will be an offset from the base
    // that was mapped as memory is mapped at the start of a page
    data_target_mapped_dev_base = data_target_mapped_base + (data_target_dev_base & DATA_TARGET_MAP_MASK);


	printf("%08x\n", read_from_slv_reg(SLV_REG31_OFFSET));

	// load data into DDR/L2-Cache
	initSourceMemory(0, 2*BURST_LENGTH*NUM_BURSTS);
	printSourceMemory(0, 2*BURST_LENGTH*NUM_BURSTS);

    // set AX_CACHE
    write_to_slv_reg(SLV_REG29_OFFSET, AX_CACHE);
    // set AX_USER
    write_to_slv_reg(SLV_REG30_OFFSET, AX_USER);

    // clear interrupts
    write_to_slv_reg(SLV_REG1_OFFSET, (1 << 31));

    // read values from DDR into BRAM
    // ddr_start_address
    write_to_slv_reg(SLV_REG2_OFFSET, SOURCE_ADDRESS);
    // burst_length
    write_to_slv_reg(SLV_REG3_OFFSET, BURST_LENGTH-1);
    // num_bursts
    write_to_slv_reg(SLV_REG4_OFFSET, NUM_BURSTS);
    // bram_start_address
    write_to_slv_reg(SLV_REG5_OFFSET, BRAM_ADDRESS);

    // read_data
    write_to_slv_reg(SLV_REG1_OFFSET, (1 << 0));

    // poll slave until burst transactions are done
    while((read_from_slv_reg(SLV_REG0_OFFSET) & (1 << 0)) != (1 << 0)) {}

    // clear interrupts
    write_to_slv_reg(SLV_REG1_OFFSET, (1 << 31));

    // write values from BRAM into DDR
    // ddr_start_address
    write_to_slv_reg(SLV_REG2_OFFSET, TARGET_ADDRESS);
    // burst_length
    write_to_slv_reg(SLV_REG3_OFFSET, BURST_LENGTH-1);
    // num_bursts
    write_to_slv_reg(SLV_REG4_OFFSET, NUM_BURSTS);
    // bram_start_address
    write_to_slv_reg(SLV_REG5_OFFSET, BRAM_ADDRESS);

    // write_data
    write_to_slv_reg(SLV_REG1_OFFSET, (1 << 1));

    // poll slave until burst transactions are done
    while((read_from_slv_reg(SLV_REG0_OFFSET) & (1 << 0)) != (1 << 0)) {}

    // clear interrupts
    write_to_slv_reg(SLV_REG1_OFFSET, (1 << 31));

    //printTargetMemory(0, 2*BURST_LENGTH*NUM_BURSTS);

    // check if data in DDR/L2-Cache is okay
    printf("Check data in DDR:\n\r");
	printf("SOURCE:                         TARGET:\n\r");

    for(i = 0; i < 2*BURST_LENGTH*NUM_BURSTS; i++) {
		printf("%08x : 0x%016lx   %08x : 0x%016lx   %s\n\r", (uint32_t) (i*sizeof(uint64_t)+SOURCE_ADDRESS), read_uint64_t_from_data_source(i*sizeof(uint64_t)), (uint32_t) (i*sizeof(uint64_t)+TARGET_ADDRESS), read_uint64_t_from_data_target(i*sizeof(uint64_t)), (read_uint64_t_from_data_source(i*sizeof(uint64_t)) == read_uint64_t_from_data_target(i*sizeof(uint64_t))) ? "OK" : "FAILED");
    }


	// cleanup

	// unmap axi slave 
    if (munmap(slv_mapped_base, SLV_MAP_SIZE) == -1) {
        printf("Can't unmap AXI-slave from user space.\n");
    }

    // unmap data source
    if (munmap(data_source_mapped_base, DATA_SOURCE_MAP_SIZE) == -1) {
        printf("Can't unmap data source from user space.\n");
    }

    // unmap data
    if (munmap(data_target_mapped_base, DATA_TARGET_MAP_SIZE) == -1) {
        printf("Can't unmap data target from user space.\n");
    }

	// close /dev/mem
    close(memfd);

    printf("END\n");

    return 0;
}
