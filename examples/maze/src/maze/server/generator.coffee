rand = require 'common/rand'

CELL = 0
WALL = 1
VISITED = 2

Generator = (width, height)->
  maze = new Array height

  for i in [0...height]
    row = new Array width
    for j in [0...width]
      if (i % 2 != 0) and (j % 2 != 0) and (i < height - 1 and j < width - 1)
        row[j] = CELL
      else
        row[j] = WALL
    maze[i] = row

  set = (x, y, type)->
    maze[y][x] = type

  getNeighbours = ([x, y])->
    dirs = [[1, 0], [0, 1], [-1, 0], [0, -1]]

    found = []
    for dir in dirs
      dirX = x + dir[0] * 2
      dirY = y + dir[1] * 2

      if dirX > 0 and dirX < width and dirY > 0 and dirY < height and maze[dirY][dirX] is CELL
        found.push dir

    return found

  cells = [[1, 1]]
  maxLength = 0
  maxLengthCell = []

  step = ->
    lengthPath = cells.length
    cell = cells[lengthPath - 1]
    neighbours = getNeighbours cell
    if neighbours.length > 0
      dir = neighbours[rand(0, neighbours.length - 1)]
      set cell[0] + dir[0], cell[1] + dir[1], lengthPath + 1
      set cell[0] + dir[0] * 2, cell[1] + dir[1] * 2, lengthPath + 1

      if (lengthPath + 1) > maxLength
        maxLengthCell = [cell[0] + dir[0] * 2, cell[1] + dir[1] * 2]
        maxLength = (lengthPath + 1)

      cells.push [cell[0] + dir[0] * 2, cell[1] + dir[1] * 2]
    else
      cells.pop()

  set 1, 1, VISITED

  while cells.length > 0
    step()

  for row, y in maze
    for type, x in row
      if type isnt WALL
        row[x] = CELL

  for row in maze
    str = []
    for type in row
      str.push if type is 1 then '#' else ' '
    console.log str.join ''

  return [maze, maxLengthCell]

module.exports = Generator
