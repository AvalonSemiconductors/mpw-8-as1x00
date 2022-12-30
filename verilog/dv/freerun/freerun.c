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

#define signal_progress { test_step++; reg_mprj_datal = test_step << 8; }
#define error_out { reg_mprj_datal = (1 << 31) | (test_step << 8); test_reg_shadow |= (1 << 1); reg_mprj_wb = test_reg_shadow; while(1); }

/*
 * 0: 2F CLA
 * 1: 24 TAY
 * 2: 0D SETR
 * 3: 2B IYC
 * 4: 23 TYA
 * 5: 0A TDO
 * 6: 5F YNEC 15
 * 7: 82 BR 2
 * 8: 2C DYN
 * 9: 23 TYA
 * 10: 0A TDO
 * 11: 0C RSTR
 * 12: 50 YNEC 0
 * 13: 88 BR 8
 * 14: 80 BR 0
 */
const uint8_t rom_data1[] = {
    0x2F, 0x24, 0x0D, 0x2B,
    0x23, 0x0A, 0x5F, 0x82,
    0x2C, 0x23, 0x0A, 0x0C,
    0x50, 0x88, 0x80, 0x00
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
        if(*(pram_addr + (15 * 64) + i) != rom_data1[i]) error_out
    }
    signal_progress
    reg_mprj_wb = test_reg_shadow = 0; //Release wishbone control

    while(O_outs != digits[3]);
    while(O_outs != digits[10]);
    while(R_outs != 0b1111111);
    while(R_outs != 0b111);
    signal_progress
    while(R_outs != 0b1);

    reg_mprj_datal = 254 << 8;
    while(1) {}
}
