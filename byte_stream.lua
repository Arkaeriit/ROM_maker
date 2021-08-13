#!/usr/bin/env lua

--[[
This file describe a class that contains a stream of byte and that can output them
word by word with the desired endianess.
]]

-------------------------------Private functions--------------------------------

--Pad a string with null bytes until is is of the desired size
local function pad_zero(data, wordsize)
    local paddig_char = '\0' --should be set to '\0' unless foe debuging purpose
    while #data < wordsize do 
        data = data..paddig_char
    end
    return data
end

--flips a string around
local function flip_string(string)
    local ret = ""
    for i=1,#string do
        ret = string:sub(i,i)..ret
    end
    return ret
end

---------------------------------Public API-------------------------------------

--generate a new stream from a string data
--to predic the future data acces, the wordsize is to be provided
function new_stream(data, wordsize)
    local ret = {}
    ret.data = data
    ret.wordsize = wordsize
    ret.pointer = 1

    --return a wird from the stream
    --If all the stream is read, nil is returned
    ret.read_word = function(stream)
        if stream.pointer > #stream.data then
            return nil
        end
        local end_pointer = stream.pointer + wordsize - 1
        if end_pointer > #stream.data then
            end_pointer = #stream.data
        end
        local ret = stream.data:sub(stream.pointer, end_pointer)
        stream.pointer = end_pointer + 1
        ret = pad_zero(ret, stream.wordsize)
        return ret
    end

    return ret
end

--same as the previous function but generates a stream from a file instead
--of directely the string
--resturn nil if the fiele can not be read
function open_file_stream(filename, wordsize)
    local f = io.open(filename, "r")
    if not f then
        return nil
    end
    local data = f.read("a")
    return new_stream(data, wordsize)
end

------------------------------Formating functions-------------------------------

--Used to format a word (a string) in the desired endianess
--Return a printable string
function fomat_word(word, big_endian)
    local string_to_convert = word
    if not big_endian then
        string_to_convert = flip_string(string_to_convert)
    end
    local ret = ""
    for i=1,#string_to_convert do
        local current_byte = string.byte(string_to_convert:sub(i,i))
        ret = ret..string.format("%02X", current_byte)
    end
    return ret
end

-------------------------------Testing functions--------------------------------

--testing byte stream
local function test1()
    local data = "123456789"
    local stream = new_stream(data, 2)
    print("Printing words from stream")
    local word = stream:read_word()
    while word do
        print("   "..word)
        word = stream:read_word()
    end
end
--test1()

--testng formating modes
local function test2()
    local data = "123456789"
    local stream = new_stream(data, 4)
    print("Printing words from stream in big endian")
    local word = stream:read_word()
    while word do
        print("   0x"..fomat_word(word, true))
        word = stream:read_word()
    end
    stream = new_stream(data, 4)
    print("Printing words from stream in little endian")
    local word = stream:read_word()
    while word do
        print("   0x"..fomat_word(word, false))
        word = stream:read_word()
    end
end
--test2()

