# ---------- StarBurst ----------

class StarBurst
  constructor: (@location) ->
    @spread = 0
    @delta = 1
  
  update: () ->
    @spread += @delta
    @delta *= 1.5
  
  draw: () ->
    colour = randomColour()
    d = (Math.sqrt((@spread * @spread) / 2))
    retroCanvas.drawPixel(@location.x + @spread, @location.y, 1, colour)
    retroCanvas.drawPixel(@location.x + d, @location.y + d, 1, colour)
    retroCanvas.drawPixel(@location.x, @location.y + @spread, 1, colour)
    retroCanvas.drawPixel(@location.x - d, @location.y + d, 1, colour)
    retroCanvas.drawPixel(@location.x - @spread, @location.y, 1, colour)
    retroCanvas.drawPixel(@location.x - d, @location.y - d, 1, colour)
    retroCanvas.drawPixel(@location.x, @location.y - @spread, 1, colour)
    retroCanvas.drawPixel(@location.x + d, @location.y - d, 1, colour)
  
  done: () ->
    @location.x - @spread < 0 && @location.x + @spread >= playField.width && @location.y - @spread < 0 && @location.y + @spread >= playField.height
