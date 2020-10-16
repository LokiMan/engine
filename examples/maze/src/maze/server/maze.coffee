ViewPart = require '../lib/viewPart'
Generator = require './generator'
MazePos = require './mazePos'

Maze = ({storage, cron, remote, common: {rand}})-> ([width, height])->
  repository = storage.Repository 'mazePos', MazePos

  maze = storage.get ['maze']

  if not maze?
    [cells] = Generator rand, width, height
    maze = {cells}
    storage.set ['maze'], maze

  toClient = (player)->
    uid = player.id

    if not (pos = repository.get uid)?
      initial = {x: 1, y: 1}
      pos = repository.add uid, initial

    return _show pos

  _show = (pos)->
    return ViewPart(maze.cells, pos.getX(), pos.getY()).getCells()

  $remotes$ =
    up: (player)->    go player, 0, -1
    down: (player)->  go player, 0, +1
    left: (player)->  go player, -1, 0
    right: (player)-> go player, +1, 0

  go = (player, dx, dy)->
    pos = repository.get player.id

    view = ViewPart maze.cells, pos.getX(), pos.getY()

    if view.canMove dx, dy
      pos.goDir dx, dy
      remote player, 'show', _show pos

  {toClient, $remotes$}

module.exports = Maze
