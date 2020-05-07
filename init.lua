local cpath = ...
local lg = love.graphics
local utils = require(tostring(cpath) .. ".utils")
local log = require(tostring(cpath) .. ".log")
local Input = require(tostring(cpath) .. ".input")
local Cart = require(tostring(cpath) .. ".cart")
local _debug = false
local FrozenKnightGameEngine
do
  local _class_0
  local _base_0 = {
    start = function(self)
      self.cart = Cart(self.runtime)
      return utils.loveChain(self, {
        'load',
        'update',
        'draw',
        'resize'
      })
    end,
    load = function(self)
      if not self.showMouse then
        love.mouse.setVisible(false)
      end
      lg.setDefaultFilter('nearest', 'nearest')
      return self:onResize()
    end,
    safeCall = function(self, ...)
      local values = {
        pcall(...)
      }
      local ok = values[1]
      if ok then
        table.remove(values, 1)
        return unpack(values)
      else
        return self:setError(values[2])
      end
    end,
    update = function(self, dt)
      if self.state == 'running' and self.frame then
        self:safeCall(function(dt)
          return self:frame(dt)
        end)
        return self:cycleAnimations(dt)
      end
    end,
    draw = function(self)
      lg.clear()
      if self.state == 'fatalError' then
        self:drawError()
        return 
      end
      lg.setColor(1, 1, 1)
      lg.draw(self.runtime.bgCvs)
      if _debug and self.input then
        return input:lovePrintButtons()
      end
    end,
    drawBegin = function(self)
      lg.push()
      lg.translate(self.offsetX, self.offsetY)
      return lg.scale(self.zoom, self.zoom)
    end,
    drawEnd = function(self)
      return lg.pop()
    end,
    drawError = function(self)
      lg.setFont(self._errorFont)
      return lg.print(self.errorMessage, self._errorOffsetX, self._errorOffsetY)
    end,
    resize = function(self, w, h)
      return self:onResize(w, h)
    end,
    onResize = function(self, w, h)
      if not (w and h) then
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
        self.offsetY = (h - size) * 0.5
        self.offsetX = self.offsetY + (w - h) * 0.5
      else
        self.offsetX = (w - size) * 0.5
        self.offsetY = self.offsetX
      end
    end,
    setError = function(self, text)
      local font = lg.newFont(self.height / 32)
      local ew = font:getWidth(text)
      local eh = font:getHeight()
      local w, h = lg.getDimensions()
      self._errorOffsetX = (w - ew) * 0.5
      self._errorOffsetY = (h - eh) * 0.5
      self._errorFont = font
      self.state = 'fatalError'
      self.errorMessage = text
    end,
    createAnimation = function(self, delay, fnProgress, fnDone)
      local co = coroutine.create(function(delay)
        local v = 0
        while v < delay do
          self:safeCall(fnProgress, v / delay)
          v = v + coroutine.yield()
        end
        self:safeCall(fnProgress, 1)
        if fnDone then
          return self:safeCall(fnDone)
        end
      end)
      coroutine.resume(co, delay / 1000)
      return table.insert(self._animations, co)
    end,
    cycleAnimations = function(self, dt)
      local anims = self._animations
      local nanims = { }
      for i = 1, #anims do
        local co = anims[1]
        if coroutine.resume(co, dt) then
          table.insert(nanims, co)
        end
      end
      self._animations = nanims
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      local ssize = 240
      local input = Input()
      self.frame = nil
      self.state = 'running'
      self.screenSize = ssize
      self.width = 1280
      self.height = 800
      self.zoom = 2
      self.offsetX = 0
      self.offsetY = 0
      self.cart = nil
      self.runtime = {
        ssize = ssize,
        input = input,
        drawBegin = self.drawBegin,
        drawEnd = self.drawEnd,
        getViewportInfo = function()
          return {
            originX = self.offsetX,
            originY = self.offsetY,
            width = self.width,
            height = self.height,
            zoom = self.zoom
          }
        end,
        bgCvs = lg.newCanvas(self.width, self.height)
      }
      self._animations = { }
    end,
    __base = _base_0,
    __name = "FrozenKnightGameEngine"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  FrozenKnightGameEngine = _class_0
end
do
  local _class_0
  local _base_0 = {
    draw = function(self, ...)
      return self:_doCart('drawMap', ...)
    end,
    tile = function(self, ...)
      return self:_doCart('tileDraw', ...)
    end,
    tileClear = function(self, ...)
      return self:_doCart('tileClear', ...)
    end,
    clearScreen = function(self, ...)
      return self:_doCart('clearScreen', ...)
    end,
    makeTileset = function(self, ...)
      return self:_doCart('loadTileset', ...)
    end,
    listTilesets = function(self)
      return self:_doCart('listTilesets')
    end,
    removeTileset = function(self, ...)
      return self:_doCart('removeTileset', ...)
    end,
    button = function(self, ...)
      return self:_doCart('button', ...)
    end,
    buttonPressed = function(self, ...)
      return self:_doCart('buttonPressed', ...)
    end,
    printXY = function(self, ...)
      return self:_doCart('print', ...)
    end,
    tileDump = function(self, ...)
      return self:_doCart('tileDump', ...)
    end,
    config = function(self, options)
      if not options or type(options) ~= 'table' then
        return nil
      end
      if options.disableTouch and input then
        input.disableTouch = true
      end
      if options.showMouse then
        self.fkge.showMouse = true
      end
    end,
    viewport = function(self)
      return {
        offsetX = self.fkge.offsetX,
        offsetY = self.fkge.offsetY,
        width = self.fkge.width,
        height = self.fkge.height,
        zoom = self.fkge.zoom
      }
    end,
    animate = function(self, delay, fnProgress, fnDone)
      return self.fkge:createAnimation(delay, fnProgress, fnDone)
    end,
    lerp = function(self, a, b, ratio)
      return a + (b - a) * ratio
    end,
    screenSize = function(self, v)
      if v then
        self.fkge.screenSize = v
        self.fkge.runtime.screenSize = v
        return self.fkge:onResize()
      else
        return self.fkge.screenSize
      end
    end,
    _doCart = function(self, method, ...)
      local c = self.fkge.cart
      if not c then
        error("Game not started!", 3)
      end
      return c[method](c, ...)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, dontStart)
      self.fkge = FrozenKnightGameEngine()
      self.fkge.frame = function(dt)
        if self.frame then
          return self:frame(dt)
        end
      end
      if not dontStart then
        self.fkge:start()
      end
      return self
    end,
    __base = _base_0,
    __name = "Breadboard"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Breadboard = _class_0
  return _class_0
end
