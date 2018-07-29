POSX = 0
POSZ = 1
NEGX = 2
NEGZ = 3
POSY = 4
NEGY = 5
leftOf = {[POSX]=NEGZ, [POSZ]=POSX, [NEGX]=POSZ, [NEGZ]=NEGX}
rightOf = {[POSX]=POSZ, [POSZ]=NEGX, [NEGX]=NEGZ, [NEGZ]=POSX}

function halfSpin()
  turtle.turnLeft()
  turtle.turnLeft()
end

function safeForward()
  while not turtle.forward() do
    turtle.dig()
  end
end

function safeBack()
  if not turtle.back() then
    halfSpin()
    safeForward()
    halfSpin()
  end
end

function safeUp()
  while not turtle.up() do
    turtle.digUp()
  end
end

function safeDown()
  while not turtle.down() do
    turtle.digDown()
  end
end

function getFacing(shouldBreakBlocks)
  shouldBreakBlocks = shouldBreakBlocks or false

  if turtle.detect() and not shouldBreakBlocks then
    -- try to find a free direction to move in
    turtle.turnLeft()
    if not turtle.detect() then
      local dir = rightOf[getFacing(false)]
      turtle.turnRight()
      return dir
    end

    turtle.turnLeft()
    if not turtle.detect() then
      local dir = rightOf[rightOf[getFacing(false)]]
      halfSpin()
      return dir
    end

    turtle.turnLeft()
    if not turtle.detect() then
      local dir = leftOf[getFacing(false)]
      turtle.turnLeft()
      return dir
    end
    error("Not allowed to break blocks and no free space to get direction")
  end

  local curPos = vector.new(gps.locate())
  safeForward()
  local offsetPos = vector.new(gps.locate())
  safeBack()
  local diffPos = offsetPos - curPos
  if diffPos.x > 0 then
    return POSX
  elseif diffPos.x < 0 then
    return NEGX
  elseif diffPos.z > 0 then
    return POSZ
  elseif diffPos.z < 0 then
    return NEGZ
  else
    --something went wrong
    error("I don't know which direction I'm facing :(")
  end
end

function setFacing(goal, current)
  --finds current facing direction if none supplied
  current = current or getFacing(true)

  if current == goal then
    return goal
  elseif leftOf[current] == goal then
    turtle.turnLeft()
    return goal
  elseif rightOf[current] == goal then
    turtle.turnRight()
    return goal
  else
    halfSpin()
    return goal
  end
end

function goToPosition(goalX, goalY, goalZ, facing)
  facing = facing or getFacing(true)
  local myPos = vector.new(gps.locate())

  if myPos.x < goalX then
    facing = setFacing(POSX, facing)
  elseif myPos.x > goalX then
    facing = setFacing(NEGX, facing)
  end
  for i=1,math.abs(myPos.x-goalX) do
    safeForward()
  end

  if myPos.z < goalZ then
    facing = setFacing(POSZ, facing)
  elseif myPos.z > goalZ then
    facing = setFacing(NEGZ, facing)
  end
  for i=1,math.abs(myPos.z-goalZ) do
    safeForward()
  end

  if myPos.y < goalY then
    for i=1,goalY-myPos.y do
      safeUp()
    end
  elseif myPos.y > goalY then
    for i=1,myPos.y-goalY do
      safeDown()
    end
  end
  
  local finalPos = vector.new(gps.locate())
  if finalPos.x == goalX and finalPos.y == goalY and finalPos.z == goalZ then
    return true
  else
    return false
  end
end