/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include <defs.h>
#include <stub.c>

#define reg_mprj_wb (*(volatile uint32_t*)0x30800000)
#define pram_addr ((volatile uint8_t*)0x30010000)
#define reg_gpio_data (*(volatile uint32_t*)0x21000000)
#define reg_gpio_ena (*(volatile uint32_t*)0x21000004)
#define R_outs ((reg_mprj_wb >> 8) & 0xFFFF)
#define O_outs (reg_mprj_wb & 0xFF)
#define TMS_status ((reg_mprj_wb >> 24) & 1)
#define X_reg ((reg_mprj_wb >> 25) & 0b111)
#define reg_pla_ins_ands ((volatile uint32_t*)0x30020000)
#define reg_pla_ins_ors ((volatile uint32_t*)0x30020080)
#define reg_pla_O_ands ((volatile uint32_t*)0x30020100)
#define reg_pla_O_ors ((volatile uint32_t*)0x30020180)

#define signal_progress { test_step++; reg_mprj_datal = test_step << 8; }
#define error_out { reg_mprj_datal = (1 << 31) | (test_step << 8); test_reg_shadow |= (1 << 1); reg_mprj_wb = test_reg_shadow; while(1); }

#define getNextAddr(addr) (((addr << 1) | (!((((addr >> 5) & 1) != ((addr >> 4) & 1)) | (addr == 0b111111)) | (addr == 0x1F) )) & 0b111111)

// Modification: extend TDO instruction to TDODYN as described in data manual page 170
const uint32_t custom_ins_pla_ands[] = {
    0b0110101010101010,
    0b0110101000000000,
    0b0110100100000000,
    0b0110011000000000,
    0b0110010100000000,
    0b0101101010101010,
    0b0101101010101001,
    0b0101101010100110,
    0b0101101010100101,
    0b0101101010010000,
    0b0101100101101010,
    0b0101100101101001,
    0b0101100101100100,
    0b0101100101011010,
    0b0101100101011001,
    0b0101100101010110,
    0b0101100101010101,
    0b0101010110101001,
    0b0101010110010101,
    0b0101010101101010,
    0b0101010101101001,
    0b0101000101100110,
    0b0101000101100101,
    0b0101010101011010,
    0b0101010101011001,
    0b0101010101010110,
    0b0101010101010101,
    0b0101010110011001,
    0b0000000000000000,
    0b0000000000000000
};
const uint8_t custom_ins_pla_ands_len = 30;

const uint32_t custom_ins_pla_ors[] = {
    0b000000100000000001110000000000,
    0b000000000000000000000000000100,
    0b001111111110011111110111101100,
    0b000110100111111100111111110011,
    0b001001011001110011110010011111,
    0b001010111011101111111111111101,
    0b001101111111111111111001111111,
    0b001111111111111111111111111111,
    0b000111101101111110111111111111,
    0b001111111111111111110111110111,
    0b000101000000100000001000101000,
    0b001010011110000001000111000011,
    0b001101110111111110111000111000,
    0b000000100111001010100111000011,
    0b001000011000010101000000010100,
    0b000001000000000000000000000000
};
const uint8_t custom_ins_pla_ors_len = 16;

// Modification: SL = 0, A = 0 will display digit 8
const uint32_t custom_O_pla_ands[] = {
    0b1001010101,
    0b1001010110,
    0b1001011001,
    0b1001011010,
    0b1001100101,
    0b1001100110,
    0b1001101001,
    0b1001101010,
    0b1010010101,
    0b1010010110,
    0b1010011001,
    0b1010011010,
    0b1010100101,
    0b1010100110,
    0b1010101001,
    0b1010101010,
    0b0100000010,
    0b0100001000,
    0b0100100000,
    0b0101010101
};
const uint8_t custom_O_pla_ands_len = 20;

const uint32_t custom_O_pla_ors[] = {
    0b00010000000000000000,
    0b10101101011111101101,
    0b11000010011110011111,
    0b10000010111111111011,
    0b10000111101101101101,
    0b10001111110101000101,
    0b10001101111101110001,
    0b10001110111101111100
};
const uint8_t custom_O_pla_ors_len = 8;

/*
 * 4F TCY 15
 * 23 TYA
 * 0A TDODYN
 * 23 TYA
 * 0A TDODYN
 * 23 TYA
 * 0A TDODYN
 * 40 TCY 0
 * 0A TDODYN
 * 23 TYA
 * 0A TDODYN
 * 40 TCY 0
 * 7F CLA
 * 02 YNEA
 * 0A TDODYN
 */
const uint8_t rom_data1[] = {
    0x4F, 0x23, 0x0A, 0x23,
    0x0A, 0x23, 0x0A, 0x40,
    0x0A, 0x23, 0x0A, 0x40,
    0x7F, 0x02, 0x0A, 0x00
};
const uint32_t rom_data1_len = 16;

