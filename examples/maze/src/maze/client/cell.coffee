Cell = (pos, type)->
  image = if type is 0 then 'floor_1' else 'wall_1'

  img
    src: "/res/img/#{image}.png"
    pos: pos

module.exports = Cell
