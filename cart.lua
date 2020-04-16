local lg = love.graphics
local Cart
do
  local _class_0
  local _base_0 = {
    tileDraw = function(self, tilesetID, sourceCellX, sourceCellY, destinationCellX, spanCellX, spanCellY, alpha, colour, offsetX, offsetY, flipX, flipY)
      local ts = self:findTileset(tilesetID)
      if not ts then
        error("Need a tileset ID!", 2)
      end
      if not (sourceCellX and sourceCellY) then
        error("Invalid source coordinates (" .. tostring(sourceCellX) .. ", " .. tostring(sourceCellY), 2)
      end
      if not (destinationCellX and destinationCellY) then
        error("Invalid destination coordinates (" .. tostring(destinationCellX) .. ", " .. tostring(destinationCellY) .. ")", 2)
      end
      local dx = sourceCellX * 8
      local dy = sourceCellY * 8
      local isx = spanCellX or 1
      local isy = spanCellY or 1
      local ox = offsetX or 0
      local oy = offsetY or 0
      local fx = flipX and -1 or 1
      local fy = flipY and -1 or 1
      if flipX then
        local destCellX = destCellX + isx
      end
      if flipY then
        local destCellY = destCellY + isy
      end
      local w = isx * 8
      local h = isy * 8
      local quad = ts.quad
      if quad then
        quad:setViewport(dx, dy, w, h, ts.imageWidth, ts.imageHeight)
      else
        quad = lg.newQuad(dx, dy, w, h, ts.imageWidth, ts.imageHeight)
        ts.quad = quad
      end
      alpha = alpha or 1
      local col = colour or {
        1,
        1,
        1
      }
      lg.setCanvas(self._backCanvas)
      lg.setBlendMode('alpha')
      lg.setColor(col[1], col[2], col[3], alpha)
      lg.draw(ts.image, quad, destinationCellX * 8 + ox, destinationCellY * 8 + oy, 0, fx, fy)
      return lg.setCanvas()
    end,
    tileClear = function(self, destinationCellX, destinationCellY, spanCellX, spanCellY, alpha, colour, offsetX, offsetY)
      local ox = offsetX or 0
      local oy = offsetY or 0
      local sx = spanCellX or 1
      local sy = spanCellY or 1
      alpha = alpha or 0
      local col = colour or {
        0,
        0,
        0
      }
      lg.setCanvas(self._backCanvas)
      lg.setBlendMode('replace')
      lg.setColor(col[1], col[2], col[3], alpha)
      lg.rectangle('fill', destinationCellX * 8 + ox, destinationCellY * 8 + oy, sx * 8, sy * 8)
      lg.setCanvas()
      return lg.setBlendMode('alpha')
    end,
    createTileset = function(self, img)
      local ts = self._tileSets
      local iw, ih = img:getDimensions()
      ts.nextIndex = ts.nextIndex + 1
      local n = "tset" .. tostring(ts.nextIndex)
      local t = {
        key = n,
        image = img,
        imageWidth = iw,
        imageHeight = ih,
        lineCells = math.floor(iw / 8)
      }
      ts[n] = t
      return n, t
    end,
    loadTileset = function(self, fileName)
      if not fileName then
        error("Need a fileName to load!", 2)
      end
      if not love.filesystem.getInfo(fileName) then
        error("Missing file: " .. tostring(fileName), 2)
      end
      local tsc = self._tileSetCache
      local t = tsc[fileName]
      local n = nil
      if t then
        n = t.key
      else
        local img = lg.newImage(fileName)
        n, t = self:createTileset(img)
        t.fileName = fileName
        tsc[fileName] = t
      end
      return n
    end,
    listTileset = function(self)
      local o = { }
      for k, v in pairs(self._tileSets) do
        if k:sub(1, 4) == 'tset' then
          o[#o + 1] = k
        end
      end
      return o
    end,
    removeTileset = function(self, n)
      local t = self:findTileset(n)
      if t then
        self._tileSetCache[t.fileName] = nil
        self._tileSets[n] = nil
      end
    end,
    findTileset = function(self, n)
      if not n then
        return nil
      end
      if type(n) ~= 'string' or #n < 5 or n:sub(1, 4) ~= 'tset' then
        print("Warning! " .. tostring(n) .. " may not be a tileset ID.")
      end
      return self._tileSets[n]
    end,
    clearScreen = function(self, ...)
      lg.setCanvas(self._runtime.bgCvs)
      self._runtime.drawBegin()
      lg.clear(...)
      self._runtime.drawEnd()
      return lg.setCanvas()
    end,
    drawMap = function(self, sourceCellX, sourceCellY, spanCellX, spanCellY, offsetX, offsetY, rotationAngle, scale, alpha, colour)
      if not sourceCellX or not sourceCellY then
        error("Invalid coordinates (" .. tostring(sourceCellX) .. ", " .. tostring(sourceCellY) .. ")!", 2)
      end
      local bg = self._backCanvas
      local q = bg.quad or lg.newQuad(0, 0, 8, 8, bg:getDimensions())
      local ss = self._runtime.screenSize / 8
      local cw = spanCellX or ss
      local ch = spanCellY or ss
      local ox = offsetX or 0
      local oy = offsetY or 0
      scale = scale or 1
      alpha = alpha or 1
      local col = colour or {
        1,
        1,
        1
      }
      q:setViewport(sourceCellX * 8, sourceCellY * 8, cw * 8, ch * 8)
      lg.setCanvas(self._runtime.bgCvs)
      self._runtime.drawBegin()
      lg.push()
      lg.translate(ox, oy)
      if rotationAngle then
        lg.translate(cw * 4 * scale, ch * 4 * scale)
        lg.rotate(rotationAngle)
        lg.translate(-cw * 4 * scale, -ch * 4 * scale)
      end
      lg.scale(scale, scale)
      lg.setColor(col[1], col[2], col[3], alpha)
      lg.draw(bg, q)
      lg.pop()
      self._runtime.drawEnd()
      return lg.setCanvas()
    end,
    print = function(self, x, y, text, c)
      if not x or type(x) ~= 'number' or not y or type(y) ~= 'number' then
        error("Invalid printXY coords (" .. tostring(x) .. ", " .. tostring(y) .. ")", 2)
      end
      if not text then
        error("Need something to print for printXY", 2)
      end
      local col = c or {
        1,
        1,
        1
      }
      lg.setCanvas(self._runtime.bgCvs)
      lg.setColor(col[1], col[2], col[3])
      lg.print(text, x, y)
      return lg.setCanvas()
    end,
    getViewportInfo = function(self)
      return self._runtime.getViewportInfo()
    end,
    button = function(self, btn)
      return self._runtime.input:getButton(btn)
    end,
    buttonPressed = function(self, btn)
      return self._runtime.input:getButton(btn, true)
    end,
    getDivMod = function(self, a, b)
      if b == 0 then
        return 
      end
      local c = a / b
      local d = math.floor(c)
      return d, (c - d) * b
    end,
    tileDump = function(self, fileName)
      local cdata = self._backCanvas:newImageData()
      return cdata:encode('png', fileName)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, runtime)
      self._runtime = runtime
      lg.setDefaultFilter('nearest', 'nearest')
      self._backCanvas = lg.newCanvas(2048, 2048)
      self._clear = nil
      self._tileSetCache = { }
      self._tileSets = {
        nextIndex = 0
      }
    end,
    __base = _base_0,
    __name = "Cart"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Cart = _class_0
  return _class_0
end
