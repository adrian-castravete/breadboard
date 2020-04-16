--- Breadboard (fkge)
--
-- Simple game engine over Löve2D for even faster prototyping
--
-- @classmod Breadboard
-- @license MIT
-- @author Adrian Castravete

cpath = ...
lg = love.graphics
utils = require cpath .. ".utils"
Input = require cpath .. ".input"
Cart = require cpath .. ".cart"

_debug = false


class FrozenKnightGameEngine

	new: =>
		ssize = 240
		input = Input!

		@env =
			frame: -> nil
		@state = 'running'
		@screenSize = ssize
		@width = 1280
		@height = 800
		@zoom = 2
		@offsetX = 0
		@offsetY = 0
		@cart = nil
		@runtime =
			:ssize
			:input
			drawBegin: @drawBegin
			drawEnd: @drawEnd
			getViewportInfo: ->
				return {
					originX: @offsetX
					originY: @offsetY
					width: @width
					height: @height
					zoom: @zoom
				}
			bgCvs: lg.newCanvas @width, @height

		@_animations = {}

	start: =>
		@cart = Cart @runtime
		utils.loveChain self, {'load', 'update', 'draw', 'resize'}

	load: =>
		if not @env.showMouse
			love.mouse.setVisible false
		lg.setDefaultFilter 'nearest', 'nearest'
		@onResize!

	safeCall: (...)=>
		values = {pcall(...)}
		ok = values[1]
		if ok
			table.remove values, 1
			unpack values
		else
			@setError values[2]

	update: (dt)=>
		if @state == 'running'
			@safeCall @env.frame, dt
			@cycleAnimations dt

	draw: =>
		-- lg.clear 2/7, 5/7, 1
		lg.clear!
		if @state == 'fatalError'
			@drawError!
			return

		lg.setColor 1, 1, 1
		lg.draw @runtime.bgCvs
		if _debug and @input
			input\lovePrintButtons()

	drawBegin: =>
		lg.push!
		lg.translate @offsetX, @offsetY
		lg.scale @zoom, @zoom

	drawEnd: =>
		lg.pop!

	drawError: =>
		lg.setFont @_errorFont
		lg.print @errorMessage, @_errorOffsetX, @_errorOffsetY

	resize: (w, h)=>
		@onResize w, h

	onResize: (w, h)=>
		if not (w and h)
			w, h = lg.getDimensions!

		if w ~= @width or h ~= @height
			@runtime.bgCvs = lg.newCanvas w, h

		@width = w
		@height = h
		@zoom = math.floor(math.min(w, h) / @screenSize)

		size = @zoom * @screenSize
		if w > h
			@offsetY = (h - size) * 0.5
			@offsetX = @offsetY + (w - h) * 0.5
		else
			@offsetX = (w - size) * 0.5
			@offsetY = @offsetX

	setError: (text)=>
		font = lg.newFont @height / 32
		ew = font\getWidth text
		eh = font\getHeight!
		w, h = lg.getDimensions!

		@_errorOffsetX = (w - ew) * 0.5
		@_errorOffsetY = (h - eh) * 0.5
		@_errorFont = font
		@state = 'fatalError'
		@errorMessage = text

	createAnimation: (delay, fnProgress, fnDone)=>
		co = coroutine.create (delay)->
			v = 0
			while v < delay
				@safeCall fnProgress, v / delay
				v = v + coroutine.yield()
			@safeCall fnProgress, 1
			if fnDone
				@safeCall fnDone

		coroutine.resume co, delay / 1000
		table.insert @_animations, co

	cycleAnimation: (dt)=>
		anims = @_animations

		nanims = {}
		for i=1, #anims
			co = anims[1]
			if coroutine.resume co, dt
				table.insert nanims, co

		@_animations = nanims


