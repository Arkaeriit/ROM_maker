# ROM\_maker
This program is used to make a ROM in Verilog from a binary file.

## Usage
Usage: ROM\_maker <arguments...>
List of available arguments:
- name <name>: The name of the Verilog module. Default to "rom".
- input\_file <file>: The binary file the data is read from. Default to `/dev/stdin`.
- output\_file <file>: The file where the Verilog code is written. Default to `/dev/stdout`.
- wordsize <size>: Width in byte of the data bus of the ROM. Default to a single byte.
- asynchronous: Use this flag to make the ROM asynchronous. It is synchronous by default.
- big\_endian: Use this flag to read the data as big endian words. It is read as little endian otherwise.

## Output module
The ouputed Verilog module got a `clk` input if it is synchronous. It got an `enable` input. It got an `addr` bus input for the address and a `data` bus output.

