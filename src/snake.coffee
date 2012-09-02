# ---------- Point ----------

class Point
  constructor: (@x, @y) ->
  
  set: (@x, @y) ->
  
  add: (otherPoint) ->
    new Point(@x + otherPoint.x, @y + otherPoint.y)
  
  addTo: (otherPoint) ->
    this.set(@x + otherPoint.x, @y + otherPoint.y)
  
  isEqualTo: (otherPoint) ->
    @x == otherPoint.x && @y == otherPoint.y

# ---------- Mushroom ----------

class Mushroom
  constructor:(@location) ->
    @life = min_mushroom_life + randomNumber(min_mushroom_life)
    @scale = mushroom_growth_delta
    @scaling = mushroom_growth_delta
  
  update: () ->
    if @scaling != 0
      @scale += @scaling
      if @scaling > 0 && @scale >= 1
        @scale = 1
        @scaling = 0
      else if @scaling < 0 && @scale < (2 * mushroom_growth_delta)
        @scale = 0
        @scaling = 0
    else
      @life--
      @scaling = -mushroom_growth_delta if @life == 1
  
  alive: () ->
    @life > 0

  draw: () ->
    retroCanvas.drawPixel(@location.x, @location.y, @scale, 'green')

# ---------- Playfield ----------

class PlayField
  constructor: (@width, @height) ->
    @mushrooms = []
    @starBursts = []
  
  update: () ->
    i = 0
    while i < @mushrooms.length
      @mushrooms[i].update()
      if !@mushrooms[i].alive()
        this.removeMushroom(@mushrooms[i])
      else
        i++
    if @mushrooms.length < max_mushrooms && randomNumber(mushroom_frequency) == 3
      this.spawnMushroom()
    i = 0
    while i < @starBursts.length
      @starBursts[i].update()
      if @starBursts[i].done()
        @starBursts.splice(i, 1)
      else
        i++
  
  spawnMushroom: () ->
    location = new Point(0, 0)
    while true
      location.set(randomNumber(playField.width), randomNumber(playField.height))
      if (this.mushroomAt(location) == undefined && !snake.hasSegmentAt(location))
        mushroom = new Mushroom(location)
        @mushrooms.push(mushroom)
        break
  
  removeMushroom: (mushroom) ->
    index = @mushrooms.indexOf(mushroom)
    if index >= 0
      @mushrooms.splice(index, 1)
  
  munchMushroom: (point) ->
    mushroom = this.mushroomAt(point)
    if mushroom?
      @starBursts.push(new StarBurst(mushroom.location))
      this.removeMushroom(mushroom)
      updateScore(score + mushroom_score)
      true
    else
      false
  
  mushroomAt: (point) ->
    find(@mushrooms, (mush) -> (mush.alive() && mush.location.isEqualTo(point)))
  
  draw: () ->
    retroCanvas.clear()
    @mushrooms.forEach((mushroom) -> mushroom.draw())
    @starBursts.forEach((starBurst) -> starBurst.draw())

# ---------- Snake ----------

class Snake
  constructor: (length) ->
    @segments = []
    @alive = true
    @direction = new Point(1, 0)
    @lastDirection = @direction
    x = Math.round(playField.width / 2)
    y = Math.round(playField.height / 2)
    for i in [0...length]
      @segments.push(new Point(x, y))
  
  head: () ->
    @segments[0]
  
  tail: () ->
    @segments[@segments.length - 1]
  
  hasSegmentAt: (location) ->
    arrayHas(@segments, (segment) -> segment.isEqualTo(location))
  
  draw: () ->
    retroCanvas.beginPath(this.head().x, this.head().y, '#f00')
    @segments.forEach((segment) -> retroCanvas.lineTo(segment.x, segment.y))
    retroCanvas.endPath()
    retroCanvas.drawPixel(this.head().x, this.head().y, 1, '#000')
    retroCanvas.drawPixel(this.tail().x, this.tail().y, 1, '#f00')
  
  move: () ->
    if this.willMeetItsDoom()
      @alive = false
    else
      if ticks % snake_grows_after_ticks == 0
        this.grow(1)
      if this.willMunchAMushroom()
        this.grow(segments_added_per_mushroom)
      for i in [(@segments.length - 1)...0]
        @segments[i].set(@segments[i - 1].x, @segments[i - 1].y)
      this.head().addTo(@direction)
      @lastDirection = @direction
  
  willMeetItsDoom: () ->
    newHead = this.head().add(@direction)
    return true if newHead.x < 0 || newHead.x >= playField.width || newHead.y < 0 || newHead.y >= playField.height
    return true if this.hasSegmentAt(newHead)
    false
  
  willMunchAMushroom: () ->
    newHead = this.head().add(@direction)
    playField.munchMushroom(newHead)
  
  grow: (length) ->
    for i in [1..length]
      @segments.push(new Point(this.tail().x, this.tail().y))
  
  changeDirection: (direction) ->
    if direction?
      d = @lastDirection.add(direction)
      if d.x != 0 || d.y != 0  # don't allow player to move back in the direction they are going
        @direction = direction

# ---------- Keyboard controller ----------

keyMap =
  '37': new Point(-1, 0)
  '39': new Point(1, 0)
  '38': new Point(0, -1)
  '40': new Point(0, 1)

class KeyboardController
  constructor: () ->
    @keysDown = []
    document.onkeydown = (event) -> keyboardController.keyDown(event)
    document.onkeyup = (event) -> keyboardController.keyUp(event)
  
  keyDown: (event) ->
    key = (event || window.event).keyCode
    if @keysDown.indexOf(key) == -1
      @keysDown.push(key)
      snake.changeDirection(keyMap[key])
    
  keyUp: (event) ->
    key = (event || window.event).keyCode
    index = @keysDown.indexOf(key)
    if index >= 0
      @keysDown.splice(index, 1)

# ---------- Scoreboard ----------

class Scoreboard
  constructor: () ->
    if localStorage?
      data = localStorage.getItem("scoreboard") || "0,0,0,0,0,0,0,0,0,0"
      @scores = data.split(',')
      for i in [0...@scores.length]
        @scores[i] = parseInt(@scores[i])
  
  addScore: (playerScore) ->
    if @scores?
      i = 0
      while i < @scores.length
        if playerScore >= @scores[i]
          @scores.splice(i, 0, playerScore)
          @scores.splice(this.scores.length - 1, 1)
          @playerScore = playerScore
          localStorage.setItem("scoreboard", @scores.toString())
          return
        i++
      @playerScore = undefined
  
  render: () ->
    if @scores?
      container = document.getElementById('highscores')
      table = "<table><tr><th colspan='2'>Local High Scores</th></tr>"
      playerScore = @playerScore
      i = 1
      @scores.forEach((score) ->
        if score == playerScore
          table += "<tr class='player'>"
          @playerScore = undefined
        else
          table += "<tr>"
        table += "<td>" + i + "</td><td>" + scoreboard.scores[i - 1] + "</td>"
        i++
      )
      table += "</table>"
      container.innerHTML = table