/* Expected states of O-output with the standard PLA */
const uint8_t digits[] = {
    //SL high
    0b01111110,
    0b00001100,
    0b10110110,
    0b10011110,
    0b11001100,
    0b11011010,
    0b11111010,
    0b00001110,
    0b11111110,
    0b11011110,
    0b11101110,
    0b11111000,
    0b01110010,
    0b10111100,
    0b11110010,
    0b11100010,
    //SL low
    0b00000001,
    0b00000010,
    0b00000100,
    0b00001000
};

void clock_cycles(uint8_t cycles, int* test_reg_shadow) {
    *test_reg_shadow &= ~(1 << 1);
    reg_mprj_wb = *test_reg_shadow;
    for(uint8_t i = 0; i < cycles; i++) {
        *test_reg_shadow ^= (1 << 2);
        reg_mprj_wb = *test_reg_shadow;
    }
}

void main()
{
    int test_reg_shadow;
    uint8_t test_step = 0;

    reg_spi_enable = 1;
    reg_wb_enable = 1;

    reg_mprj_io_5  = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_6  = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_7  = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_8  = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_9  = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_10 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_11 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_12 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_13 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_14 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_15 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_16 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_17 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_18 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_19 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_20 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_21 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_22 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_23 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_24 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_25 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_26 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_27 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_28 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_29 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_30 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_32 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_33 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_34 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_35 = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
    reg_mprj_io_36 = GPIO_MODE_USER_STD_OUTPUT;
    reg_mprj_io_37 = GPIO_MODE_USER_STD_OUTPUT;

     /* Apply configuration */
    reg_mprj_xfer = 1;
    while(reg_mprj_xfer == 1);
    reg_mprj_datal = 0xFF00;
    reg_mprj_datah = 0;

    reg_mprj_wb = test_reg_shadow = 0b11011; //Assume control over the design using Wishbone. Its ours now!

    //Write
    uint8_t addr = 0;
    for(int i = 0; i < rom_data1_len; i++) {
        *(pram_addr + (15 * 64) + addr) = rom_data1[i];
        addr = getNextAddr(addr);
    }
    reg_mprj_datal = 0;

    //Verify
    addr = 0;
    for(int i = 0; i < rom_data1_len; i++) {
        if(*(pram_addr + (15 * 64) + addr) != rom_data1[i]) error_out
        addr = getNextAddr(addr);
    }
    signal_progress

    //Write
    for(int i = 0; i < custom_ins_pla_ands_len; i++) {
        *(reg_pla_ins_ands + i) = custom_ins_pla_ands[i];
    }
    for(int i = 0; i < custom_ins_pla_ors_len; i++) {
        *(reg_pla_ins_ors + i) = custom_ins_pla_ors[i];
    }
    for(int i = 0; i < custom_O_pla_ands_len; i++) {
        *(reg_pla_O_ands + i) = custom_O_pla_ands[i];
    }
    for(int i = 0; i < custom_O_pla_ors_len; i++) {
        *(reg_pla_O_ors + i) = custom_O_pla_ors[i];
    }
    signal_progress

    //Verify
    for(int i = 0; i < custom_ins_pla_ands_len; i++) {
        if(*(reg_pla_ins_ands + i) != custom_ins_pla_ands[i]) error_out
    }
    for(int i = 0; i < custom_ins_pla_ors_len; i++) {
        if(*(reg_pla_ins_ors + i) != custom_ins_pla_ors[i]) error_out
    }
    for(int i = 0; i < custom_O_pla_ands_len; i++) {
        if(*(reg_pla_O_ands + i) != custom_O_pla_ands[i]) error_out
    }
    for(int i = 0; i < custom_O_pla_ors_len; i++) {
        if(*(reg_pla_O_ors + i) != custom_O_pla_ors[i]) error_out
    }
    signal_progress

    //Run tests
    clock_cycles(3*6+4, &test_reg_shadow);
    if(O_outs != digits[15]) error_out
    clock_cycles(2*6, &test_reg_shadow);
    if(O_outs != digits[14]) error_out
    clock_cycles(2*6, &test_reg_shadow);
    if(O_outs != digits[13]) error_out
    if(TMS_status != 1) error_out
    clock_cycles(2*6, &test_reg_shadow);
    if(O_outs != digits[13]) error_out
    if(TMS_status != 0) error_out
    clock_cycles(2*6, &test_reg_shadow);
    if(O_outs != digits[15]) error_out
    if(TMS_status != 1) error_out
    signal_progress
    clock_cycles(4*6, &test_reg_shadow);
    if(O_outs != digits[8]) error_out
    signal_progress

    clock_cycles(1*6, &test_reg_shadow); //Just to add some delay

    reg_mprj_wb = test_reg_shadow = 0b0011; //Hold in reset
    
    reg_mprj_datal = 254 << 8;
    while(1) {}
}
