#!/usr/bin/env lua

local documentation = [[This program is used to make a ROM in Verilog from a binary file.
Usage: ROM_maker <arguments...>
List of available arguments:
    -name <name>: The name of the Verilog module. Default to "rom".
    -input_file <file>: The binary file the data is read from. Default to /dev/stdin.
    -output_file <file>: The file where the Verilog code is written. Default to /dev/stdout.
    -wordsize <size>: Width in byte of the data bus of the ROM. Default to a single byte.
    -asynchronous: Use this flag to make the ROM asynchronous. It is synchronous by default.
    -big_endian: Use this flag to read the data as big endian words. It is read as little endian otherwise.

The ouputed Verilog module got a clk input if it is synchronous. It got an enable input. It got an addr bus input for the address and a data bus output.
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


-----------------------------------Main logic-----------------------------------

--Compute the needed addr size to address all the word extracted from a stream
local function get_needed_size(stream)
    local number_of_words = math.ceil(#stream.data/stream.wordsize)
    return math.ceil(math.log(number_of_words)/math.log(2))
end

--Generate a memory from a byte stream
local function stream_to_rom(stream, name, is_synchronous, big_endian)
    local ret = memory_header(name, is_synchronous, stream.wordsize*8, get_needed_size(stream))
    local addr = 0;
    local word = stream:read_word()
    while word do
        ret = ret..memory_content(addr, word, stream.wordsize*8, get_needed_size(stream), big_endian)
        addr = addr+1
        word = stream:read_word()
    end
    return ret..memory_footer
end


--------------------------------------UI----------------------------------------

--list of the diferent configuration and their defualt value
local function defaut_flags()
    local ret = {
        input_file = "/dev/stdin",
        is_synchronous = true,
        big_endian = false,
        name = "rom",
        wordsize = 1,
        output_file = "/dev/stdout",
        error = false,
        help = false
    }
    return ret
end

--reads a list of arguments and edit config flags acordingely
local function read_args(args)
    local flags = defaut_flags()
    local i = 1
    while i <= #args do
        local arg = args[i]
        if arg == "-help" or arg == "help" or arg == "--help" then
            flags.help = true
        elseif arg == "-name" then
            local name = args[i+1]
            i = i + 1
            flags.name = name
            if name == nil then
                flags.error = true
            end
        elseif arg == "-input_file" then
            local name = args[i+1]
            i = i + 1
            flags.input_file = name
            if name == nil then
                flags.error = true
            end
        elseif arg == "-output_file" then
            local name = args[i+1]
            i = i + 1
            flags.output_file = name
            if name == nil then
                flags.error = true
            end
        elseif arg == "-wordsize" then
            local wordsize = args[i+1]
            i = i + 1
            flags.wordsize = math.tointeger(wordsize)
            if wordsize == nil or not math.tointeger(flags.wordsize) then
                flags.error = true
            end
        elseif arg == "-big_endian" then
            flags.big_endian = true
        elseif arg == "-asynchronous" then
            flags.is_synchronous = false
        else
            flags.error = true
        end
        i = i + 1        
    end
    return flags
end

local function main(args)
    local flags = read_args(args)
    if flags.error then
        io.stderr:write(documentation)
        os.exit(1)
    end
    if flags.help then
        io.stdout:write(documentation)
        os.exit(0)
    end
    local stream = byte_stream.open_file_stream(flags.input_file, flags.wordsize)
    if stream == nil then
        io.stderr:write("Error, unable to open ",flags.input_file,'\n')
        os.exit(2)
    end
    local f_out = io.open(flags.output_file, "w")
    if f_out == nil then
        io.stderr:write("Error, unable to open ",flags.output_file,'\n')
        os.exit(3)
    end
    local rom = stream_to_rom(stream, flags.name, flags.is_synchronous, flags.big_endian)
    f_out:write(rom)
    f_out:close()
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
--test1()

--testing the stream reading
local function test2()
    local data = "123456789"
    local stream = byte_stream.new_stream(data, 4)
    print(stream_to_rom(stream, "test_rom2", true, true))
end
--test2()

----------------------------------Running main-----------------------------------

main(arg)

