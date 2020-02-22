local cpath = tostring(...):gsub("%.[^%.]+", "")
local lg = love.graphics
local utils = require(cpath .. ".utils")
local class = utils.class
local loveChain = utils.loveChain

local _debugMouseTouch = false
local _debugTouchPoints = false or _debugMouseTouch
local _debugTouchRegions = false
local _debugTouchForceShow = false
local keys = {
  left = 'l',
  up = 'u',
  right = 'r',
  down = 'd',
  s = 'l',
  e = 'u',
  f = 'r',
  d = 'd',
  lalt = 'a',
  lctrl = 'b',
  space = 'c',
  z = 'a',
  x = 'b',
  c = 'c',
  j = 'a',
  k = 'b',
  l = 'c',
  ["return"] = 's',
}

local joyButtons = {
  [1] = 'a',
  [2] = 'b',
  [3] = 'c',
  [4] = 'a',
  [5] = 'b',
  [6] = 'c',
  [7] = 's',
  [8] = 's',
  [9] = 's',
  [10] = 's',
}

local Widget = class()

function Widget:init(config)
  for key, value in pairs(config) do
    self[key] = value
  end
  self:refresh()
end

function Widget:draw()
  local p = self.parent
  lg.push()
  lg.translate(self.offsetX, self.offsetY)
  lg.scale(p.guiScale, p.guiScale)
  lg.draw(self.img, self.quad)
  lg.pop()
  if _debugTouchRegions then
    lg.setColor(1,0,0)
    lg.rectangle('line', self.offsetX+0.5, self.offsetY+0.5, self.width, self.height)
    lg.setColor(1,1,1)
  end
end

function Widget:refresh()
  local pw, ph = self.img:getDimensions()
  local p = self.parent
  local s = p.guiScale
  local x, y = self.x * s, self.y * s
  self.quad = lg.newQuad(self.sx, self.sy, self.sw, self.sh, pw, ph)
  self.offsetX = x < 0 and p.guiWidth + x or x
  self.offsetY = y < 0 and p.guiHeight + y or y
  self.width = self.sw * s
  self.height = self.sh * s
end

function Widget:isHit(x, y)
  return x >= self.offsetX and
         y >= self.offsetY and
         x < self.offsetX + self.width and
         y < self.offsetY + self.height
end

function Widget:getButton()
  if self.button then
    return self.button
  end
end

function Widget:hitCoords(x, y)
  local s = self.parent.guiScale
  local dx, dy = (x - self.offsetX) / s, (y - self.offsetY) / s
  return dx, dy
end

local DpadWidget = class(Widget)

function DpadWidget:getButton(x, y)
  if not x then x = 0 end
  if not y then y = 0 end
  x = x - 16
  y = y - 16
  local d = math.sqrt(x*x+y*y)
  if d < 5 or d >= 16 then return end

  local r = math.pi / 8
  local a = math.atan2(y, x)
  local o = ""
  if a > r and a < r*7 then
    o = o .. 'd'
  end
  if a > r*5 or a < -r*5 then
    o = o .. 'l'
  end
  if a > -r*7 and a < -r then
    o = o .. 'u'
  end
  if a > -r*3 and a < r*3 then
    o = o .. 'r'
  end

  return o
end

local Input = class()

function Input:init()
  self.disableTouch = false
  self.usingTouch = false
  self.guiWidth = 1280
  self.guiHeight = 800
  self.guiScale = 2
  self.joyThreshold = 0.5
  self.buttons = {
    l = false,
    u = false,
    r = false,
    d = false,
    a = false,
    b = false,
    c = false,
    s = false,
  }
  self.buttonDebounces = {
    l = false,
    u = false,
    r = false,
    d = false,
    a = false,
    b = false,
    c = false,
    s = false,
  }
  self.img = nil
  self.qdpad = nil
  self.points = {
    top = 1,
  }
  self.widgets = nil

  loveChain(self, {
    'load', 'draw', 'resize',
    'keypressed', 'keyreleased',
    'touchpressed', 'touchreleased', 'touchmoved',
    'mousepressed', 'mousereleased', 'mousemoved',
    'joystickpressed', 'joystickreleased', 'joystickaxis', 'joystickhat',
  })

  self:resize()
end

