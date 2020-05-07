log = require "log"

chain = (loveFunc, func, after)->
	(...)->
		if loveFunc and after
			loveFunc ...
		func ...
		if loveFunc and not after
			loveFunc ...

loveChain = (instance, funcNames)->
	for i=1, #funcNames
		key = funcNames[i]
		log.debug 1, "Chaining '#{key}'..."
		love[key] = chain love[key], (...)->
			--log.debug "Calling '#{key}'..."
			instance[key] instance, ...

{
	:loveChain
}
