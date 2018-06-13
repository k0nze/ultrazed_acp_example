/*
 * acp_dummy.c: simple test application for the AXI ACP
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"

// AX_CACHE value
#define AX_CACHE 0xF
// AX_USER value
#define AX_USER  0x2
// from where in the DDR should data be read by the AXI-Master
#define SOURCE_ADDRESS 0x21000000
// to which location in the DDR should the AXI-Master write
#define TARGET_ADDRESS 0x28000000
// to whcih and from which address should the AXI-Master write in the BRAM
#define BRAM_ADDRESS 1024
// how many consecutive bursts should be executed
#define NUM_BURSTS 3
// how many 128 Bit values should be transmitted in each burst
#define BURST_LENGTH 4


void _Xil_Out32(volatile u32* addr, u32 data) {

	// lower 32bit
	if(((u32) addr) % 8 == 0) {
		Xil_Out64(addr, (Xil_In64(addr) & 0xFFFFFFFF00000000) | data);
	}
	// upper 32bit
	else {
		u64 temp;
		temp = ((u64) data) << 32;
		Xil_Out64(addr-1, (Xil_In64(addr-1) & 0x00000000FFFFFFFF) | temp);
	}
}

u32 _Xil_In32(volatile u32* addr) {

	u64 temp;

	// lower 32bit
	if(((u32) addr) % 8 == 0) {
		temp = Xil_In64(addr);
		return (u32) (temp & 0x00000000FFFFFFFF);
	}
	// upper 32bit
	else {
		temp = Xil_In64(addr-1);
		return (u32) ((temp & 0xFFFFFFFF00000000) >> 32);
	}
}

void initMemory(u32 start_address, u32 length) {
	int i,j;
	i = start_address;

	j = 0;
	for(i = start_address; i < start_address+(8*length); i = i + 8) {
		Xil_Out64(i, ((u64) (j*2+1) << 32) | (u64) (j*2));
		j = j + 1;
	}
}

void printMemory(u32 start_address, u32 length) {
	int i;

	printf("DDR:\n\r");
	for(i = start_address; i < start_address+(8*length); i = i + 8) {
		printf("%08x : 0x%016lx\n\r", i, Xil_In64(i));
	}
}

int main()
{
    init_platform();

    int i;

    volatile u32* volatile slaveaddr_p = (u32*) XPAR_ACP_DUMMY_0_S00_AXI_BASEADDR;

    printf("START\n\r");

    // load data into DDR/L2-Cache
    initMemory(SOURCE_ADDRESS, 2*BURST_LENGTH*NUM_BURSTS);
    printMemory(SOURCE_ADDRESS, 2*BURST_LENGTH*NUM_BURSTS);

    // set AX_CACHE
    _Xil_Out32(slaveaddr_p+29, AX_CACHE);
    // set AX_USER
    _Xil_Out32(slaveaddr_p+30, AX_USER);

    // clear interrupts
	_Xil_Out32(slaveaddr_p+1, (1 << 31));

    // read values from DDR into BRAM
    // ddr_start_address
    _Xil_Out32(slaveaddr_p+2, SOURCE_ADDRESS);
    // burst_length
    _Xil_Out32(slaveaddr_p+3, BURST_LENGTH-1);
    // num_bursts
    _Xil_Out32(slaveaddr_p+4, NUM_BURSTS);
    // bram_start_address
    _Xil_Out32(slaveaddr_p+5, BRAM_ADDRESS);

    // read_data
    _Xil_Out32(slaveaddr_p+1, (1 << 0));

    // poll slave until burst transactions are done
    while((_Xil_In32(slaveaddr_p+0) & (1 << 0)) != (1 << 0)) {}

    // clear interrupts
    _Xil_Out32(slaveaddr_p+1, (1 << 31));

    // write values from BRAM into DDR
    // ddr_start_address
	_Xil_Out32(slaveaddr_p+2, TARGET_ADDRESS);
	// burst_length
	_Xil_Out32(slaveaddr_p+3, BURST_LENGTH-1);
	// num_bursts
	_Xil_Out32(slaveaddr_p+4, NUM_BURSTS);
	// bram_start_address
	_Xil_Out32(slaveaddr_p+5, BRAM_ADDRESS);

	// write_data
	_Xil_Out32(slaveaddr_p+1, (1 << 1));

	// poll slave until burst transactions are done
	while((_Xil_In32(slaveaddr_p+0) & (1 << 0)) != (1 << 0)) {}

	// clear interrupts
	_Xil_Out32(slaveaddr_p+1, (1 << 31));

	//printMemory(TARGET_ADDRESS, 2*BURST_LENGTH*NUM_BURSTS);

	// check if data in DDR is okay
	printf("Check data in DDR:\n\r");
	printf("SOURCE:                         TARGET:\n\r");

	for(int i = 0; i < 0+(8*NUM_BURSTS*4*2); i = i + 8) {
		printf("%08x : 0x%016lx   %08x : 0x%016lx   %s\n\r", i+SOURCE_ADDRESS, Xil_In64(i+SOURCE_ADDRESS), i+TARGET_ADDRESS, Xil_In64(i+TARGET_ADDRESS), (Xil_In64(i+SOURCE_ADDRESS) == Xil_In64(i+TARGET_ADDRESS)) ? "OK" : "FAILED");
	}

    printf("END\n\r");

    cleanup_platform();
    return 0;
}

