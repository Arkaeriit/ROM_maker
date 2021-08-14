#!/usr/bin/env lua

local documentation = [[This program is used to make a ROM in Verilog from a binairy file.
]]

local byte_stream = require("byte_stream")

------------------------------Verilog templates---------------------------------

--return the start of the module to make a memory block
local function memory_header(name, is_synchronous, data_size, addr_size)
    local ret = "module "..name.."("
    if is_synchronous then
        ret = ret.."input clk, "
    end
    ret = ret.."input enable, input ["..tostring(addr_size).."-1:0] addr, output ["..tostring(data_size).."-1:0] data);\n"
    ret = ret.."    reg ["..tostring(data_size).."-1:0] data_reg;\n"
    if is_synchronous then
        ret = ret.."    always @ (posedge clk)\n"
    else
        ret = ret.."    always @ (addr)\n"
    end
    ret = ret.."        case(addr)\n"
    return ret
end

--Used to terminate the module started with memory_header
local memory_footer = [[            default : data_reg <= 0;
        endcase
    assign data = ( enable ? data_reg : 0 );
endmodule
]]

--Fills the content of the case statement in the module
local function memory_content(addr, word, data_size, addr_size, big_endian)
    local serialized_word = byte_stream.format_word(word, big_endian)
    local usable_addr = tostring(addr_size).."'h"..string.format("%X", addr)
    local usable_word = tostring(data_size).."'h"..serialized_word
    local ret = "            "..usable_addr.." : data_reg <= "..usable_word..";\n"
    return ret
end

-------------------------------Testing functions--------------------------------

--testing the verilog templates
local function test1()
    local rom = memory_header("test_rom", false, 8, 9)
    rom = rom..memory_content(0, "a", 8, 9, false)
    rom = rom..memory_content(1, "b", 8, 9, false)
    rom = rom..memory_content(2, "c", 8, 9, false)
    rom = rom..memory_footer
    print(rom)
end
test1()

