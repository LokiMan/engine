MouseDraggable = (document, userSelect)->
  gameContainer = document.body.firstElementChild

  (domElement, actions, guiElement)->
    guiElement.__unWatchMouseDraggable?()

    if actions is false
      delete guiElement.__unWatchMouseDraggable
      return

    {start, startMove, move, endMove, end} = actions

    currentMove = undefined
    startX = undefined
    startY = undefined

    mouseDown = (e)->
      return if e.button isnt 0

      e.preventDefault?()

      startX = e.clientX
      startY = e.clientY

      document.addEventListener 'mousemove', mouseMove
      document.addEventListener 'mouseup', mouseUp

      start? startX, startY

    currentMove = firstMove = (e)->
      userSelect gameContainer.style, 'none'
      startMove? startX, startY

      currentMove = nextMoves
      nextMoves e

    nextMoves = (e)->
      move? (e.clientX - startX), (e.clientY - startY)
      e.preventDefault?()
      e.stopPropagation?()
      return false

    mouseMove = (e)->
      currentMove e

    mouseUp = (e)->
      document.removeEventListener 'mousemove', mouseMove
      document.removeEventListener 'mouseup', mouseUp

      dx = e.clientX - startX
      dy = e.clientY - startY

      if currentMove isnt firstMove
        currentMove = firstMove

        endMove? dx, dy

        userSelect gameContainer.style, ''

      end? dx, dy

    domElement.addEventListener 'mousedown', mouseDown

    guiElement.__unWatchMouseDraggable = ->
      domElement.removeEventListener 'mousedown', mouseDown

module.exports = MouseDraggable
