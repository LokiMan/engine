module.exports = (element, value, guiElement)->
  if value is true
    guiElement.getScrollTop = ->
      element.scrollTop
    return

  element.scrollTop = if value is -1
    element.scrollHeight
  else
    value
