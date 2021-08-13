#!/usr/bin/env lua

--[[
This file describe a class that contains a stream of byte and that can output them
word by word with the desired endianess.
]]

-------------------------------Private functions--------------------------------

--Pad a string with null bytes until is is of the desired size
local function pad_zero(data, wordsize)
    local paddig_char = '$' --should be set to '\0' unless foe debuging purpose
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
--to predic the future data acces, the wordsize and the endianess are to be provided
function new_stream(data, wordsize,big_endian)
    local ret = {}
    ret.data = data
    ret.big_endian = big_endian
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
        if not big_endian then
            ret = flip_string(ret)
        end
        return ret
    end

    return ret
end

--same as the previous function but generates a stream from a file instead
--of directely the string
--resturn nil if the fiele can not be read
function open_file_stream(filename, wordsize, eig_endian)
    local f = io.open(filename, "r")
    if not f then
        return nil
    end
    local data = f.read("a")
    return new_stream(data, wordsize, big_endian)
end

-------------------------------Testing functions--------------------------------

local function test1()
    local data = "123456789"
    local stream_be = new_stream(data, 2, true)
    local stream_le = new_stream(data, 2, false)
    print("Printing words from stream_be")
    local word = stream_be:read_word()
    while word do
        print("   "..word)
        word = stream_be:read_word()
    end
    print("Printing words from stream_le")
    word = stream_le:read_word()
    while word do
        print("   "..word)
        word = stream_le:read_word()
    end
end
test1()

