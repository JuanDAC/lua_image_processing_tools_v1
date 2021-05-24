
local getLength
getLength = function(table)
  local lengthNum = 0
  for k, v in ipairs(table) do
    lengthNum = lengthNum + 1
  end
  return lengthNum
end
local forCels
forCels = function(props)
  if props.wrapper.cels == nil then
    return nil
  end
  if getLength(props.wrapper.cels) <= 0 then
    return nil
  end
  for i, cel in ipairs(props.wrapper.cels) do
    local _continue_0 = false
    repeat
      if cel == nil then
        _continue_0 = true
        break
      end
      if cel.image == nil then
        _continue_0 = true
        break
      end
      props.callback({
        index = i,
        cel = cel
      })
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
end
local forLayers
forLayers = function(props)
  if props.wrapper.layers == nil then
    return nil
  end
  if getLength(props.wrapper.layers) <= 0 then
    return nil
  end
  for i, layer in ipairs(props.wrapper.layers) do
    local _continue_0 = false
    repeat
      if layer.isGroup then
        layer.isVisible = true
        forLayers({
          wrapper = layer,
          callback = props.callback
        })
      end
      if layer == nil then
        _continue_0 = true
        break
      end
      if layer.isImage then
        props.callback({
          index = i,
          layer = layer
        })
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
end
local ImageProcessing
do
  local _class_0
  local _base_0 = {
    radians = function(self, props)
      return (props.angle * math.pi) / 180
    end,
    rotate = function(self, angle)
      return function(props)
        return {
          x = ((props.x * math.cos(self:radians({
            angle = angle
          }))) - (props.y * math.sin(self:radians({
            angle = angle
          })))),
          y = ((props.y * math.cos(self:radians({
            angle = angle
          }))) + (props.x * math.sin(self:radians({
            angle = angle
          }))))
        }
      end
    end,
    processedImage = function(self, props)
      local image = Image(props.cel.image.width, props.cel.image.height, ColorMode.RGB)
      for x = 0, props.cel.image.width - 1, 1 do
        for y = 0, props.cel.image.height - 1, 1 do
          local pixel = props.cel.image:getPixel(x, y)
          local position = { }
          if props.transform ~= nil then
            position = props.transform({
              x = x,
              y = y
            })
          else
            position = {
              x = x,
              y = y
            }
          end
          image:drawPixel(position.x, position.y, props.pixelHandler({
            pixel = pixel,
            cel = props.cel
          }))
        end
      end
      local position = props.cel.position
      if props.transform ~= nil then
        position = props.transform(position)
      end
      return image, Point(position.x, position.y)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "ImageProcessing"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ImageProcessing = _class_0
end
local PixelHandlers
do
  local _class_0
  local _base_0 = {
    negativePixel = function(self, pixel)
      return 255 - pixel
    end,
    blackAndWhitePixel = function(self, range)
      return function(pixel)
        local digital = 0
        if pixel > range then
          digital = 255
        end
        return digital
      end
    end,
    without = function(self, props)
      return props.pixel
    end,
    grayScale = function(self, props)
      local gray = math.floor((app.pixelColor.rgbaR(props.pixel) + app.pixelColor.rgbaG(props.pixel) + app.pixelColor.rgbaB(props.pixel)) / 3)
      return app.pixelColor.rgba(gray, gray, gray, app.pixelColor.rgbaA(props.pixel))
    end,
    maximumGray = function(self, props)
      local gray = math.max(app.pixelColor.rgbaR(props.pixel), app.pixelColor.rgbaG(props.pixel), app.pixelColor.rgbaB(props.pixel))
      return app.pixelColor.rgba(gray, gray, gray, app.pixelColor.rgbaA(props.pixel))
    end,
    minimumGray = function(self, props)
      local gray = math.min(app.pixelColor.rgbaR(props.pixel), app.pixelColor.rgbaG(props.pixel), app.pixelColor.rgbaB(props.pixel))
      return app.pixelColor.rgba(gray, gray, gray, app.pixelColor.rgbaA(props.pixel))
    end,
    negativeGray = function(self, props)
      local gray = self:negativePixel(math.floor((app.pixelColor.rgbaR(props.pixel) + app.pixelColor.rgbaG(props.pixel) + app.pixelColor.rgbaB(props.pixel)) / 3))
      return app.pixelColor.rgba(gray, gray, gray, app.pixelColor.rgbaA(props.pixel))
    end,
    negativeColor = function(self, props)
      return app.pixelColor.rgba(self:negativePixel(app.pixelColor.rgbaR(props.pixel)), self:negativePixel(app.pixelColor.rgbaG(props.pixel)), self:negativePixel(app.pixelColor.rgbaB(props.pixel)), app.pixelColor.rgbaA(props.pixel))
    end,
    blackAndWhite = function(self, range)
      return function(props)
        local digital = self:blackAndWhitePixel(range)(math.floor((app.pixelColor.rgbaR(props.pixel) + app.pixelColor.rgbaG(props.pixel) + app.pixelColor.rgbaB(props.pixel)) / 3))
        return app.pixelColor.rgba(digital, digital, digital, app.pixelColor.rgbaA(props.pixel))
      end
    end,
    colorize = function(self, props)
      local percentage_of_red = 225 / 255
      local percentage_of_green = 140 / 255
      local percentage_of_blue = 244 / 255
      local pixel = self:maximumGray(props)
      local color_of_red = math.max(math.min(app.pixelColor.rgbaR(pixel) * percentage_of_red, 255), 0)
      local color_of_green = math.max(math.min(app.pixelColor.rgbaG(pixel) * percentage_of_green, 255), 0)
      local color_of_blue = math.max(math.min(app.pixelColor.rgbaB(pixel) * percentage_of_blue, 255), 0)
      return app.pixelColor.rgba(color_of_red, color_of_green, color_of_blue, app.pixelColor.rgbaA(props.pixel))
    end,
    colorizeG = function(self, props)
      local percentage_of_red = 225 / 255
      local percentage_of_green = 140 / 255
      local percentage_of_blue = 244 / 255
      local pixel = self:maximumGray(props)
      local color_of_red = math.max(math.min(app.pixelColor.rgbaR(pixel) * percentage_of_red, 255), 0)
      local color_of_green = math.max(math.min(app.pixelColor.rgbaG(pixel) * percentage_of_green, 255), 0)
      local color_of_blue = math.max(math.min(app.pixelColor.rgbaB(pixel) * percentage_of_blue, 255), 0)
      return app.pixelColor.rgba(color_of_red, color_of_green, color_of_blue, app.pixelColor.rgbaA(props.pixel))
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function() end,
    __base = _base_0,
    __name = "PixelHandlers"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  PixelHandlers = _class_0
end
local main
main = function()
  local sprite = app.activeSprite
  if (sprite) then
    local currentFrame = sprite:newEmptyFrame()
    forLayers({
      wrapper = sprite,
      callback = function(props)
        local layer = props.layer
        return forCels({
          wrapper = layer,
          callback = function(props)
            local angle = -4
            local image, point = ImageProcessing:processedImage({
              cel = props.cel,
              pixelHandler = (function()
                local _base_0 = PixelHandlers
                local _fn_0 = _base_0.maximumGray
                return function(...)
                  return _fn_0(_base_0, ...)
                end
              end)()
            })
            return sprite:newCel(layer, currentFrame, image, point)
          end
        })
      end
    })
    return true
  end
end
return main()
