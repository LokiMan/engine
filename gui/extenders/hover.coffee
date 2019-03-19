Hover = (element, props, guiElement)->
  guiElement.__unWatchHover?()

  return if not props?

  savedProps = null

  mouseOver = ->
    savedProps = {}

    for key, value of props
      savedProps[key] = guiElement.style[key] ? ''

    guiElement.update style: props
    return

  mouseOut = ->
    guiElement.update style: savedProps
    return

  element.addEventListener 'mouseover', mouseOver
  element.addEventListener 'mouseout', mouseOut

  guiElement.__unWatchHover = ->
    element.removeEventListener 'mouseover', mouseOver, false
    element.removeEventListener 'mouseout', mouseOut, false

module.exports = Hover
