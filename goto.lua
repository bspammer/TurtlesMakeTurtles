local tArgs = {...}
if #tArgs ~= 4 then
  print("Usage: goto <x> <y> <z> <direction>")
  exit()
end

local x = tonumber(tArgs[1])
local y = tonumber(tArgs[2])
local z = tonumber(tArgs[3])
local dir = tonumber(tArgs[4])
os.loadAPI("movement")
movement.goToPosition(x,y,z,dir)
