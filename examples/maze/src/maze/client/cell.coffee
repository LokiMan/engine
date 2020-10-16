Cell = ({img})-> (pos, type)->
  image = if type is 0 then 'floor_1' else 'wall_1'

  img
    src: "#{image}.png"
    pos: pos

module.exports = Cell
