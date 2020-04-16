cpath = tostring(...)\gsub "%.[^%.]+", ''
lg = love.graphics
utils = require "#{cpath}.utils"

_debugMouseTouch = false
_debugTouchPoints = false or _debugMouseTouch
_debugTouchRegions = false
_debugTouchForceShow = false

keys =
	left: 'l'
	up: 'u'
	right: 'r'
	down: 'd'
	s: 'l'
	e: 'u'
	f: 'r'
	d: 'd'
	lalt: 'a'
	lctrl: 'b'
	space: 'c'
	z: 'a'
	x: 'b'
	c: 'c'
	j: 'a'
	k: 'b'
	l: 'c'
	["return"]: 's'

joyButtons = {'a', 'b', 'c', 'a', 'b', 'c', 's', 's', 's', 's'}


class Widget

	new: (config)=>
		for k, v in pairs config
			@[k] = v
		@refresh!

	draw: =>
		p = @parent

		lg.push!
		lg.translate @offsetX, @offsetY
		lg.scale p.guiScale, p.guiScale
		lg.draw @img, @quad
		lg.pop!

		if _debugTouchRegions
			lg.setColor 1, 0, 0
			lg.rectangle 'line', @offsetX+0.5, @offsetY+0.5, @width, @height
			lg.setColor 1, 1, 1

	refresh: =>
		pw, ph = @img\getDimensions!
		p = @parent
		s = p.guiScale
		x, y = @x * s, @y * s
		@quad = lg.newQuad @sx, @sy, @sw, @sh, pw, ph
		@offsetX = if x < 0 then p.guiWidth + x else x
		@offsetY = if y < 0 then p.guiHeight + y else y
		@width = @sw * s
		@height = @sh * s

	isHit: (x, y)=>
		return x >= @offsetX and y >= @offsetY and x < @offsetX + @width and y < @offsetY + @height

	getButton: =>
		if @button then
			@button
		else
			nil

	hitCoords: (x, y) =>
		s = @parent.guiScale
		(x - @offsetX) / s, (y - @offsetY) / s


class DpadWidget extends Widget

	getButton: (x, y)=>
		if not x
			x = 0
		if not y
			y = 0
		x = x - 16
		y = y - 16

		d = math.sqrt x*x + y*y
		if d < 5 or d >= 16
			return

		r = math.pi / 8
		a = math.atan2 y, x
		o = ''

		if a > r and a < r*7
			o = "#{o}d"
		if a > r*5 or a < -r*5
			o = "#{o}l"
		if a > -r*7 and a < -r
			o = "#{o}u"
		if a > -r*3 and a < r*3
			o = "#{o}r"
		o


