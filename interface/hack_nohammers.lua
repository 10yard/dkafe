-- DKAFE No hammers hack by Jon Wilson
------------------------------------------------------------------------

-- Clear all hammers
------------------------------------------------------------------------
if mem:read_i8(0xc6A18) ~= 0 then
  for k, v in pairs({0xc6A18, 0xc6680, 0xc6A1C, 0xc6690}) do
    mem:write_i8(v, 0)
  end
end