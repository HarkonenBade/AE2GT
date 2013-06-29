--[[
//=================================================
//Applied Energistics to Gregtech Recipe Interface.
//=================================================
Interface script to make using AE autocrafting with GT machines easier.
 
//================
//Licence
//================
The MIT License (MIT)
 
Copyright (c) 2013 Thomas Bytheway
 
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
 
The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.
 
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]
 
local tArgs = {...};
local recipes = {};
local dropDir = "";
local globalSleep = 0;
 
local function printUsage()
  print("Usages:")
  print("AE2GT recipe_file")
end
 
if #tArgs < 1 then
  printUsage()
  return
end
 
local function drop(cell, qty)
  turtle.select(cell);
  if dropDir == "UP" then
    return turtle.dropUp(qty)
  elseif dropDir == "FWD" then
    return turtle.drop(qty)
  elseif dropDir == "DOWN" then
    return turtle.dropDown(qty)
  else
    print("ERROR: Drop direction invalid, must be one of FWD, UP or DOWN.")
    return false
  end
end
 
local function checkRecipe(ident)
  local recipe = recipes[ident];
  local invalid = false;
  for i=1,4 do
    local cell = (ident-1)*4 + i;
    if recipe[i] > 0 then
	    if turtle.getItemCount(cell) <= recipe[i] then
        invalid = true;
      end
    end
  end
  if not invalid then
    for i=1,4 do
      local cell = (ident-1)*4 + i;
      if recipe[i] > 0 then
        drop(cell, recipe[i]);
      end
    end
    if recipe[5] > 0 then
      sleep(recipe[5]);
    end
  end
end
 
local function loadConfig(name)
  local f = fs.open(name, "r");
  dropDir = f.readLine();
  print("DropDir:"..dropDir);
  globalSleep = tonumber(f.readLine());
  print("GlobalSleep:"..tostring(globalSleep));
  for lineCount=1,4 do
    local line = f.readLine();
    if line == nil then
      print("No recipe "..tostring(lineCount).." found.")
      recipes[lineCount] = -1;
    else
      print("Loading recipe "..tostring(lineCount))
      local recipe = {};
      local count = 1;
      for k in string.gmatch(line, "[^%s]+") do
        print("Adding ingredient "..tostring(count).." quantity "..k);
        recipe[count] = tonumber(k);
        count = count + 1;
      end
      recipes[lineCount] = recipe;
    end
  end    
end
 
local function main()
  loadConfig(tArgs[1]);
  while true do
    for i=1,4 do
      if recipes[i] ~= -1 then
        checkRecipe(i);
      end
    end
    sleep(globalSleep);
  end
end

main()