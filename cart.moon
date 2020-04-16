lg = love.graphics


class Cart

	new: (runtime)=>
		@_runtime = runtime

		lg.setDefaultFilter 'nearest', 'nearest'
		@_backCanvas = lg.newCanvas 2048, 2048
		@_clear = nil

		@_tileSetCache = {}
		@_tileSets =
			nextIndex: 0

	tileDraw: (tilesetID, sourceCellX, sourceCellY, destinationCellX, spanCellX, spanCellY, alpha, colour, offsetX, offsetY, flipX, flipY)=>
		ts = @findTileset tilesetID
		if not ts
			error "Need a tileset ID!", 2

		if not (sourceCellX and sourceCellY)
			error "Invalid source coordinates (#{sourceCellX}, #{sourceCellY}", 2

		if not (destinationCellX and destinationCellY)
			error "Invalid destination coordinates (#{destinationCellX}, #{destinationCellY})", 2

		dx = sourceCellX * 8
		dy = sourceCellY * 8

		isx = spanCellX or 1
		isy = spanCellY or 1

		ox = offsetX or 0
		oy = offsetY or 0

		fx = flipX and -1 or 1
		fy = flipY and -1 or 1

		if flipX then destCellX += isx
		if flipY then destCellY += isy

		w = isx * 8
		h = isy * 8

		quad = ts.quad
		if quad
			quad\setViewport dx, dy, w, h, ts.imageWidth, ts.imageHeight
		else
			quad = lg.newQuad dx, dy, w, h, ts.imageWidth, ts.imageHeight
			ts.quad = quad

		alpha = alpha or 1
		col = colour or {1, 1, 1}

		lg.setCanvas @_backCanvas
		lg.setBlendMode 'alpha'
		lg.setColor col[1], col[2], col[3], alpha
		lg.draw ts.image, quad, destinationCellX * 8 + ox, destinationCellY * 8 + oy, 0, fx, fy
		lg.setCanvas!

	tileClear: (destinationCellX, destinationCellY, spanCellX, spanCellY, alpha, colour, offsetX, offsetY)=>
		ox = offsetX or 0
		oy = offsetY or 0

		sx = spanCellX or 1
		sy = spanCellY or 1

		alpha = alpha or 0
		col = colour or {0, 0, 0}

		lg.setCanvas @_backCanvas
		lg.setBlendMode 'replace'
		lg.setColor col[1], col[2], col[3], alpha
		lg.rectangle 'fill', destinationCellX * 8 + ox, destinationCellY * 8 + oy, sx * 8, sy * 8
		lg.setCanvas!
		lg.setBlendMode 'alpha'

	createTileset: (img)=>
		ts = @_tileSets
		iw, ih = img\getDimensions!

		ts.nextIndex += 1
		n = "tset#{ts.nextIndex}"
		t =
			key: n
			image: img
			imageWidth: iw
			imageHeight: ih
			lineCells: math.floor iw / 8
		ts[n] = t

		n, t

	loadTileset: (fileName)=>
		if not fileName
			error "Need a fileName to load!", 2

		if not love.filesystem.getInfo fileName
			error "Missing file: #{fileName}", 2

		tsc = @_tileSetCache
		t = tsc[fileName]
		n = nil
		if t
			n = t.key
		else
			img = lg.newImage fileName

			n, t = @createTileset img
			t.fileName = fileName
			tsc[fileName] = t

		n

	listTileset: =>
		o = {}

		for k, v in pairs @_tileSets
			if k\sub(1, 4) == 'tset'
				o[#o+1] = k

		return o

	removeTileset: (n)=>
		t = @findTileset n
		if t
			@_tileSetCache[t.fileName] = nil
			@_tileSets[n] = nil

	findTileset: (n)=>
		if not n
			return nil

		if type(n) ~= 'string' or #n < 5 or n\sub(1, 4) ~= 'tset'
			print "Warning! #{n} may not be a tileset ID."

		@_tileSets[n]

	clearScreen: (...)=>
		lg.setCanvas @_runtime.bgCvs
		@_runtime.drawBegin()
		lg.clear ...
		@_runtime.drawEnd()
		lg.setCanvas!

	drawMap: (sourceCellX, sourceCellY, spanCellX, spanCellY, offsetX, offsetY, rotationAngle, scale, alpha, colour)=>
		if not sourceCellX or not sourceCellY
			error "Invalid coordinates (#{sourceCellX}, #{sourceCellY})!", 2

		bg = @_backCanvas
		q = bg.quad or lg.newQuad 0, 0, 8, 8, bg\getDimensions!

		ss = @_runtime.screenSize / 8
		cw = spanCellX or ss
		ch = spanCellY or ss
		ox = offsetX or 0
		oy = offsetY or 0

		scale = scale or 1
		alpha = alpha or 1
		col = colour or {1, 1, 1}

		q\setViewport sourceCellX * 8, sourceCellY * 8, cw * 8, ch * 8
		lg.setCanvas @_runtime.bgCvs
		@_runtime.drawBegin!
		lg.push!
		lg.translate ox, oy
		if rotationAngle
			lg.translate cw*4*scale, ch*4*scale
			lg.rotate rotationAngle
			lg.translate -cw*4*scale, -ch*4*scale
		lg.scale scale, scale
		lg.setColor col[1], col[2], col[3], alpha
		lg.draw bg, q
		lg.pop!
		@_runtime.drawEnd!
		lg.setCanvas!

	print: (x, y, text, c)=>
		if not x or type(x) ~= 'number' or
			 not y or type(y) ~= 'number'
			error "Invalid printXY coords (#{x}, #{y})", 2

		if not text
			error "Need something to print for printXY", 2

		col = c or {1, 1, 1}

		lg.setCanvas @_runtime.bgCvs
		lg.setColor col[1], col[2], col[3]
		lg.print text, x, y
		lg.setCanvas!

	getViewportInfo: =>
		@_runtime.getViewportInfo!

	button: (btn)=>
		@_runtime.input\getButton btn

	buttonPressed: (btn)=>
		@_runtime.input\getButton btn, true

	getDivMod: (a, b)=>
		if b == 0
			return
		c = a / b
		d = math.floor c
		d, (c-d) * b

	tileDump: (fileName)=>
		cdata = @_backCanvas\newImageData!
		cdata\encode 'png', fileName
