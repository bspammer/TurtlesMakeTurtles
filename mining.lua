function stripName(nameToStrip)
  local position = string.find(nameToStrip, ":")
  if position == nil then
    return nil
  end
  return string.sub(nameToStrip, position+1)
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

function halfSpin()
  turtle.turnLeft()
  turtle.turnLeft()
end

function digTunnel(length)
  if length < 1 then
    error("Can't dig a tunnel that length")
  end

  for i=1,length do
    safeForward()
    turtle.digUp()
  end
end

function stripMine(length)
  digTunnel(length)
  halfSpin()
  digTunnel(length)
  halfSpin()
end

function matchBlock(blockString)
  local success, data = turtle.inspect()
  if not success then
    return false
  end
  local strippedName = stripName(data.name)
  return blockString == strippedName
end

function digTree()
  safeForward()
  local success, data = turtle.inspectUp()
  local count = 0
  if success then
    while stripName(data.name) == "log" or stripName(data.name) == "log2" do
      safeUp()
      count = count + 1
      success, data = turtle.inspectUp()
      if not success then break end
    end
  end
  for i=1,count do
    safeDown()
  end
  safeBack()
  return true
end