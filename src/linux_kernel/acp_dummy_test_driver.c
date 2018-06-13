/*  acpdummytest.c */

#include <linux/module.h>
#include <linux/version.h>
#include <linux/kernel.h>
#include <linux/types.h>
#include <linux/kdev_t.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/cdev.h>
#include <linux/uaccess.h>
#include <asm/io.h>


MODULE_LICENSE("GPL");
MODULE_AUTHOR("Konstantin (Konze) Luebeck");
MODULE_DESCRIPTION("Simple AXI ACP device driver");
MODULE_VERSION("0.01");

#define DEVICE_NAME "acp_dummy_test"
#define EXAMPLE_MSG "Hello, World!\n"
#define MSG_BUFFER_LEN 16

// AX_CACHE value
//#define AX_CACHE 0x7
//#define AX_CACHE 0xB
#define AX_CACHE 0xF
// AX_USER value
//#define AX_USER 0x1
#define AX_USER 0x2
// from where in the DDR should data be read by the AXI-Master
#define SOURCE_ADDRESS 0x78000000
// to which location in the DDR should the AXI-Master write
#define TARGET_ADDRESS 0x79000000
// how many 128 Bit values should be transmitted in each burst
#define BURST_LENGTH 4

#define SLV_AXI_BASE_ADDR 0x80000000
#define SLV_MAP_SIZE 128UL // = 32*4

#define DATA_SOURCE_MAP_SIZE 0x4000 
#define DATA_TARGET_MAP_SIZE 4096UL

#define ACP_DUMMY_BRAM_SIZE 1024 // bytes

static void __iomem *slv; 
static void __iomem *source; 
static void __iomem *target; 

/* Prototypes for device functions */
static loff_t device_seek(struct file *, loff_t, int);
static ssize_t device_read(struct file *, char *, size_t, loff_t *);
static ssize_t device_write(struct file *, const char *, size_t, loff_t *);
static int device_open(struct inode *, struct file *);
static int device_release(struct inode *, struct file *);

static int major_num;
static int device_open_count = 0;
static int cursor;
static char bram[ACP_DUMMY_BRAM_SIZE];

static char* bram_ptr;

/* This structure points to all of the device functions */
static struct file_operations file_ops = {
    .llseek = device_seek,
    .read = device_read,
    .write = device_write,
    .open = device_open,
    .release = device_release
};

static loff_t device_seek(struct file *flip, loff_t offset, int whence) {
    if(whence == SEEK_SET) {
        cursor = offset % (ACP_DUMMY_BRAM_SIZE);
    }
    else if(whence == SEEK_CUR) {
        cursor = (cursor + offset) % (ACP_DUMMY_BRAM_SIZE);
    } 
    else if(whence == SEEK_END) {
        cursor = (ACP_DUMMY_BRAM_SIZE + offset) % (ACP_DUMMY_BRAM_SIZE);
    }
}

/* When a process reads from our device, this gets called. */
static ssize_t device_read(struct file *flip, char *buffer, size_t len, loff_t *offset) {

    int bytes_read = 0;

    int i;
    char byte;

    // in each acp burst 4 128 bit (= 64 byte) values will be transmitted calculate the number of 64 byte bursts 
    int num_bursts = (len + 64 - 1) / 64;

    // clear interupts
    iowrite32((1 << 31), (uint32_t*)slv + 1);

    // write values from BRAM into DDR
    // ddr_start_address
    iowrite32(TARGET_ADDRESS, (uint32_t*)slv + 2);
    // burst_length
    iowrite32(BURST_LENGTH-1, (uint32_t*)slv + 3);
    // num_bursts
    iowrite32(num_bursts, (uint32_t*)slv + 4);
    // bram_start_address
    iowrite32(cursor, (uint32_t*)slv + 5);

    // write_data
    iowrite32((1 << 1), (uint32_t*)slv + 1);
    
    while( (ioread32((uint32_t*)slv + 0)) & (1 << 0) != (1 << 0)) {}

    // clear interupts
    iowrite32((1 << 31), (uint32_t*)slv + 1);

    
    // check if there is enough space starting at the cursor
    if(cursor + len > ACP_DUMMY_BRAM_SIZE) {
        len = ACP_DUMMY_BRAM_SIZE - cursor;
    }

    bram_ptr = bram + cursor;

    for(i = 0; i < len; i++) {
        put_user(ioread8((uint8_t*)target + i), buffer++);
        bytes_read++;
    }

    cursor = cursor + bytes_read;
    return bytes_read;
}

