-- Traverses all terrain. Will scale any obstacle, impossible to stop without using the height limit or surrounding it with blocks.

local args = {...}
local distanceToTravel
local findTrees

if #args < 1 or #args > 2 or tonumber(args[1]) == nil then
  print("Usage: pathfinding <distance> [break trees: true | false]")
  return
else
  args[2] = string.lower(args[2] or "false")
  findTrees = args[2] == "true"
  distanceToTravel = tonumber(args[1])
end

os.loadAPI("mining")

down = function() if not turtle.detectDown() then return turtle.down() else return false end end
up = function() if not turtle.detectUp() then return turtle.up() else return false end end
forward = function() if turtle.forward() then distanceToTravel = distanceToTravel - 1 return true else return false end end
back = function() if turtle.back() then distanceToTravel = distanceToTravel + 1 return true else return false end end

local directionCycle = {[down]=forward, [forward]=up, [up]=back, [back]=down}

local modeZero = {mainAction=down, backupAction=forward, nextMode=nil, prevMode=nil, id=0}

local mode = modeZero
local oneMainActionComplete = false

while true do
  if distanceToTravel == 0 then
    while turtle.down() do end
    break
  end
  
  if mode.nextMode == nil then
    -- Generate a new mode
    mode.nextMode = {mainAction=mode.backupAction, backupAction=directionCycle[mode.backupAction], nextMode=nil, prevMode=mode, id=mode.id+1}
  end

  -- dig dem trees
  if findTrees then
    if mining.matchBlock("log") or mining.matchBlock("log2") then
      mining.digTree()
    end
  end

  if mode.id == 0 then
    if not mode.mainAction() then
      if not mode.backupAction() then
        mode = mode.nextMode
      end
    end
  else
    if oneMainActionComplete then
      oneMainActionComplete = false
      if mode.mainAction() then
        -- two mainActions in a row mean we should go back to the previous mode
        mode.nextMode = nil
        mode = mode.prevMode
      elseif not mode.backupAction() then
        mode = mode.nextMode
      end
    else
      if mode.mainAction() then
        oneMainActionComplete = true
      elseif not mode.backupAction() then
        mode = mode.nextMode
      end
    end
  end
end

return