function Input:load()
  self.img = lg.newImage(cpath .. "/assets/buttons.png")
  self.widgets = {
    DpadWidget{
      x = 4,
      y = -64,
      sx = 0,
      sy = 0,
      sw = 32,
      sh = 32,
      img = self.img,
      parent = self,
      update = true,
    },
    Widget{
      x = -40,
      y = -70,
      sx = 32,
      sy = 0,
      sw = 16,
      sh = 16,
      img = self.img,
      parent = self,
      button = 'a',
      combi = true,
    },
    Widget{
      x = -40,
      y = -50,
      sx = 48,
      sy = 0,
      sw = 16,
      sh = 16,
      img = self.img,
      parent = self,
      button = 'b',
      combi = true,
    },
    Widget{
      x = -20,
      y = -60,
      sx = 32,
      sy = 16,
      sw = 16,
      sh = 16,
      img = self.img,
      parent = self,
      button = 'c',
      combi = true,
    },
    Widget{
      x = -20,
      y = 16,
      sx = 48,
      sy = 16,
      sw = 16,
      sh = 8,
      img = self.img,
      parent = self,
      button = 's',
    },
  }
end

function Input:draw()
  if self.disableTouch then return end

  if not self.usingTouch and not _debugTouchForceShow then
    return
  end
  local wids = self.widgets
  for i=1, #wids do
    lg.setColor(1, 1, 1, 0.5)
    wids[i]:draw()
  end
  lg.setColor(1, 1, 1, 1)

  if _debugTouchPoints then
    self:drawTouches()
  end
  if _debugMouseTouch and self._dbgMouseX and self._dbgMouseY then
    self:drawTarget(self._dbgMouseX, self._dbgMouseY, {0, 0.3, 1})
  end
end

function Input:drawTarget(x, y, col)
  local r, g, b, a = nil
  if col then
    r, g, b, a = lg.getColor()
    lg.setColor(col)
  end
  lg.circle('line', x, y, 48)
  lg.line(x - 64, y, x + 64, y)
  lg.line(x, y - 64, x, y + 64)
  if col then
    lg.setColor(r, g, b, a)
  end
end

function Input:drawTouches()
  lg.push()
  for k, v in pairs(self.points) do
    if k ~= 'top' then
      self:drawTarget(v.x, v.y)
    end
  end
  lg.pop()
end

function Input:resize(w, h)
  if not (w or h) then
    w, h = lg.getDimensions()
  end
  self.guiWidth = w
  self.guiHeight = h
  self.guiScale = math.floor(math.min(w, h) / 120)
  if not self.widgets then return end
  for i=1, #self.widgets do
    self.widgets[i]:refresh()
  end
end

function Input:keypressed(key)
  for k, v in pairs(keys) do
    if key == k and not self.buttons[v] then
      self.buttons[v] = true
    end
  end
end

function Input:keyreleased(key)
  if self.usingTouch then self.usingTouch = false end

  if key == 'escape' then
    love.event.quit()
    return
  elseif key == 'f11' then
    if love.window.getFullscreen() then
      love.window.setFullscreen(false)
    else
      love.window.setFullscreen(true)
    end
    return
  end

  for k, v in pairs(keys) do
    if key == k and self.buttons[v] then
      self.buttons[v] = false
    end
  end
end

function Input:touchpressed(id, x, y)
  if self.disableTouch then return end

  if not self.usingTouch then
    self.usingTouch = true
  end
  local hit = nil
  for i=1, #self.widgets do
    local w = self.widgets[i]
    if w:isHit(x, y) then
      hit = w
    end
  end
  if not hit then return end
  local b = hit:getButton(hit:hitCoords(x, y))
  if not b then return end
  self:setButtons(b, true)
  local pts = self.points
  pts[id] = {
    id = pts.top,
    x = x,
    y = y,
    w = hit,
  }
  pts.top = pts.top + 1
end

function Input:touchreleased(id, x, y)
  if self.disableTouch then return end

  local p = self.points[id]
  if p then
    local b = p.w:getButton(p.w:hitCoords(x, y))
    if not b then b = "lurd" end
    self:setButtons(b, false)
  end
  self.points[id] = nil
end

function Input:touchmoved(id, x, y)
  if self.disableTouch then return end

  local p = self.points[id]
  if not p then return end
  p.x = x
  p.y = y
  if p.w.update then
    self:setButtons("lurd", false)
    local b = p.w:getButton(p.w:hitCoords(x, y))
    self:setButtons(b, true)
  end
end

function Input:mousepressed(x, y, b, t)
  if _debugMouseTouch and b == 1 and not t then
    self:touchpressed(1, x, y)
  end
