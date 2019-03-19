MouseOut = (element, action, guiElement)->
  element.addEventListener 'mouseout', ->
    action guiElement

module.exports = MouseOut
