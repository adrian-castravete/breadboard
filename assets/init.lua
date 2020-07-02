local lg = love.graphics

local cache = {
  images = {}
}

local function loadImage(fileName)
  local imgs = cache.images
  local img = imgs[fileName]
  if not img then
    img = lg.newImage(fileName)
    imgs[fileName] = img
  end
  return img
end

return {
  loadImage = loadImage,
}
