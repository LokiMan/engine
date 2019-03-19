# Этот объект используется для работы с видимой частью лабиринта - для отправки
# этой части с сервера на клиент, для отображения на клиенте и для определения
# возможности перехода (как на клиенте так и на сервере)

WIDTH = 7
HEIGHT = 5

HALF_WIDTH = (WIDTH - 1) / 2
HALF_HEIGHT = (HEIGHT - 1) / 2

CELL = 0
WALL = 1

cells = new Array HEIGHT
for _, y in cells
  cells[y] = new Array WIDTH

ViewPart = (mazeCells, x = HALF_WIDTH, y = HALF_HEIGHT)->
  for vy in [0 ... HEIGHT]
    for vx in [0 ... WIDTH]
      cx = vx - (HALF_WIDTH - x)
      cy = vy - (HALF_HEIGHT - y)
      cells[vy][vx] = (mazeCells[cy]?[cx]) ? WALL

  getCells = ->
    return cells

  canMove = (dx, dy)->
    return cells[HALF_HEIGHT + dy]?[HALF_WIDTH + dx] is CELL

  {getCells, canMove}

ViewPart.WIDTH = WIDTH
ViewPart.HEIGHT = HEIGHT

module.exports = ViewPart
