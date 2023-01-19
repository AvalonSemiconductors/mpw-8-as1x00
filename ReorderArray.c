#include <stdio.h>
#include <stdint.h>

const uint8_t rom_data1[] = {
    0x0D, 0x42, 0x0D, 0x4A,
    0x0D, 0x42, 0x0C, 0x40,
    0x0C, 0x49, 0x0C, 0x40,
    0x23, 0x45, 0x02, 0x23,

    0x0A, 0x06, 0x40, 0x0A,
    0x01, 0x40, 0x0A, 0x05,
    0x4B, 0x0A, 0x23, 0x0A,
    0x2D, 0x0A, 0x24, 0x05,

    0x0A, 0x23, 0x0A, 0x2F,
    0x0A, 0x0B, 0x08, 0x02,
    0x0A, 0x0E, 0x0A, 0x07,
    0x0A, 0x24, 0x2B, 0x0D,

    0x2C, 0x2C, 0x0D, 0x40,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
};

#define getNextAddr(addr) (((addr << 1) | (!((((addr >> 5) & 1) != ((addr >> 4) & 1)) | (addr == 0b111111)) | (addr == 0x1F) )) & 0b111111)

void main(void) {
	uint8_t addr = 0;
	uint8_t ordered[64];
	for(int i = 0; i < 64; i++) ordered[i] = 0;
	for(int i = 0; i < 64; i++) {
		ordered[addr] = rom_data1[i];
		addr = getNextAddr(addr);
		printf("%d\n", addr);
	}
	printf("{");
	for(int i = 0; i < 64; i++) {
		if(i % 4 == 0) printf("\n\t");
		printf("0x%02x,", ordered[i]);
		if((i + 1) % 4 != 0) printf(" ");
	}
	printf("\n};");
}
