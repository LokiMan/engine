ViewPart = require '../lib/viewPart'
Cell = require './cell'
ArrowFactory = require './arrow'

CELL_WIDTH = 100
CELL_HEIGHT = CELL_WIDTH * (3 / 4)

Maze = (cells, {container, remote, gui})->
  left = (gui.gameContainer.pos.width - CELL_WIDTH * ViewPart.WIDTH) / 2
  top = 80
  container.update pos: [left, top]

  mazeDiv = div()

  Arrow = ArrowFactory remote

  arrows =
    right: Arrow [625, 124], 'right'
    left: Arrow [-50, 124], 'left'
    up: Arrow [286, -53], 'up'
    down: Arrow [286, 300], 'down'

  show = (cells)->
    view = ViewPart cells

    mazeDiv.clear()
    mazeDiv.append ->
      for row, y in view.getCells()
        for cell, x in row
          Cell [x * CELL_WIDTH, y * CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT], cell

    arrows.right.update visible: (view.canMove +1, 0)
    arrows.left.update visible: (view.canMove -1, 0)
    arrows.up.update visible: (view.canMove 0, -1)
    arrows.down.update visible: (view.canMove 0, +1)

  show cells

  # current cell
  div
    pos: [3 * CELL_WIDTH, 2 * CELL_HEIGHT, CELL_WIDTH, CELL_HEIGHT]
    style:
      backgroundColor: 'rgba(255, 255, 255, 0.3)'

  dirs = 38: 'up', 40: 'down', 37: 'left', 39: 'right'

  onKeyDown = (e)->
    dir = dirs[e.keyCode]

    if dir?
      if arrows[dir].isVisible
        remote dir
      e.preventDefault()?

  {show, onKeyDown}

module.exports = Maze
