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

-------------------------------Testing functions--------------------------------

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
test1()

