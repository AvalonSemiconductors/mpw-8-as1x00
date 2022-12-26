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

#define signal_progress { test_step++; reg_mprj_datal = test_step << 8; }
#define error_out { reg_mprj_datal = (1 << 31) | (test_step << 8); test_reg_shadow |= (1 << 1); reg_mprj_wb = test_reg_shadow; while(1); }

/*
 * 4A TCY 5
 * 23 TYA
 * 3C LDX 0
 * 03 TAM
 * 2F CLA
 * 0A TDO
 * 21 TMA
 * 0A TDO
 * 48 TCY 1
 * 23 TYA
 * 20 TAMIY
 * 05 A10AAC
 * 04 TAMZA
 * 0A TDO
 * 0D SETR
 * 2E XMA
 * 
 * 0A TDO
 * 2C DYN
 * 22 TMY
 * 23 TYA
 * 0A TDO
 * 44 TCY 2
 * 21 TMA
 * 0A TDO
 * 3E LDX 1
 * 45 TCY 10
 * 23 TYA
 * 03 TAM
 * 01 A8AAC
 * 00 COMX
 * 03 TAM
 * 00 COMX
 * 
 * 21 TMA
 * 0A TDO
 * 00 COMX
 * 21 TMA
 * 0A TDO
 * 25 AMAAC
 * 0A TDO
 * 27 SAMAN
 * 0A TDO
 * 28 IMAC
 * 0A TDO
 * 2A DMAN
 * 0A TDO
 * 31 SBIT 2
 * 21 TMA
 * 0A TDO
 * 
 * 36 RBIT 1
 * 21 TMA
 * 0A TDO
 * 6A TCMIY 5
 * 03 TAM
 * 2C DYN
 * 21 TMA
 * 0A TDO
 * 2B IYC
 * 21 TMA
 * 0A TDO
 */
const uint8_t rom_data1[] = {
    0x4A, 0x23, 0x30, 0x03,
    0x2F, 0x0A, 0x21, 0x0A,
    0x48, 0x23, 0x20, 0x05,
    0x04, 0x0A, 0x0D, 0x2E,

    0x0A, 0x2C, 0x22, 0x23,
    0x0A, 0x44, 0x21, 0x0A,
    0x3E, 0x45, 0x23, 0x03,
    0x01, 0x00, 0x03, 0x00,

    0x21, 0x0A, 0x00, 0x21,
    0x0A, 0x25, 0x0A, 0x27,
    0x0A, 0x28, 0x0A, 0x2A,
    0x0A, 0x31, 0x21, 0x0A,

    0x36, 0x21, 0x0A, 0x6A,
    0x03, 0x2C, 0x21, 0x0A,
    0x2B, 0x21, 0x0A, 0x00,
    0x00, 0x00, 0x00, 0x00,
};
const uint32_t rom_data1_len = 64;

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

    reg_mprj_wb = test_reg_shadow = 0b0011; //Assume control over the design using Wishbone. Its ours now!

    //Write
    for(int i = 0; i < rom_data1_len; i++) {
        *(pram_addr + (15 * 64) + i) = rom_data1[i];
    }
    reg_mprj_datal = 0;

    //Verify
    for(int i = 0; i < rom_data1_len; i++) {
        if(*(pram_addr + (15 * 64) + i) != rom_data1[i]) {
            error_out;
        }
    }
    signal_progress
    clock_cycles(3*6+4, &test_reg_shadow);
    if(X_reg != 0) error_out;
    clock_cycles(3*6, &test_reg_shadow);
    if(O_outs != digits[0]) error_out;
    clock_cycles(2*6, &test_reg_shadow);
    if(O_outs != digits[5]) error_out;
    clock_cycles(7*6, &test_reg_shadow);
    if(O_outs != digits[0]) error_out;
    if(R_outs != 0b100) error_out;
    clock_cycles(2*6, &test_reg_shadow);
    if(O_outs != digits[11]) error_out;
    clock_cycles(4*6, &test_reg_shadow);
    if(O_outs != digits[1]) error_out;
    clock_cycles(3*6, &test_reg_shadow);
    if(O_outs != digits[0]) error_out;
    signal_progress
    clock_cycles(1*6, &test_reg_shadow);
    if(X_reg != 1) error_out;
    clock_cycles(5*6, &test_reg_shadow);
    if(X_reg != 2) error_out;
    clock_cycles(2*6, &test_reg_shadow);
    if(X_reg != 1) error_out;
    clock_cycles(2*6, &test_reg_shadow);
    if(O_outs != digits[10]) error_out;
    clock_cycles(3*6, &test_reg_shadow);
    if(O_outs != digits[2]) error_out;
    signal_progress
    clock_cycles(2*6, &test_reg_shadow);
    if(O_outs != digits[4]) error_out;
    clock_cycles(2*6, &test_reg_shadow);
    if(O_outs != digits[14]) error_out;
    clock_cycles(2*6, &test_reg_shadow);
    if(O_outs != digits[3]) error_out;
    clock_cycles(2*6, &test_reg_shadow);
    if(O_outs != digits[1]) error_out;
    signal_progress
    clock_cycles(3*6, &test_reg_shadow);
    if(O_outs != digits[6]) error_out;
    clock_cycles(4*6, &test_reg_shadow);
    if(O_outs != digits[4]) error_out;
    signal_progress
    clock_cycles(5*6, &test_reg_shadow);
    if(O_outs != digits[5]) error_out;
    clock_cycles(3*6, &test_reg_shadow);
    if(O_outs != digits[4]) error_out;
    signal_progress
    clock_cycles(4*6, &test_reg_shadow);

    reg_mprj_wb = test_reg_shadow = 0b0011; //Hold in reset
    
    reg_mprj_datal = 254 << 8;
    while(1) {}
}
