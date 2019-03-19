TouchDraggable = (domElement, actions, guiElement)->
  guiElement.__unWatchTouchDraggable?()

  if actions is false
    delete guiElement.__unWatchTouchDraggable
    return

  {start, startMove, move, endMove, end, touchCheck} = actions

  started = false
  detecting = false
  startX = 0
  startY = 0

  touchStart = (e)->
    return if e.touches.length isnt 1 or started

    detecting = true

    touch = e.touches[0]
    startX = touch.clientX
    startY = touch.clientY

    start? startX, startY

  touchMove = (e)->
    return if not started and not detecting

    if detecting
      detect e

    if started
      draw e

  detect = (e)->
    detecting = false

    if touchCheck?
      started = touchCheck getDiffs(e)...
    else
      started = true

    if started
      # Если не отменить поведение по умолчанию, то второго touchmove может и
      # не быть (например, в Android). Поэтому необходимо определить swipe с
      # первого раза и отменить поведение по умолчанию – скроллинг страницы
      e.preventDefault()
      startMove? startX, startY

  getDiffs = (e)->
    touch = e.changedTouches[0]
    [Math.round(touch.clientX - startX), Math.round(touch.clientY - startY)]

  draw = (e)->
    # Отменяем поведение по умолчанию, дабы в дальнейшем срабатывали
    # обработчики touchmove и не срабатывал скролл
    e.preventDefault()
    move? getDiffs(e)...

  stopDrag = (e)->
    [dx, dy] = getDiffs e

    if started
      # Отменяем поведение по умолчанию. Например, если пользователь отпустил
      # палец на ссылке, то может произойти переход по ней, чего нам не надо.
      e.preventDefault()
      e.stopPropagation()

      detecting = started = false

      endMove? dx, dy

    end? dx, dy

  guiElement.__unWatchTouchDraggable = ->
    domElement.removeEventListener 'touchstart', touchStart
    domElement.removeEventListener 'touchmove', touchMove
    domElement.removeEventListener 'touchend', stopDrag
    domElement.removeEventListener 'touchcancel', stopDrag

  domElement.addEventListener 'touchstart', touchStart
  domElement.addEventListener 'touchmove', touchMove
  domElement.addEventListener 'touchend', stopDrag
  domElement.addEventListener 'touchcancel', stopDrag

module.exports = TouchDraggable