/* Called when a process tries to write to our device */
static ssize_t device_write(struct file *flip, const char *buffer, size_t len, loff_t *offset) {

    int i;
    char byte;

    // in each acp burst 4 128 bit (= 64 byte) values will be transmitted calculate the number of 64 byte bursts
    int num_bursts = (len + 64 - 1) / 64;


    // check if there is enough space starting at the cursor
    if(cursor + len > ACP_DUMMY_BRAM_SIZE) {
        len = ACP_DUMMY_BRAM_SIZE - cursor;
    }

    bram_ptr = bram + cursor;

    for(i = 0; i < len; i++) {
        if(copy_from_user(&byte, buffer + i, 1)) {
            return -EFAULT;
        }

        // write byte to source
        iowrite8(byte, (uint8_t*)source + i);

        *bram_ptr = byte;
        bram_ptr++;
    }

    /*
    // print data written into source in kernel log
    for(i = 0; i < len; i++) {
        printk(KERN_INFO "0x%02x\n", ioread8((uint8_t*)source + i));
    }
    */


    // clear interupts
    iowrite32((1 << 31), (uint32_t*)slv + 1);
    
    // read values from DDR into BRAM
    // ddr_start_address
    iowrite32(SOURCE_ADDRESS, (uint32_t*)slv + 2);
    // burst_length 
    iowrite32(BURST_LENGTH-1, (uint32_t*)slv + 3);
    // num_bursts
    iowrite32(num_bursts, (uint32_t*)slv + 4);
    // bram_start_address
    iowrite32(cursor, (uint32_t*)slv + 5);

    // read_data
    iowrite32((1 << 0), (uint32_t*)slv + 1);
   
    while( (ioread32((uint32_t*)slv + 0)) & (1 << 0) != (1 << 0)) {}

    // clear interupts
    iowrite32((1 << 31), (uint32_t*)slv + 1);

    cursor = cursor + len;

    return len;
}

/* Called when a process opens our device */
static int device_open(struct inode *inode, struct file *file) {

    cursor = 0;

    /* If device is open, return busy */
    if (device_open_count) {
        return -EBUSY;
    }
    device_open_count++;
    try_module_get(THIS_MODULE);
    return 0;
}

/* Called when a process closes our device */
static int device_release(struct inode *inode, struct file *file) {
    /* Decrement the open counter and usage count. Without this, the module would not unload. */
    device_open_count--;
    module_put(THIS_MODULE);
    return 0;
}

static int __init acp_dummy_test_init(void) {

    // map AXI-slave
    if((slv = ioremap(SLV_AXI_BASE_ADDR, SLV_MAP_SIZE)) == NULL) {
        printk(KERN_ERR "Mapping AXI-slave failed\n");
        return -1;
    } 

    printk(KERN_INFO "slv_reg31: 0x%08x\n", ioread32((uint32_t*)slv + 31));

    // map source address
    if((source = ioremap_cache(SOURCE_ADDRESS, DATA_SOURCE_MAP_SIZE)) == NULL) {
        printk(KERN_ERR "Mapping data source failed\n");
        return -1;
    } 

    printk(KERN_INFO "Data source: 0x%08x mapped\n", SOURCE_ADDRESS);

    // map target address
    if((target = ioremap_cache(TARGET_ADDRESS, DATA_TARGET_MAP_SIZE)) == NULL) {
        printk(KERN_ERR "Mapping data target failed\n");
        return -1;
    } 

    printk(KERN_INFO "Data target: 0x%08x mapped\n", TARGET_ADDRESS);

    // clear BRAM
    memset(bram, 0, ACP_DUMMY_BRAM_SIZE);

    // set up acp dummy
    // set AX_CACHE
    iowrite32(AX_CACHE, (uint32_t*)slv + 29);
    // set AX_USER
    iowrite32(AX_USER, (uint32_t*)slv + 30);
    // clear interupts
    iowrite32((1 << 31), (uint32_t*)slv + 1);
    
    /* Try to register character device */
    major_num = register_chrdev(0, "acp_dummy_test", &file_ops);
    if (major_num < 0) {
        printk(KERN_ALERT "Could not register device: %d\n", major_num);
        return major_num;
    } else {
        printk(KERN_INFO "acp_dummy_test module loaded with device major number %d\n", major_num);
        return 0;
    }
}

static void __exit acp_dummy_test_exit(void) {

    iounmap(slv);
    iounmap(source);
    iounmap(target);

    /* Remember — we have to clean up after ourselves. Unregister the character device. */
    unregister_chrdev(major_num, DEVICE_NAME);
    printk(KERN_INFO "Goodbye, World!\n");
}

/* Register module functions */
module_init(acp_dummy_test_init);
module_exit(acp_dummy_test_exit);
