MouseClick = (element, action, guiElement)->
  guiElement.__unWatchMouseClick?()

  if not action
    delete guiElement.__unWatchMouseClick
    return

  click = (e)->
    action guiElement, e

  element.addEventListener 'click', click

  guiElement.__unWatchMouseClick = ->
    element.removeEventListener 'click', click

module.exports = MouseClick
