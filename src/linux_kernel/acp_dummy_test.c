#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

// how many 64 bit words should be written and read to acp_dummy 
#define NUM_64BIT_WORDS 24
// calculates the char buffer length for the number 64 bit words that should be
// transferred
#define BUFFER_LENGTH ((64/8)*NUM_64BIT_WORDS)
// to which and from which address should the AXI-Master write in the BRAM
#define BRAM_ADDRESS 648

int main() {

    printf("START\n");

    int fd;
    uint32_t i, j;

    char buffer_0[BUFFER_LENGTH];
    char buffer_1[BUFFER_LENGTH];

    fd = open("/dev/acp_dummy", O_RDWR);

    if(fd < 0) {
        printf("Can't open /dev/acp_dummy.\n");
        return 1;
    }

    // set cursor to initial position (only multiples of 16 allowed)
    lseek(fd, BRAM_ADDRESS, SEEK_SET);

    // fill buffer_0
    j = 0;

    for(i = 0; i < NUM_64BIT_WORDS; i++) {
        buffer_0[i*8]   = j & 0xFF;
        buffer_0[i*8+1] = (j >> 8) & 0xFF;
        buffer_0[i*8+2] = (j >> 16) & 0xFF;
        buffer_0[i*8+3] = (j >> 24) & 0xFF;
        j++;

        buffer_0[i*8+4] = j & 0xFF;
        buffer_0[i*8+5] = (j >> 8) & 0xFF;
        buffer_0[i*8+6] = (j >> 16) & 0xFF;
        buffer_0[i*8+7] = (j >> 24) & 0xFF;
        j++;
    }

    // write the whole content of buffer_0 to acp_dummy
    write(fd, buffer_0, BUFFER_LENGTH); 


    // set cursor to initial position
    lseek(fd, BRAM_ADDRESS, SEEK_SET);
    // read to buffer_1 from acp_dummy
    read(fd, buffer_1, BUFFER_LENGTH);


    // check if data in DDR/L2-Cache is okay
    uint64_t source_word;
    uint64_t target_word;

    printf("Check data in DDR:\n\r");
	printf("SOURCE:                     TARGET:\n\r");

    for(i = 0; i < NUM_64BIT_WORDS; i++) {
        source_word = (uint64_t) (((uint64_t) buffer_0[i*8+7] << 56) | ((uint64_t) buffer_0[i*8+7] << 56) | ((uint64_t) buffer_0[i*8+6] << 48) | ((uint64_t) buffer_0[i*8+5] << 40) | ((uint64_t) buffer_0[i*8+4] << 32) | ((uint64_t) buffer_0[i*8+3] << 24) | ((uint64_t) buffer_0[i*8+2] << 16) | ((uint64_t) buffer_0[i*8+1] << 8) | buffer_0[i*8]);
        target_word = (uint64_t) (((uint64_t) buffer_1[i*8+7] << 56) | ((uint64_t) buffer_1[i*8+7] << 56) | ((uint64_t) buffer_1[i*8+6] << 48) | ((uint64_t) buffer_1[i*8+5] << 40) | ((uint64_t) buffer_1[i*8+4] << 32) | ((uint64_t) buffer_1[i*8+3] << 24) | ((uint64_t) buffer_1[i*8+2] << 16) | ((uint64_t) buffer_1[i*8+1] << 8) | buffer_1[i*8]);
		printf("%4d : 0x%016lx   %4d : 0x%016lx   %s\n\r", i, source_word, i, target_word, (source_word == target_word) ? "OK" : "FAILED");
    }


    close(fd);

    printf("END\n");

    return 0;
}
