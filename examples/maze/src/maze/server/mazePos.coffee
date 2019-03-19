MazePos = (pos)->
  getX = ->
    pos.x

  getY = ->
    pos.y

  goDir = (dx, dy)->
    if dx isnt 0
      pos.x += dx
    if dy isnt 0
      pos.y += dy

  {getX, getY, goDir}

module.exports = MazePos
