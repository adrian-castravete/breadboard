-- title:        Breadboard (fkge)
-- author:       Adrian Castravete (fkbm)
-- description:  Simple game engine over Löve2D for even faster prototyping

local cpath = ...
local lg = love.graphics
local utils = require(cpath .. ".utils")
local class = utils.class
local Input = require(cpath .. ".input")
local Cart = require(cpath .. ".cart")

local input = Input()

local _debug = false
local Breadboard = class()

local env = {
  frame = function () end,
  class = class,
}

function Breadboard:init()
  self.state = "running"
  self.screenSize = 240
  self.width = 1280
  self.height = 800
  self.zoom = 2
  self.offsetX = 0
  self.offsetY = 0
  self.runtime = {
    screenSize = self.screenSize,
    input = input,
    drawBegin = function ()
      self:drawBegin()
    end,
    drawEnd = function ()
      self:drawEnd()
    end,
    getViewportInfo = function ()
      return {
        originX = self.offsetX,
        originY = self.offsetY,
        width = self.width,
        height = self.height,
        zoom = self.zoom,
      }
    end,
    bgCvs = lg.newCanvas(self.width, self.height),
  }

  self._animations = {}
end

function Breadboard:load()
  if not env.showMouse then
    love.mouse.setVisible(false)
  end
  lg.setDefaultFilter("nearest", "nearest")
  self:onResize()
end

function Breadboard:safeCall(...)
  local values = {pcall(...)}
  local ok = values[1]
  if ok then
    table.remove(values, 1)
    return unpack(values)
  else
    self:setError(values[2])
  end
end

function Breadboard:update(dt)
  if self.state == "running" then
    self:safeCall(env.frame, dt)
    self:cycleAnimations(dt)
  end
end

function Breadboard:draw()
  --lg.clear(2/7, 5/7, 1)
  lg.clear()
  if self.state == "fatalError" then
    self:drawError()
    return
  end
  lg.setColor(1, 1, 1)
  lg.draw(self.runtime.bgCvs)
  if _debug and input then
    input.lovePrintButtons()
  end
end

function Breadboard:drawBegin()
  lg.push()
  lg.translate(self.offsetX, self.offsetY)
  lg.scale(self.zoom, self.zoom)
end

function Breadboard:drawEnd()
  lg.pop()
end

function Breadboard:drawError()
  lg.setFont(self._errorFont)
  lg.print(self.errorMessage, self._errorOffsetX, self._errorOffsetY)
end

function Breadboard:resize(w, h)
  self:onResize(w, h)
end

function Breadboard:onResize(w, h)
  if not (w or h) then
    w, h = lg.getDimensions()
  end
  if w ~= self.width or h ~= self.height then
    self.runtime.bgCvs = lg.newCanvas(w, h)
  end
  self.width = w
  self.height = h
  self.zoom = math.floor(math.min(w, h) / self.screenSize)
  local size = self.zoom * self.screenSize
  if w > h then
    self.offsetY = (h - size) / 2
    self.offsetX = self.offsetY + (w - h) / 2
  else
    self.offsetX = (w - size) / 2
    self.offsetY = self.offsetX
  end
end

function Breadboard:setError(text)
  local font = lg.newFont(self.height / 32)
  local ew = font:getWidth(text)
  local eh = font:getHeight()
  local w, h = lg.getDimensions()

  self._errorOffsetX = (w - ew) * 0.5
  self._errorOffsetY = (h - eh) * 0.5
  self._errorFont = font
  self.state = "fatalError"
  self.errorMessage = text
end

function Breadboard:createAnimation(delay, fnProgress, fnDone)
  local co = coroutine.create(function (delay)
    local v = 0
    while v < delay do
      self:safeCall(fnProgress, v / delay)
      v = v + coroutine.yield()
    end
    self:safeCall(fnProgress, 1)
    if fnDone then
      self:safeCall(fnDone)
    end
  end)
  coroutine.resume(co, delay / 1000)
  table.insert(self._animations, co)
end

function Breadboard:cycleAnimations(dt)
  local anims = self._animations
  local nanims = {}
  for i=1, #anims do
    local co = anims[i]
    if coroutine.resume(co, dt)  then
      nanims[#nanims+1] = co
    end
  end
  self._animations = nanims
end

main = Breadboard()
utils.loveChain(main, {'load', 'update', 'draw', 'resize'})

function prettyPrintString(data, indent)
  function prettyIndent(indent)
    local o = ""
    for i=1, indent do
      o = o .. "  "
    end
    return o
  end

  if not indent then
    indent = 0
  end

  local o = ""
  tdata = type(data)
  if tdata == "table" then
    o = o .. "{\n"
    indent = indent + 1
    for k, v in pairs(data) do
      o = o .. prettyIndent(indent)
      if type(k) ~= "string" then
        k = "[" .. k .. "]"
      end
      o = o .. k .. " = "
      o = o .. prettyPrintString(v, indent)
    end
    indent = indent - 1
    o = o .. prettyIndent(indent)
    if indent > 0 then
      o = o .. "},\n"
    else
      o = o .. "}\n"
    end
  elseif tdata == "function" then
    o = o .. "<function>,\n"
  elseif tdata == "string" then
    o = o .. '"' .. data .. '",\n'
  elseif tdata == "number" or tdata == "boolean" then
    o = o .. tostring(data) .. ",\n"
  else
    o = o .. "?" .. tdata .. "?,\n"
  end

  return o
end

function printAny(v)
  print(prettyPrintString(v))
  io.flush()
end

function lgPrintTable(tab)
  local tabo = prettyPrintString(tab)
  local i = 0
  for line in tabo:gmatch("[^\n]+") do
    local line = line:gsub("%s+$", "")
    if line then
      i = i + 1
      lg.print(line, 0, i*16)
    end
  end
end

local cart = Cart(main.runtime)

function _attachMethodsToTable(conf, tblIn, tblOut)
  local o = tblOut or {}

  for key, value in pairs(conf) do
    o[key] = function(...)
      return tblIn[value](tblIn, ...)
    end
  end

  return o
end

function env.config(options)
  if not options or type(options) ~= 'table' then
    return
  end
  if options.disableTouch and input then
    input.disableTouch = true
  end
  if options.showMouse then
    env.showMouse = true
  end
end

function env.viewport()
  return {
    offsetX = main.offsetX,
    offsetY = main.offsetY,
    width = main.width,
    height = main.height,
    zoom = main.zoom,
  }
end

function env.animate(delay, fnProgress, fnDone)
  main:createAnimation(delay, fnProgress, fnDone)
end

function env.lerp(a, b, r)
  return a + (b - a) * r
end

function env.screenSize(v)
  main.screenSize = v
  main.runtime.screenSize = v
  main:onResize()
end

return _attachMethodsToTable({
  clearScreen = "clearScreen",      -- clear the screen
  draw = "drawMap",                 -- draw from tilemap to screen
  tile = "tileDraw",                -- draw to the tilemap
  tileClear = "tileClear",          -- clear on the tilemap
  makeTileset = "loadTileset",      -- load a tileset from file
  listTilesets = "listTilesets",    -- list tilesets
  removeTileset = "removeTileset",  -- remove a loaded tileset
  button = "button",                -- check button press
  buttonPressed = "buttonPressed",  -- check button press in “this” frame
  -- debug
  printXY = "print",                -- print text on screen
  tileDump = "tileDump",            -- exports an image with the current tilemap
}, cart, env)
