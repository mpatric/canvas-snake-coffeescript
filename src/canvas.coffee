# ---------- RetroCanvas ----------

class RetroCanvas
  constructor: (@canvas, width, height) ->
    @context = @canvas.getContext('2d')
    @xScale = @canvas.width / width
    @yScale = @canvas.height / height
  
  clear: () ->
    @context.clearRect(0, 0, @canvas.width, @canvas.height)
  
  drawPixel: (x, y, scale, colour) ->
    if scale > 0
      @context.fillStyle = colour
      @context.fillRect(((x + ((1 - scale) / 2)) * @xScale) + 1, ((y + ((1 - scale) / 2)) * @yScale) + 1, (scale * @xScale) - 2, (scale * @yScale) - 2)
  
  beginPath: (x, y, colour) ->
    @context.fillStyle = 'none'
    @context.strokeStyle = colour
    @context.lineWidth = ((@xScale + @yScale) / 2) - 2
    @context.beginPath((x + 0.5) * @xScale, (y + 0.5) * @yScale)
  
  lineTo: (x, y) ->
    @context.lineTo((x + 0.5) * @xScale, (y + 0.5) * @yScale)
  
  endPath: () ->
    @context.stroke()
