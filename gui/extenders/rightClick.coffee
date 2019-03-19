RightClick = (element, action, guiElement)->
  if action?
    element.oncontextmenu = ->
      action guiElement
      return false
  else
    element.oncontextmenu = null

module.exports = RightClick
