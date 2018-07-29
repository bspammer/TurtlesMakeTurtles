os.loadAPI("mining")
os.loadAPI("movement")
os.loadAPI("inventory")

local startPos = vector.new(gps.locate())
local targetAmount = 10
local targetOre = "redstone"
local oreLevels = {["coal"]=45, ["iron"]=40, ["gold"]=25, ["redstone"]=10, ["diamond"]=10}

movement.goToPosition(startPos.x, oreLevels[targetOre], startPos.z)
while inventory.itemAmount(targetOre) < targetAmount do
  mining.stripMine(50)
  turtle.turnRight()
  for i=1,5 do
    movement.safeForward()
    turtle.digUp()
  end
  turtle.turnLeft()
  inventory.compactInventory()
  inventory.cleanJunk(true)
  inventory.compactInventory()
end
movement.goToPosition(startPos.x, startPos.y, startPos.z)