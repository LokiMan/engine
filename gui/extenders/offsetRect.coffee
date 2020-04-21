module.exports = (element, value, guiElement)->
  body = document.body
  docElem = document.documentElement
  gameContainer = body.firstElementChild

  if value is true
    guiElement.getOffsetRect = ->
      rect = element.getBoundingClientRect()

      scrollLeft = window.pageXOffset or (docElem.scrollLeft ? body.scrollLeft)
      scrollTop = window.pageYOffset or (docElem.scrollTop ? body.scrollTop)

      clientLeft = docElem.clientLeft or body.clientLeft or 0
      clientTop = docElem.clientTop or body.clientTop or 0

      left = rect.left - gameContainer.offsetLeft + scrollLeft - clientLeft
      top = rect.top + scrollTop - clientTop

      return {
        left: Math.round left
        top: Math.round top
        width: rect.width
        height: rect.height
      }

    guiElement.getBoundingClientRect = ->
      element.getBoundingClientRect()
