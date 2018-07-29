craftingRecipes = {
  ["crafting_table"]={
    totals={
      ["planks"]=4
    },
    recipe={
      "planks", "planks", nil,
      "planks", "planks", nil,
      nil     , nil     , nil
    }
  },
  ["stick"]={
    totals={
      ["planks"]=2
    },
    recipe={
      "planks", nil, nil,
      "planks", nil, nil,
      nil     , nil, nil
    }
  },
  ["chest"]={
    totals={
      ["planks"]=8
    },
    recipe={
      "planks", "planks", "planks",
      "planks", nil     , "planks",
      "planks", "planks", "planks"
    }
  },
  ["CC-Computer"]={
    totals={
      ["stone"]=7,
      ["redstone"]=1,
      ["glass_pane"]=1
    },
    recipe={
      "stone", "stone"     , "stone",
      "stone", "redstone"  , "stone",
      "stone", "glass_pane", "stone"
    }
  },
  ["furnace"]={
    totals={
      ["cobblestone"]=8
    },
    recipe={
      "cobblestone", "cobblestone", "cobblestone",
      "cobblestone", nil          , "cobblestone",
      "cobblestone", "cobblestone", "cobblestone"
    }
  },
  ["glass_pane"]={
    totals={
      ["glass"]=6
    },
    recipe={
      "glass", "glass", "glass",
      "glass", "glass", "glass",
      nil    , nil    , nil
    }
  },
  ["CC-Turtle"]={
    totals={
      ["iron_ingot"]=7,
      ["CC-Computer"]=1,
      ["chest"]=1
    },
    recipe={
      "iron_ingot", "iron_ingot" , "iron_ingot",
      "iron_ingot", "CC-Computer", "iron_ingot",
      "iron_ingot", "chest"      , "iron_ingot"
    }
  },
  ["iron_block"]={
    totals={
      ["iron_ingot"]=9
    },
    recipe={
      "iron_ingot", "iron_ingot", "iron_ingot",
      "iron_ingot", "iron_ingot", "iron_ingot",
      "iron_ingot", "iron_ingot", "iron_ingot"
    }
  }
}

recipeToInventorySlot = {1,2,3,5,6,7,9,10,11}

function stripName(nameToStrip)
  local position = string.find(nameToStrip, ":")
  if position == nil then
    return nil
  end
  return string.sub(nameToStrip, position+1)
end

function matchItem(itemString, slot)
  slot = slot or turtle.getSelectedSlot()
  local data = turtle.getItemDetail(slot)
  if data == nil then
    return false
  end
  local strippedName = stripName(data.name)
  return itemString == strippedName
end

function findEmptySlot()
  for i=1,16 do
    if turtle.getItemCount(i) == 0 then
      return true, i
    end
  end
  return false, nil
end

function findItem(itemString, selectSlot, startFrom)
  selectSlot = selectSlot or false
  startFrom = startFrom or 1
  for i=startFrom,16 do
    if matchItem(itemString, i) then
      if selectSlot then turtle.select(i) end
      return true, i
    end
  end
  return false, nil
end

function findAndRefuel()
  local success, _ = findItem("coal", true)
  if success then
    turtle.refuel()
    return true
  else
    return false
  end
end

function swapItems(slot1, slot2)
  local startSlot = turtle.getSelectedSlot()

  local success, emptySlot = findEmptySlot()
  if not success then
    return false
  end

  turtle.select(slot1)
  turtle.transferTo(emptySlot)
  turtle.select(slot2)
  turtle.transferTo(slot1)
  turtle.select(emptySlot)
  turtle.transferTo(slot2)
  turtle.select(startSlot)
  return true
end

function itemAmount(itemString)
  local total = 0
  for i=1,16 do
    if matchItem(itemString, i) then
      total = total + turtle.getItemCount(i)
    end
  end
  return total
end

function getItemName(slot)
  local data = turtle.getItemDetail(slot)
  if data == nil then
    return nil
  end
  return stripName(data.name)
