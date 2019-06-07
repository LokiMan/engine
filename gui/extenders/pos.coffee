transform = require './style/transform'

Pos = ({style}, pos, guiElement)->
  if guiElement.animated
    style.position = 'absolute'

    style.left = '0'
    style.top = '0'

    [left, top] = pos

    if pos.length > 2
      [..., width, height] = pos
      style.width = width + if typeof width is 'number' then 'px' else ''
      style.height = height + if typeof height is 'number' then 'px' else ''
    else
      pos = (c for c in guiElement.pos)
      pos[0] = left
      pos[1] = top

    transform style, "translate3d(#{left}px, #{top}px, 0px)"

    guiElement.pos = pos
  else
    guiElement.pos ?= {}

    if Array.isArray(pos)
      style.position = 'absolute'

      for n, i in ['left', 'top', 'width', 'height']
        if (v = pos[i])?
          style[n] = v + if typeof v is 'number' then 'px' else ''
          guiElement.pos[n] = v
          guiElement.pos[i] = v
    else
      if pos['left']? or pos['top']? or pos['right']? or pos['bottom']?
        style.position = 'absolute'

      for n, i in ['left', 'top', 'width', 'height', 'right', 'bottom']
        if (v = pos[n])?
          style[n] = v + if typeof v is 'number' then 'px' else ''
          guiElement.pos[n] = v
          guiElement.pos[i] = v

  return

module.exports = Pos
