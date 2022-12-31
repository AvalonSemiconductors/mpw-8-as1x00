# AS1x00 4-bit Microcontroller

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

<div>
<p>
This project is my first attempt at building a microcontroller. I decided to start with the design of the TMS1000 Microcontroller from 1975, and add several architectural and implementation improvements, including the ability to enable the extensions introduced by the TMS1100, so the design can emulate either chip.
</p>
<h3>Features/Improvements include:</h3>
<ul>
<li>1024 or 2048 bytes of program memory</li>
<li>128 or 256 words of data memory</li>
<li>Use of a RAM block initialized over wishbone as program memory, instead of a OTP ROM</li>
<li>Microcode re-programmable over wishbone</li>
<li>One output port using a re-programmable PLA</li>
<li>6 clock cycles per instruction</li>
<li>16+8 output ports</li>
<li>4 input ports</li>
</ul>
<p>
Full documentation is TODO.
</p>
</div>
