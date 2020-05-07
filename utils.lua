local log = require("log")
local chain
chain = function(loveFunc, func, after)
  return function(...)
    if loveFunc and after then
      loveFunc(...)
    end
    func(...)
    if loveFunc and not after then
      return loveFunc(...)
    end
  end
end
local loveChain
loveChain = function(instance, funcNames)
  for i = 1, #funcNames do
    local key = funcNames[i]
    log.debug(1, "Chaining '" .. tostring(key) .. "'...")
    love[key] = chain(love[key], function(...)
      return instance[key](instance, ...)
    end)
  end
end
return {
  loveChain = loveChain
}
