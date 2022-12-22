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
#define R_outs (reg_mprj_wb >> 8)

#define signal_progress { test_step++; reg_mprj_datal = test_step << 8; }
#define error_out { reg_mprj_datal = (1 << 31) | (test_step << 8); test_reg_shadow |= (1 << 1); reg_mprj_wb = test_reg_shadow; while(1); }

/*
 * ; Test R output
 * 0D SETR
 * 44 TCY 4
 * 0D SETR
 * 45 TCY 5
 * 0D SETR
 * 44 TCY 4
 * 0C RSTR
 * 40 TCY 0
 * 0C RSTR
 * 49 TCY 9
 * 0C RSTR
 * ; Test O output
 * 4A TCY 10
 * 23 TYA
 * 0A TDO
 * ; Arithmetic test, use TCY as NOP to set status
 * 06 A6AAC
 * 40 TCY 0
 * 0A TDO
 * 01 A8AAC
 * 40 TCY 0
 * 0A TDO
 * 05 A10AAC
 * 40 TCY 0
 * 0A TDO
 * 00 COMX
 * 0A TDO
 * 2D CPAIZ
 * 0A TDO
 * ; Test TAY
 * 24 TAY
 * 05 A10AAC
 * 23 TYA
 * 0A TDO
 */
const uint8_t rom_data1[] = {
    0x0D, 0x44, 0x0D, 0x45,
    0x0D, 0x44, 0x0C, 0x40,
    0x0C, 0x49, 0x0C, 0x4A,
    0x23, 0x0A, 0x06, 0x40,
    
    0x0A, 0x01, 0x40, 0x0A,
    0x05, 0x40, 0x0A, 0x00,
    0x0A, 0x2D, 0x0A, 0x24,
    0x05, 0x23, 0x0A, 0x00,
    
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
};
const uint32_t rom_data1_len = 64;

const uint8_t rom_data2[] = {
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00,
};
const uint32_t rom_data2_len = 16;

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
#ifdef UART_DEBUG
    reg_mprj_io_6  = GPIO_MODE_MGMT_STD_OUTPUT;
#else
    reg_mprj_io_6  = GPIO_MODE_MGMT_STD_INPUT_PULLDOWN;
#endif
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

#ifdef UART_DEBUG
    reg_uart_enable = 1;
    *((volatile uint32_t*)0x20000000) = 8333; //reg_uart_clkdiv
#endif

     /* Apply configuration */
    reg_mprj_xfer = 1;
    while(reg_mprj_xfer == 1);
    reg_mprj_datal = 0xFF00;
    reg_mprj_datah = 0;

    reg_mprj_wb = test_reg_shadow = 0b0011; //Assume control over the design using Wishbone. Its ours now!
#ifdef UART_DEBUG
    print("SoC: Begin!\nSoC: Write program memory.\n");
#endif

    //Write
    for(int i = 0; i < rom_data1_len; i++) {
        *(pram_addr + (15 * 64) + i) = rom_data1[i];
    }
    reg_mprj_datal = 0;
#ifdef UART_DEBUG
    print("SoC: Verify program memory.\n");
#endif

    //Verify
    for(int i = 0; i < rom_data1_len; i++) {
        if(*(pram_addr + (15 * 64) + i) != rom_data1[i]) {
#ifdef UART_DEBUG
            print("SoC: Verification error!\n\n");
#endif
            error_out;
        }
    }
    signal_progress

    clock_cycles(5*6, &test_reg_shadow);
    if(R_outs != 0b110001) error_out;
    clock_cycles(6*6, &test_reg_shadow);
    if(R_outs != 0b100000) error_out;
    signal_progress
    
    
    
    /*clock_cycles(9*6, &test_reg_shadow); //Make PC overflow and wrap around, then run the first few instructions again
    if(R_outs != 0b110001) error_out;
    signal_progress
    reg_mprj_wb = test_reg_shadow = 0b0011; //Hold in reset*/
    
    reg_mprj_datal = 254 << 8;
    while(1) {}
}