end

function compactInventory()
  --combine items
  for i=1,16 do
    if turtle.getItemCount(i) ~= 0 and turtle.getItemSpace(i) ~= 0 then
      local currentName = getItemName(i)
      if currentName == nil then error("This shouldn't happen") end
      for j=i+1,16 do
        if getItemName(j) == currentName and turtle.getItemSpace(j) ~= 0 then
          turtle.select(j)
          turtle.transferTo(i)
        end
      end
    end
  end
  -- remove gaps
  for i=1,16 do
    -- start from the end
    local slot = 16-i+1
    local success, emptySlot = findEmptySlot()
    if success then
      if emptySlot < slot and turtle.getItemCount(slot) ~= 0 then
        turtle.select(slot)
        turtle.transferTo(emptySlot)
      end
    else
      break
    end
  end
  turtle.select(1)
  return true
end

function cleanJunk(digHole, keepOneStack)
  digHole = digHole or false
  keepOneStack = keepOneStack or false

  if digHole then
    for i=1,2 do
      while not turtle.down() do turtle.digDown() end
    end
    while not turtle.up() do turtle.digUp() end
    while turtle.detect() do turtle.dig() end
  end

  local junkList = {"cobblestone", "stone", "dirt", "gravel", "sand"}
  for i=1,16 do
    local data = turtle.getItemDetail(i)
    if data ~= nil then
      local name = stripName(data.name)
      for _,junk in pairs(junkList) do
        if name == junk then
          local amount = itemAmount(name)
          local maxStack = turtle.getItemCount(i) + turtle.getItemSpace(i)
          if not keepOneStack or amount >= maxStack*2 or (amount > maxStack and turtle.getItemSpace(i) ~= 0) then
            turtle.select(i)
            turtle.dropDown()
          end
        end
      end
    end
  end

  if digHole then
    local success, slot = findItem("cobblestone")
    if success then
      turtle.select(slot)
      turtle.place()
      turtle.up()
      turtle.placeDown()
    else
      turtle.up()
    end
  end
end

function toggleCrafting()
  if findItem("diamond_pickaxe", true) or findItem("crafting_table", true) then
    return turtle.equipLeft()
  else
    return false
  end
end

function craftItem(itemName)
  if craftingRecipes[itemName] == nil then return false, "No recipe for that item." end

  for i=1,16 do
    if not (turtle.getItemCount(i) == 0) then
      return false, "Inventory must be empty to craft an item."
    end
  end

  local suckDropTable = {}
  if turtle.suckUp() then
    turtle.dropUp()
    suckDropTable = {suck=turtle.suckUp, drop=turtle.dropDown}
  else
    suckDropTable = {suck=turtle.suckDown, drop=turtle.dropUp}
  end

  local recipe = craftingRecipes[itemName]
  local emptySlot = 16
  turtle.select(1)
  while suckDropTable.suck() do
    local data = turtle.getItemDetail(1)
    local name = stripName(data.name)
    local currentAmount = itemAmount(name) - turtle.getItemCount(1)
    local success, slot = findItem(name, false, 2)
    for k,v in pairs(recipe.totals) do
      if k == name and currentAmount < v then
        if success then 
          turtle.transferTo(slot)
        else
          turtle.transferTo(emptySlot)
          emptySlot = emptySlot - 1
        end
        break
      end
    end
    suckDropTable.drop()
  end

  for i=emptySlot+1,16 do
    local data = turtle.getItemDetail(i)
    local name = stripName(data.name)
    if recipe.totals[name] < data.count then
      turtle.select(i)
      suckDropTable.drop(data.count - recipe.totals[name])
    end
  end

  for i=emptySlot+1,16 do
    local data = turtle.getItemDetail(i)
    local name = stripName(data.name)
    for j=1,9 do
      if name == recipe.recipe[j] then
        turtle.select(i)
        turtle.transferTo(recipeToInventorySlot[j],1)
      end
    end
  end

  return turtle.craft()
end