export class Breadboard

	--- Constructor.
	-- Create the main Breadboard object, a simple engine on top of Löve2D
	-- @tparam boolean dontStart whether to create the _cart_ and start running
	new: (dontStart)=>
		@fkge = FrozenKnightGameEngine!
		if not dontStart
			@fkge.start!
		self

	--- Draw (part of) the map to screen.
	-- Given some source coordinates along with a width and height, draw as many
	-- tiles to the screen to a specified coordinate.
	-- @tparam number srcX the start coordinate to draw the map from (X coordinate)
	-- @tparam number srcY the start coordinate to draw the map from (Y coordinate)
	-- @tparam number spX the amount of tiles to draw to the screen (X coordinate)
	-- @tparam number spY the amount of tiles to draw to the screen (Y coordinate)
	-- @tparam number offX the position on screen to draw to (X coordinate)
	-- @tparam number offY the position on screen to draw to (Y coordinate)
	-- @tparam number rotationAngle rotate the map while drawing it to the screen (default 0)
	-- @tparam number scale the size of the map while drawing to the screen (default 1)
	-- @tparam number a the opacity of the thing to draw (default 1)
	-- @tparam table col the colour effect (default is white {1, 1, 1})
	draw: (...)=>
		@_doCart 'drawMap', ...

	--- Draw new tiles from a tileset into the map data.
	-- Given a tileset copy one or more tiles to the map data.
	-- @tparam string tsetID the Identification tag for the loaded tileset
	-- @tparam number srcX the start coordinate to draw the from the tileset (X coordinate)
	-- @tparam number srcY the start coordinate to draw the from the tileset (Y coordinate)
	-- @tparam number dstX the start coordinate to draw on the map (X coordinate)
	-- @tparam number dstY the start coordinate to draw on the map (Y coordinate)
	-- @tparam number spX the amount of tiles to draw to the tile map (X coordinate) (default 1)
	-- @tparam number spY the amount of tiles to draw to the tile map (Y coordinate) (default 1)
	-- @tparam number a the opacity of the thing to draw (default 1)
	-- @tparam table col the colour effect (default is white {1, 1, 1})
	-- @tparam number offX finer control over where to draw on the map (X coordinate) (default 0)
	-- @tparam number offY finer control over where to draw on the map (Y coordinate) (default 0)
	-- @tparam boolean fX whether to flip horizontally (default false)
	-- @tparam boolean fY whether to flip vertically (default false)
	tile: (...)=>
		@_doCart 'tileDraw', ...

	--- Clear one or more tiles from the tile map
	-- @tparam number dstX the start coordinate to clear on the map (X coordinate)
	-- @tparam number dstY the start coordinate to clear on the map (Y coordinate)
	-- @tparam number spX the amount of tiles to draw to the tile map (X coordinate) (default 1)
	-- @tparam number spY the amount of tiles to draw to the tile map (Y coordinate) (default 1)
	-- @tparam number a the opacity of the thing to draw (default 0)
	-- @tparam table col the colour effect (default is black {0, 0, 0})
	tileClear: (...)=>
		@_doCart 'tileClear', ...

	--- Clear the screen.
	-- It's advisable to always have this in the start of the _tick_ function.
	-- Whatever is given to this function is passed to `love.graphics.clear`.
	-- So you can pass **_either_ one table** or up to **four numbers**.
	-- The default is colour black.
	-- @tparam table colours a table containing the red, green, blue values
	--  and an optional alpha on their respective positions
	-- @tparam number red value for the red channel
	-- @tparam number green value for the green channel
	-- @tparam number blue value for the blue channel
	-- @tparam number alpha value for the alpha channel
	clearScreen: (...)=>
		@_doCart 'clearScreen', ...

	--- Make a tileset from a file.
	-- Load a file pointed to by `fileName` and check whether it has already been loaded.
	-- In case it has, return the existing tileset, otherwise create a tileset from the file,
	-- cache it and return it.
	-- @tparam string fileName the given file name
	-- @treturn string tileset ID
	makeTileset: (...)=>
		@_doCart 'loadTileset', ...

	--- List all loaded tileset IDs.
	-- @treturn table the table containing the list of all loaded/cached tileset IDs
	listTilesets: =>
		@_doCart 'listTilesets'
	
	--- Remove a tileset.
	-- Given its ID remove a loaded tileset. On error, silently fail.
	-- @tparam string tilesetID tileset ID
	removeTileset: (...)=>
		@_doCart 'removeTileset', ...

	--- Retrieve a button's state.
	-- Given a button ID return whether it's pressed or not.
	-- @tparam string btn a button ID (l,u,r,d,a,b,c,s)
	-- @treturn boolean the button state
	button: (...)=>
		@_doCart 'button', ...

	--- Retrieve whether a button has just been pressed.
	-- Given a button ID return whether it's been pressed in the last frame.
	-- @tparam string btn a button ID (l,u,r,d,a,b,c,s)
	-- @treturn boolean the button state
	buttonPressed: (...)=>
		@_doCart 'buttonPressed', ...

	--- Print text on screen
	-- Print some text on screen using the default font. This is very basic and should only be used
	-- for debugging reasons, or not at all.
	-- @tparam number x the X coordinate of where to start writing
	-- @tparam number y the Y coordinate of where to start writing
	-- @tparam string text the **text** to write
	-- @tparam table col the colour to use (default white {1, 1, 1})
	printXY: (...)=>
		@_doCart 'print', ...

	--- Write the tilemap to disk.
	-- Given a file name write the current state of the tile map to disk. This is pretty heavy, so
	-- it should be avoided for every frame. It's mainly for debugging reasons.
	-- @tparam string fileName the file name to write to. (PNG)
	tileDump: (...)=>
		@_doCart 'tileDump', ...

	--- Change configuration stuff.
	-- Some changes may only be changed before the start of the engine, others can be change whilst
	-- it is running.
	-- @tparam table options the configuration table; the known confiuration entries are:
	--
	--  * disableTouch - disable the gamepad that appears on android; Good for when you use
	--  Löve2D's touch capabilities. (default false)
	--  * showMouse - by default the mouse is hidden, set this to true to leave
	--  the mouse cursor visible
	config: (options)=>
		if not options or type(options) ~= 'table'
			return nil

		if options.disableTouch and input
			input.disableTouch = true

		if options.showMouse
			@fkge.env.showMouse = true

	--- Return some viewport information.
	-- Return some _crucial?!_ information about the viewport.
	-- @treturn table a table containing the following values:
	--
	--  * offsetX and offsetY - Given that the viewport is dynamic this shows where exactly on 
	--  screen the first pixel of the internal viewport square
	--  * width and height - The viewport dimensions
	--  * zoom - The current scale/zoom level
	viewport: =>
		return {
			offsetX: @fkge.offsetX
			offsetY: @fkge.offsetY
			width: @fkge.width
			height: @fkge.height
			zoom: @fkge.zoom
		}

	--- Start an animation coroutine.
	-- Given a delay, a progress function and a done function, until the delay ends, execute the
	-- progress function (passing it the elapsed percentage) and finally execute the done function.
	-- @tparam number delay the amount in milliseconds to execute this animation for.
	-- @tparam function fnProgress the progress function
	-- @tparam function fnDone the done function
	animate: (delay, fnProgress, fnDone) =>
		@fkge\createAnimation(delay, fnProgress, fnDone)

	--- Linear interpolation function.
	-- Interpolate two numbers at a specific percentage.
	-- @tparam number a the first value
	-- @tparam number b the second value
	-- @tparam number ratio the ratio between the two as a value between 0 and 1
	lerp: (a, b, ratio)=>
		a + (b - a) * ratio

	--- Set or Get the screen size.
	-- If a value `v` is given, set the internal viewport size to `v` x `v`.
	-- @tparam number v if this is given, set the screen size
	-- @treturn number the screen size if `v` is nto given
	screenSize: (v)=>
		if v
			@fkge.screenSize = v
			@fkge.runtime.screenSize = v
			@fkge\onResize!
		else
			@fkge.screenSize

	_doCart: (method, ...)=>
		c = @fkge.cart
		if not c
			error "Game not started!", 3
		c[method](c, ...)