export class Input

	new: =>
		@disableTouch = false
		@usingTouch = false

		@guiWidth = 1280
		@guiHeight = 800
		@guiScale = 2
		@joyThreshold = 0.5

		@buttons =
			l: false
			u: false
			r: false
			d: false
			a: false
			b: false
			c: false
			s: false

		@buttonDebounces =
			l: false
			u: false
			r: false
			d: false
			a: false
			b: false
			c: false
			s: false

		@img = nil
		@qdpad = nil
		@points =
			top: 1
		@widgets = nil
		
		utils.loveChain self, {
			'load', 'draw', 'resize',
			'keypressed', 'keyreleased',
			'touchpressed', 'touchreleased', 'touchmoved',
			'mousepressed', 'mousereleased', 'mousemoved',
			'joystickpressed', 'joystickreleased', 'joystickaxis', 'joystickhat'
		}

		@resize!

	love: =>
		@img = lg.newImage "#{cpath}/assets/buttons.png"
		@widgets = {
			DpadWidget {
				x: 4
				y: -64
				sx: 0
				sy: 0
				sw: 32
				sh: 32
				img: @img
				parent: self
				update: true
			},
			Widget {
				x: -40
				y: -70
				sx: 32
				sy: 0
				sw: 16
				sh: 16
				img: @img
				parent: self
				button: 'a'
				combi: true
			},
			Widget {
				x: -40
				y: -50
				sx: 48
				sy: 0
				sw: 16
				sh: 16
				img: @img
				parent: self
				button: 'b'
				combi: true
			},
			Widget {
				x: -20
				y: -60
				sx: 32
				sy: 16
				sw: 16
				sh: 16
				img: @img
				parent: self
				button: 'c'
				combi: true
			},
			Widget {
				x: -20
				y: 16
				sx: 48
				sy: 16
				sw: 16
				sh: 8
				img: @img
				parent: self
				button: 's'
			}
		}

	draw: =>
		if @disableTouch then return nil

		if not @usingTouch and not _debugTouchForceShow then return nil

		wids = @widgets
		for i=1, #wids
			lg.setColor 1, 1, 1, 0.5
			wids[i]\draw!
		lg.setColor 1, 1, 1, 1

		if _debugTouchPoints
			@drawTouches!

		if _debugMouseTouch and @_dbgMouseX and @_dbgMouseY
			@drawTarget @_dbgMouseX, @_dbgMouseY, {0, 0.3, 1}

	drawTarget: (x, y, col)=>
		r, g, b, a = nil
		if col
			r, g, b, a = lg.getColor!
			lg.setColor col

		lg.circle 'line', x, y, 48
		lg.line x-64, y, x+64, y
		lg.line x, y-64, x, y+64

		if col
			lg.setColor r, g, b, a

	drawTouches: =>
		lg.push!

		for k, v in pairs @points
			if k ~= 'top'
				@drawTarget v.x, v.y

		lg.pop!

	resize: (w, h)=>
		if not (w or h)
			w, h = lg.getDimensions!

		@guiWidth = w
		@guiHeight = h
		@guiScale = math.floor math.min(w, h) / 120

		if not @widgets then return nil
		
		for i=1, #@widgets
			@widgets[i]\refresh!

	keypressed: (key)=>
		for k, v in pairs keys
			if key == k and not @buttons[v]
				@buttons[v] = true

	keyreleased: (key)=>
		if @usingTouch
			@usingTouch = false

		if key == 'escape'
			love.event.quit!

		elseif key == 'f11'
			if love.window.getFullscreen!
				love.window.setFullscreen false
			else
				love.window.setFullscreen true
			return nil

		for k, v in pairs keys
			if key == k and @buttons[v]
				@buttons[v] = false

	touchpressed: (id, x, y)=>
		if @disableTouch 
			return nil

		if not @usingTouch
			@usingTouch = true

		hit = nil
		for i=1, #@widgets
			w = @widgets[i]
			if w\isHit x, y
				hit = w

		if not hit
			return nil

		b = hit\getButton hit\hitCoords(x, y)
		if not b
			return nil

		@setButtons b, true
		pts = @points
		pts[id] =
			id: pts.top
			:x
			:y
			w: hit
		pts.top += 1

	touchreleased: (id, x, y)=>
		if @disableTouch
			return nil

		p = @points[id]
		if p
			b = p.w\getButton p.w\hitCoords(x, y)
			if not b then b = 'lurd'
			@setButtons b, false
		@points[id] = nil

	touchmoved: (id, x, y)=>
		if @disableTouch
			return nil

		p = @points[id]
		if not p
			return nil
		p.x = x
		p.y = y
		if p.w.update
			@setButtons 'lurd', false
			b = p.w\getButtons p.w\hitCoords(x, y)
			@setButtons b, true

	mousepressed: (x, y, b, t)=>
		if _debugMouseTouch and b == 1 and not t
			@touchpressed 1, x, y

	mousereleased: (x, y, b, t)=>
		if _debugMouseTouch and b == 1 and not t
			@touchreleased 1, x, y

	mousemoved: (x, y, t)=>
		@_dbgMouseX = x
		@_dbgMouseY = y
		if _debugMouseTouch and not t
			@touchmoved 1, x, y

	joystickpressed: (j, b)=>
		joy = @ensureJoystick j
		joy.buttons[b] = b
		m = joyButtons[b]
		if m
			@buttons[m] = true

	joystickreleased: (j, b)=>
		joy = @ensureJoystick j
		joy.buttons[b] = nil
		m = joyButtons[b]
		if m
			@buttons[m] = false

	joystickaxis: (j, a, v)=>
		thr = @joyThreshold
		btns = @buttons
		dealAxis = (a, f, s)=>
			if a < -thr
				btns[f] = true
				btns[s] = false
			elseif a < thr
				btns[f] = false
				btns[s] = false
			else
				btns[f] = false
				btns[s] = true
		joy = @ensureJoystick(j)
		joy.axis[a] = v
		if a == 1 then dealAxis v, 'l', 'r'
		if a == 2 then dealAxis v, 'u', 'd'

	joystickhat: (j, h, d)=>
		joy = @ensureJoystick j
		oldHat = joy.hats[h]
		btns = @buttons
		joy.hats[h] = d

		if h == 1
			dirs = 'lurd'
			for i=1, #dirs
				btns[dirs\sub(i,i)] = false
			for i=1, #d
				v = d\sub i, i
				if v ~= 'c' then
					btns[v] = true

	ensureJoystick: (j)=>
		if not @joysticks
			@joysticks = {}
		joy = @joysticks[j]
		if not joy
			joy =
				buttons: {}
				axis: {}
				hats: {}
			@joysticks[j] = joy
		joy

	printButtonString: (v)=>
		l, u, r, d, a, b, c, s = nil
		b = @buttons
		if v
			b = v
		l = if b.l then 'L' else 'l'
		u = if b.u then 'U' else 'u'
		r = if b.r then 'R' else 'r'
		d = if b.d then 'D' else 'd'
		a = if b.a then 'A' else 'a'
		c = if b.c then 'C' else 'c'
		s = if b.s then 'S' else 's'
		b = if b.b then 'B' else 'b'

		"#{l}#{u}#{r}#{d}#{a}#{b}#{c}#{s}"

	printJoystickStrings: (x, y)=>
		if not @joysticks then return 0
		i = 0
		for joyId, joy in pairs @joysticks
			joyName = joyId\getName!
			o = "#{joyName}: "

			first = true
			comma = =>
				if first
					first = false
				else
					o = "#{o}, "
			
			for k, v in pairs joy.axis
				comma!
				o = "#{o}a#{k}(#{v})"

			for k, v in pairs joy.hats
				comma!
				o = "#{o}h#{k}(#{v})"

			comma!
			o = "#{o}b("
			first = true
			for k, _ in pairs(joy.buttons) do
				comma!
				o = "#{o}#{k}"
			o = "#{o})"

			lg.print o, x, y + 16 * i
			i += 1
		i

	lgPrintButtons: (x, y)=>
		if not x then x = 0
		if not y then y = 0
		s = @printButtonString!
		lg.print s, x, y
		s = @printButtonString @buttonDebounces
		lg.print s, x, y+16
		@printJoystickStrings x, y+32

	setButtons: (b, v)=>
		if not b then return nil
		if not v then v = false

		for i=1, #b
			@buttons[b\sub(i,i)] = v

	getButton: (v, once)=>
		if once and @buttons[v]
			if @buttonDebounces[v]
				return false
			else
				@buttonDebounces[v] = true
				return true

		if not @buttons[v]
			@buttonDebounces[v] = false

		@buttons[v]
