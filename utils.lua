local function chain(loveFunc, func, after)
  return function (...)
    if loveFunc and after then
      loveFunc(...)
    end
    func(...)
    if loveFunc and not after then
      loveFunc(...)
    end
  end
end

local function loveChain(instance, funcNames)
  for i=1, #funcNames do
    local key = funcNames[i]
    love[key] = chain(love[key], function (...)
      instance[key](instance, ...)
    end)
  end
end

local function class(base)
  local Klass = {}
  Klass.__index = Klass
  setmetatable(Klass, {
    __call = function (s, ...)
      local o = {}
      if base then
        setmetatable(s, base)
        o = base(...)
      end

      o = setmetatable(o, s)
      if o.init then
        o:init(...)
      end
      return o
    end
  })

  return Klass
end

return {
  class = class,
  loveChain = loveChain,
}
