local cpath = tostring(...):gsub("%.[^%.]+", '')
local lg = love.graphics
local utils = require(tostring(cpath) .. ".utils")
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
  ["return"] = 's'
}
local joyButtons = {
  'a',
  'b',
  'c',
  'a',
  'b',
  'c',
  's',
  's',
  's',
  's'
}
local Widget
do
  local _class_0
  local _base_0 = {
    draw = function(self)
      local p = self.parent
      lg.push()
      lg.translate(self.offsetX, self.offsetY)
      lg.scale(p.guiScale, p.guiScale)
      lg.draw(self.img, self.quad)
      lg.pop()
      if _debugTouchRegions then
        lg.setColor(1, 0, 0)
        lg.rectangle('line', self.offsetX + 0.5, self.offsetY + 0.5, self.width, self.height)
        return lg.setColor(1, 1, 1)
      end
    end,
    refresh = function(self)
      local pw, ph = self.img:getDimensions()
      local p = self.parent
      local s = p.guiScale
      local x, y = self.x * s, self.y * s
      self.quad = lg.newQuad(self.sx, self.sy, self.sw, self.sh, pw, ph)
      if x < 0 then
        self.offsetX = p.guiWidth + x
      else
        self.offsetX = x
      end
      if y < 0 then
        self.offsetY = p.guiHeight + y
      else
        self.offsetY = y
      end
      self.width = self.sw * s
      self.height = self.sh * s
    end,
    isHit = function(self, x, y)
      return x >= self.offsetX and y >= self.offsetY and x < self.offsetX + self.width and y < self.offsetY + self.height
    end,
    getButton = function(self)
      if self.button then
        return self.button
      else
        return nil
      end
    end,
    hitCoords = function(self, x, y)
      local s = self.parent.guiScale
      return (x - self.offsetX) / s, (y - self.offsetY) / s
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, config)
      for k, v in pairs(config) do
        self[k] = v
      end
      return self:refresh()
    end,
    __base = _base_0,
    __name = "Widget"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Widget = _class_0
