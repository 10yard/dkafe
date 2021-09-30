--[[
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Graphic helpers
---------------
]]

local string_sub = string.sub
local string_len = string.len

-- Characters
dkchars = {}
dkchars["0"] = 0x00
dkchars["1"] = 0x01
dkchars["2"] = 0x02
dkchars["3"] = 0x03
dkchars["4"] = 0x04
dkchars["5"] = 0x05
dkchars["6"] = 0x06
dkchars["7"] = 0x07
dkchars["8"] = 0x08
dkchars["9"] = 0x09
dkchars[" "] = 0x10
dkchars["A"] = 0x11
dkchars["B"] = 0x12
dkchars["C"] = 0x13
dkchars["D"] = 0x14
dkchars["E"] = 0x15
dkchars["F"] = 0x16
dkchars["G"] = 0x17
dkchars["H"] = 0x18
dkchars["I"] = 0x19
dkchars["J"] = 0x1a
dkchars["K"] = 0x1b
dkchars["L"] = 0x1c
dkchars["M"] = 0x1d
dkchars["N"] = 0x1e
dkchars["O"] = 0x1f
dkchars["P"] = 0x20
dkchars["Q"] = 0x21
dkchars["R"] = 0x22
dkchars["S"] = 0x23
dkchars["T"] = 0x24
dkchars["U"] = 0x25
dkchars["V"] = 0x26
dkchars["W"] = 0x27
dkchars["X"] = 0x28
dkchars["Y"] = 0x29
dkchars["Z"] = 0x2a
dkchars["."] = 0x2b
dkchars["-"] = 0x2c
dkchars[":"] = 0x2e
dkchars["<"] = 0x30
dkchars[">"] = 0x31
dkchars["="] = 0x34
dkchars["$"] = 0x36  -- double exclamations !!
dkchars["!"] = 0x38
dkchars["'"] = 0x3a
dkchars[","] = 0x43
dkchars["["] = 0x49 -- copyright part 1
dkchars["]"] = 0x4a -- copyright part 2
dkchars["("] = 0x4b -- ITC part 1
dkchars[")"] = 0x4c -- ITC part 2
dkchars["^"] = 0xb0 -- rivet block
dkchars["?"] = 0xfb
dkchars["@"] = 0xff -- extra mario icon

function write_message(start_address, text)
    -- write characters of message to DK's video ram
    local _dkchars = dkchars
    for key=1, string_len(text) do
		mem:write_u8(start_address - ((key - 1) * 32), _dkchars[string_sub(text, key, key)])
    end
end