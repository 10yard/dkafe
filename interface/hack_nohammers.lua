-- No Hammers Hack 

-- clear all hammers
if mem:read_i8(0xc6A18) ~= 0 then
	mem:write_i8(0xc6A18, 0)    -- top
	mem:write_i8(0xc6680, 0)
	mem:write_i8(0xc6A1C, 0)    -- bottom
	mem:write_i8(0xc6690, 0)
	
	-- mem:write_i8(0xc6345, 0)  --forces hammers to become inactive
	-- mem:write_i8(0xc6350, 0)  --probably not needed
end