end
local DpadWidget
do
  local _class_0
  local _parent_0 = Widget
  local _base_0 = {
    getButton = function(self, x, y)
      if not x then
        x = 0
      end
      if not y then
        y = 0
      end
      x = x - 16
      y = y - 16
      local d = math.sqrt(x * x + y * y)
      if d < 5 or d >= 16 then
        return 
      end
      local r = math.pi / 8
      local a = math.atan2(y, x)
      local o = ''
      if a > r and a < r * 7 then
        o = tostring(o) .. "d"
      end
      if a > r * 5 or a < -r * 5 then
        o = tostring(o) .. "l"
      end
      if a > -r * 7 and a < -r then
        o = tostring(o) .. "u"
      end
      if a > -r * 3 and a < r * 3 then
        o = tostring(o) .. "r"
      end
      return o
    end
  }
  _base_0.__index = _base_0
  setmetatable(_base_0, _parent_0.__base)
  _class_0 = setmetatable({
    __init = function(self, ...)
      return _class_0.__parent.__init(self, ...)
    end,
    __base = _base_0,
    __name = "DpadWidget",
    __parent = _parent_0
  }, {
    __index = function(cls, name)
      local val = rawget(_base_0, name)
      if val == nil then
        local parent = rawget(cls, "__parent")
        if parent then
          return parent[name]
        end
      else
        return val
      end
    end,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  if _parent_0.__inherited then
    _parent_0.__inherited(_parent_0, _class_0)
  end
  DpadWidget = _class_0
end
do
  local _class_0
  local _base_0 = {
    load = function(self)
      self.img = lg.newImage(tostring(cpath) .. "/assets/buttons.png")
      self.widgets = {
        DpadWidget({
          x = 4,
          y = -64,
          sx = 0,
          sy = 0,
          sw = 32,
          sh = 32,
          img = self.img,
          parent = self,
          update = true
        }),
        Widget({
          x = -40,
          y = -70,
          sx = 32,
          sy = 0,
          sw = 16,
          sh = 16,
          img = self.img,
          parent = self,
          button = 'a',
          combi = true
        }),
        Widget({
          x = -40,
          y = -50,
          sx = 48,
          sy = 0,
          sw = 16,
          sh = 16,
          img = self.img,
          parent = self,
          button = 'b',
          combi = true
        }),
        Widget({
          x = -20,
          y = -60,
          sx = 32,
          sy = 16,
          sw = 16,
          sh = 16,
          img = self.img,
          parent = self,
          button = 'c',
          combi = true
        }),
        Widget({
          x = -20,
          y = 16,
          sx = 48,
          sy = 16,
          sw = 16,
          sh = 8,
          img = self.img,
          parent = self,
          button = 's'
        })
      }
    end,
    draw = function(self)
      if self.disableTouch then
        return nil
      end
      if not self.usingTouch and not _debugTouchForceShow then
        return nil
      end
      local wids = self.widgets
      for i = 1, #wids do
        lg.setColor(1, 1, 1, 0.5)
        wids[i]:draw()
      end
      lg.setColor(1, 1, 1, 1)
      if _debugTouchPoints then
        self:drawTouches()
      end
      if _debugMouseTouch and self._dbgMouseX and self._dbgMouseY then
        return self:drawTarget(self._dbgMouseX, self._dbgMouseY, {
          0,
          0.3,
          1
        })
      end
    end,
    drawTarget = function(self, x, y, col)
      local r, g, b, a = nil
      if col then
        r, g, b, a = lg.getColor()
        lg.setColor(col)
      end
      lg.circle('line', x, y, 48)
      lg.line(x - 64, y, x + 64, y)
      lg.line(x, y - 64, x, y + 64)
      if col then
        return lg.setColor(r, g, b, a)
      end
    end,
    drawTouches = function(self)
      lg.push()
      for k, v in pairs(self.points) do
        if k ~= 'top' then
          self:drawTarget(v.x, v.y)
        end
      end
      return lg.pop()
    end,
    resize = function(self, w, h)
      if not (w or h) then
        w, h = lg.getDimensions()
      end
      self.guiWidth = w
      self.guiHeight = h
      self.guiScale = math.floor(math.min(w, h) / 120)
      if not self.widgets then
        return nil
      end
      for i = 1, #self.widgets do
        self.widgets[i]:refresh()
      end
    end,
    keypressed = function(self, key)
      for k, v in pairs(keys) do
        if key == k and not self.buttons[v] then
          self.buttons[v] = true
        end
      end
    end,
    keyreleased = function(self, key)
      if self.usingTouch then
        self.usingTouch = false
      end
      if key == 'escape' then
        love.event.quit()
      elseif key == 'f11' then
        if love.window.getFullscreen() then
          love.window.setFullscreen(false)
        else
          love.window.setFullscreen(true)
        end
        return nil
      end
      for k, v in pairs(keys) do
        if key == k and self.buttons[v] then
          self.buttons[v] = false
        end
      end
    end,
    touchpressed = function(self, id, x, y)
      if self.disableTouch then
        return nil
      end
      if not self.usingTouch then
        self.usingTouch = true
      end
      local hit = nil
      for i = 1, #self.widgets do
        local w = self.widgets[i]
        if w:isHit(x, y) then
          hit = w
        end
      end
      if not hit then
        return nil
      end
      local b = hit:getButton(hit:hitCoords(x, y))
      if not b then
        return nil
      end
      self:setButtons(b, true)
      local pts = self.points
      pts[id] = {
        id = pts.top,
        x = x,
        y = y,
        w = hit
      }
      pts.top = pts.top + 1
    end,
    touchreleased = function(self, id, x, y)
      if self.disableTouch then
        return nil
      end
      local p = self.points[id]
      if p then
        local b = p.w:getButton(p.w:hitCoords(x, y))
        if not b then
          b = 'lurd'
        end
        self:setButtons(b, false)
      end
      self.points[id] = nil
    end,
    touchmoved = function(self, id, x, y)
      if self.disableTouch then
        return nil
      end
      local p = self.points[id]
      if not p then
        return nil
      end
      p.x = x
      p.y = y
      if p.w.update then
        self:setButtons('lurd', false)
        local b = p.w:getButtons(p.w:hitCoords(x, y))
        return self:setButtons(b, true)
      end
    end,
    mousepressed = function(self, x, y, b, t)
      if _debugMouseTouch and b == 1 and not t then
        return self:touchpressed(1, x, y)
      end
    end,
    mousereleased = function(self, x, y, b, t)
      if _debugMouseTouch and b == 1 and not t then
        return self:touchreleased(1, x, y)
      end
    end,
    mousemoved = function(self, x, y, t)
      self._dbgMouseX = x
      self._dbgMouseY = y
      if _debugMouseTouch and not t then
        return self:touchmoved(1, x, y)
      end
    end,
    joystickpressed = function(self, j, b)
      local joy = self:ensureJoystick(j)
      joy.buttons[b] = b
      local m = joyButtons[b]
      if m then
        self.buttons[m] = true
      end
    end,
    joystickreleased = function(self, j, b)
      local joy = self:ensureJoystick(j)
      joy.buttons[b] = nil
      local m = joyButtons[b]
      if m then
        self.buttons[m] = false
      end
    end,
    joystickaxis = function(self, j, a, v)
      local thr = self.joyThreshold
      local btns = self.buttons
      local dealAxis
      dealAxis = function(self, a, f, s)
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
      if a == 1 then
        dealAxis(v, 'l', 'r')
      end
      if a == 2 then
        return dealAxis(v, 'u', 'd')
      end
    end,
    joystickhat = function(self, j, h, d)
      local joy = self:ensureJoystick(j)
      local oldHat = joy.hats[h]
      local btns = self.buttons
      joy.hats[h] = d
      if h == 1 then
        local dirs = 'lurd'
        for i = 1, #dirs do
          btns[dirs:sub(i, i)] = false
        end
        for i = 1, #d do
          local v = d:sub(i, i)
          if v ~= 'c' then
            btns[v] = true
          end
        end
      end
    end,
    ensureJoystick = function(self, j)
      if not self.joysticks then
        self.joysticks = { }
      end
      local joy = self.joysticks[j]
      if not joy then
        joy = {
          buttons = { },
          axis = { },
          hats = { }
        }
        self.joysticks[j] = joy
      end
      return joy
    end,
    printButtonString = function(self, v)
      local l, u, r, d, a, b, c, s = nil
      b = self.buttons
      if v then
        b = v
      end
      if b.l then
        l = 'L'
      else
        l = 'l'
      end
      if b.u then
        u = 'U'
      else
        u = 'u'
      end
      if b.r then
        r = 'R'
      else
        r = 'r'
      end
      if b.d then
        d = 'D'
      else
        d = 'd'
      end
      if b.a then
        a = 'A'
      else
        a = 'a'
      end
      if b.c then
        c = 'C'
      else
        c = 'c'
      end
      if b.s then
        s = 'S'
      else
        s = 's'
      end
      if b.b then
        b = 'B'
      else
        b = 'b'
      end
      return tostring(l) .. tostring(u) .. tostring(r) .. tostring(d) .. tostring(a) .. tostring(b) .. tostring(c) .. tostring(s)
    end,
    printJoystickStrings = function(self, x, y)
      if not self.joysticks then
        return 0
      end
      local i = 0
      for joyId, joy in pairs(self.joysticks) do
        local joyName = joyId:getName()
        local o = tostring(joyName) .. ": "
        local first = true
        local comma
        comma = function(self)
          if first then
            first = false
          else
            o = tostring(o) .. ", "
          end
        end
        for k, v in pairs(joy.axis) do
          comma()
          o = tostring(o) .. "a" .. tostring(k) .. "(" .. tostring(v) .. ")"
        end
        for k, v in pairs(joy.hats) do
          comma()
          o = tostring(o) .. "h" .. tostring(k) .. "(" .. tostring(v) .. ")"
        end
        comma()
        o = tostring(o) .. "b("
        first = true
        for k, _ in pairs(joy.buttons) do
          comma()
          o = tostring(o) .. tostring(k)
        end
        o = tostring(o) .. ")"
        lg.print(o, x, y + 16 * i)
        i = i + 1
      end
      return i
    end,
    lgPrintButtons = function(self, x, y)
      if not x then
        x = 0
      end
      if not y then
        y = 0
      end
      local s = self:printButtonString()
      lg.print(s, x, y)
      s = self:printButtonString(self.buttonDebounces)
      lg.print(s, x, y + 16)
      return self:printJoystickStrings(x, y + 32)
    end,
    setButtons = function(self, b, v)
      if not b then
        return nil
      end
      if not v then
        v = false
      end
      for i = 1, #b do
        self.buttons[b:sub(i, i)] = v
      end
    end,
    getButton = function(self, v, once)
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
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
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
        s = false
      }
      self.buttonDebounces = {
        l = false,
        u = false,
        r = false,
        d = false,
        a = false,
        b = false,
        c = false,
        s = false
      }
      self.img = nil
      self.qdpad = nil
      self.points = {
        top = 1
      }
      self.widgets = nil
      utils.loveChain(self, {
        'load',
        'draw',
        'resize',
        'keypressed',
        'keyreleased',
        'touchpressed',
        'touchreleased',
        'touchmoved',
        'mousepressed',
        'mousereleased',
        'mousemoved',
        'joystickpressed',
        'joystickreleased',
        'joystickaxis',
        'joystickhat'
      })
      return self:resize()
    end,
    __base = _base_0,
    __name = "Input"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Input = _class_0
  return _class_0
end
