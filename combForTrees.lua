local args = {...}
if tonumber(args[1]) == nil then
  print("Usage: combForTrees <length>")
end
local sideLength = tonumber(args[1])

for i=1,sideLength/2 do
  shell.run("pathfinding", "100", "true")
  turtle.turnLeft()
  shell.run("pathfinding", "1", "true")
  turtle.turnLeft()
  shell.run("pathfinding", "100", "true")
  turtle.turnRight()
  shell.run("pathfinding", "1", "true")
  turtle.turnRight()
end
