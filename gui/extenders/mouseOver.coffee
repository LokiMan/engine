MouseOver = (element, action, guiElement)->
  element.addEventListener 'mouseover', ->
    action guiElement

module.exports = MouseOver
