

getLength = (table) -> 
	lengthNum = 0
	for k, v in ipairs(table)
		lengthNum += 1
	return lengthNum

forCels = (props) ->
	if props.wrapper.cels == nil
		return nil
	if getLength(props.wrapper.cels) <= 0
		return nil
	for i, cel in ipairs(props.wrapper.cels)
		if cel == nil
			continue
		if cel.image == nil
			continue
		props.callback(index: i, cel: cel)

forLayers = (props) ->
	if props.wrapper.layers == nil
		return nil
	if getLength(props.wrapper.layers) <= 0
		return nil
	for i, layer in ipairs(props.wrapper.layers)
		if layer.isGroup
			layer.isVisible = true
			forLayers(wrapper: layer, callback: props.callback)
		if layer == nil
			continue
		if layer.isImage
			props.callback(index: i, layer: layer)

image processing
class ImageProcessing 
	radians: (props) => 
		return (props.angle * math.pi) / 180
	rotate: (angle) => (props) -> 
		return {
			x: ((props.x * math.cos(@radians(angle: angle))) - (props.y * math.sin(@radians(angle: angle)))),
			y: ((props.y * math.cos(@radians(angle: angle))) + (props.x * math.sin(@radians(angle: angle)))),
		}
	processedImage: (props) =>
		image = Image(props.cel.image.width, props.cel.image.height, ColorMode.RGB)
		for x = 0, props.cel.image.width - 1, 1
			for y = 0, props.cel.image.height - 1, 1
				pixel = props.cel.image\getPixel(x, y)
				position = {}
				if props.transform != nil 
					position = props.transform(x: x, y: y)
				else
					position = {x: x, y: y}
				image\drawPixel(position.x, position.y, props.pixelHandler(pixel: pixel, cel: props.cel))
		position = props.cel.position
		if props.transform != nil
			position = props.transform(position)
		return image, Point(position.x, position.y)




class PixelHandlers 
	negativePixel: (pixel) => 
		return 255 - pixel
	blackAndWhitePixel: (range) => (pixel) -> 
		digital = 0
		if pixel > range 
			digital = 255
		return digital
	without: (props) =>
		return props.pixel
	grayScale: (props) =>
		gray = math.floor((app.pixelColor.rgbaR(props.pixel) + app.pixelColor.rgbaG(props.pixel) + app.pixelColor.rgbaB(props.pixel)) / 3)
		return app.pixelColor.rgba(gray, gray, gray, app.pixelColor.rgbaA(props.pixel))
	maximumGray: (props) =>
		gray = math.max(app.pixelColor.rgbaR(props.pixel), app.pixelColor.rgbaG(props.pixel), app.pixelColor.rgbaB(props.pixel))
		return app.pixelColor.rgba(gray, gray, gray, app.pixelColor.rgbaA(props.pixel))
	minimumGray: (props) =>
		gray = math.min(app.pixelColor.rgbaR(props.pixel), app.pixelColor.rgbaG(props.pixel), app.pixelColor.rgbaB(props.pixel))
		return app.pixelColor.rgba(gray, gray, gray, app.pixelColor.rgbaA(props.pixel))
	negativeGray: (props) =>
		gray = @negativePixel(math.floor((app.pixelColor.rgbaR(props.pixel) + app.pixelColor.rgbaG(props.pixel) + app.pixelColor.rgbaB(props.pixel)) / 3))
		return app.pixelColor.rgba(gray, gray, gray, app.pixelColor.rgbaA(props.pixel))
	negativeColor: (props) =>
		return app.pixelColor.rgba(@negativePixel(app.pixelColor.rgbaR(props.pixel)), @negativePixel(app.pixelColor.rgbaG(props.pixel)), @negativePixel(app.pixelColor.rgbaB(props.pixel)), app.pixelColor.rgbaA(props.pixel))
	blackAndWhite: (range) => (props) ->
		digital = @blackAndWhitePixel(range)(math.floor((app.pixelColor.rgbaR(props.pixel) + app.pixelColor.rgbaG(props.pixel) + app.pixelColor.rgbaB(props.pixel)) / 3))
		return app.pixelColor.rgba(digital, digital, digital, app.pixelColor.rgbaA(props.pixel))
	colorize: (props) =>
		percentage_of_red = 225 / 255
		percentage_of_green = 140 / 255
		percentage_of_blue = 244 / 255
		pixel = @maximumGray(props)
		color_of_red = math.max(math.min(app.pixelColor.rgbaR(pixel) * percentage_of_red , 255), 0)
		color_of_green = math.max(math.min(app.pixelColor.rgbaG(pixel) * percentage_of_green , 255), 0)
		color_of_blue = math.max(math.min(app.pixelColor.rgbaB(pixel) * percentage_of_blue , 255), 0)
		return app.pixelColor.rgba(color_of_red, color_of_green, color_of_blue, app.pixelColor.rgbaA(props.pixel))
	colorizeG: (props) =>
		percentage_of_red = 225 / 255
		percentage_of_green = 140 / 255
		percentage_of_blue = 244 / 255
		pixel = @maximumGray(props)
		color_of_red = math.max(math.min(app.pixelColor.rgbaR(pixel) * percentage_of_red , 255), 0)
		color_of_green = math.max(math.min(app.pixelColor.rgbaG(pixel) * percentage_of_green , 255), 0)
		color_of_blue = math.max(math.min(app.pixelColor.rgbaB(pixel) * percentage_of_blue , 255), 0)
		return app.pixelColor.rgba(color_of_red, color_of_green, color_of_blue, app.pixelColor.rgbaA(props.pixel))
		

main = () ->
	sprite = app.activeSprite
	if (sprite)
		currentFrame = sprite\newEmptyFrame()
		forLayers(wrapper: sprite, callback: (props) ->
			layer = props.layer
			forCels(wrapper: layer, callback: (props) ->
				angle = -4
				image, point = ImageProcessing\processedImage(cel: props.cel, pixelHandler: PixelHandlers\colorize)
				sprite\newCel(layer, currentFrame, image, point)
			)
		)
		return true
main!