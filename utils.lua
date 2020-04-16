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
loveChain = function(instance, funcNames)
  for i = 1, #funcNames do
    local key = funcNames[i]
    love[key] = chain(love[key], function(...)
      return instance[key](instance, ...)
    end)
  end
end