end

function Input:mousereleased(x, y, b, t)
  if _debugMouseTouch and b == 1 and not t then
    self:touchreleased(1, x, y)
  end
end

function Input:mousemoved(x, y, t)
  self._dbgMouseX = x
  self._dbgMouseY = y
  if _debugMouseTouch and not t then
    self:touchmoved(1, x, y)
  end
end

function Input:joystickpressed(j, b)
  local joy = self:ensureJoystick(j)
  joy.buttons[b] = b
  local m = joyButtons[b]
  if m then
    self.buttons[m] = true
  end
end

function Input:joystickreleased(j, b)
  local joy = self:ensureJoystick(j)
  joy.buttons[b] = nil
  local m = joyButtons[b]
  if m then
    self.buttons[m] = false
  end
end

function Input:joystickaxis(j, a, v)
  local thr = self.joyThreshold
  function dealAxis(a, f, s)
    local btns = self.buttons
    if a < -thr then
      btns[f] = true
      btns[s] = false
    elseif a < thr then
      btns[f] = false
      btns[s] = false
    else
      btns[f] = false
      btns[s] = true
    end
  end
  local joy = self:ensureJoystick(j)
  joy.axis[a] = v
  if a == 1 then dealAxis(v, 'l', 'r') end
  if a == 2 then dealAxis(v, 'u', 'd') end
end

function Input:joystickhat(j, h, d)
  local joy = self:ensureJoystick(j)
  local oldHat = joy.hats[h]
  local btns = self.buttons
  joy.hats[h] = d
  if h == 1 then
    local dirs = "lurd"
    for i=1, #dirs do
      btns[dirs:sub(i, i)] = false
    end
    for i=1, #d do
      local v = d:sub(i, i)
      if v ~= 'c' then
        btns[v] = true
      end
    end
  end
end

function Input:ensureJoystick(j)
  if not self.joysticks then
    self.joysticks = {}
  end
  local joy = self.joysticks[j]
  if not joy then
    joy = {
      buttons = {},
      axis = {},
      hats = {},
    }
    self.joysticks[j] = joy
  end
  return joy
end

function Input:printButtonString(v)
  local l, u, r, d, a, b, c, s = nil
  local b = self.buttons
  if v then
    b = v
  end
  l = (b.l and 'L' or 'l')
  u = (b.u and 'U' or 'u')
  r = (b.r and 'R' or 'r')
  d = (b.d and 'D' or 'd')
  a = (b.a and 'A' or 'a')
  c = (b.c and 'C' or 'c')
  s = (b.s and 'S' or 's')
  b = (b.b and 'B' or 'b')
  return l..u..r..d..a..b..c..s
end

function Input:printJoystickStrings(x, y)
  if not self.joysticks then return 0 end
  local i = 0
  for joyId, joy in pairs(self.joysticks) do
    local joyName = joyId:getName()
    local o = joyName .. ": "
    local first = true
    for k, v in pairs(joy.axis) do
      if first then first = false else o = o .. ", " end
      o = o .. "a" .. k .. "(" .. tostring(v) .. ")"
    end

    for k, v in pairs(joy.hats) do
      if first then first = false else o = o .. ", " end
      o = o .. "h" .. k .. "(" .. tostring(v) .. ")"
    end

    if first then first = false else o = o .. ", " end
    o = o .. "b("
    first = true
    for k, _ in pairs(joy.buttons) do
      if first then first = false else o = o .. ", " end
      o = o .. k
    end
    o = o .. ")"
    lg.print(o, x, y + 16 * i)
    i = i + 1
  end
  return i
end

function Input:lgPrintButtons(x, y)
  if not x then x = 0 end
  if not y then y = 0 end
  local s = self:printButtonString()
  lg.print(s, x, y)
  s = self:printButtonString(self.buttonDebounces)
  lg.print(s, x, y+16)
  self:printJoystickStrings(x, y + 32)
end

function Input:setButtons(b, v)
  if not b then return end
  if not v then v = false end

  for i=1, #b do
    self.buttons[b:sub(i,i)] = v
  end
end

function Input:getButton(v, once)
  if once and self.buttons[v] then
    if self.buttonDebounces[v] then
      return false
    else
      self.buttonDebounces[v] = true
      return true
    end
  end
  if not self.buttons[v] then
    self.buttonDebounces[v] = false
  end
  return self.buttons[v]
end

return Input
