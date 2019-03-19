# Используется на мобильных тач-устройствах вместо onclick для того,
# чтобы избежать паузы в 300 мсек, которую автоматически делают браузеры
# на таких устройствах.

BOUNDARY = 10

TouchClick = (element, action, guiElement)->
  guiElement.__unWatchClick?()

  if not action
    delete guiElement.__unWatchClick
    return

  trackingClick = false
  touchStartX = 0
  touchStartY = 0

  onTouchStart = (event)->
    return if event.touches.length > 1

    touch = event.touches[0]
    touchStartX = touch.pageX
    touchStartY = touch.pageY
    trackingClick = true

  onTouchMove = (event)->
    return if not trackingClick

    touch = event.changedTouches[0]

    if Math.abs(touch.pageX - touchStartX) > BOUNDARY ||
      Math.abs(touch.pageY - touchStartY) > BOUNDARY
        trackingClick = false

    return

  onTouchEnd = (event)->
    return if not trackingClick

    trackingClick = false
    action guiElement, event

  onTouchCancel = ->
    trackingClick = false

  element.addEventListener 'touchstart', onTouchStart, false
  element.addEventListener 'touchmove', onTouchMove, false
  element.addEventListener 'touchend', onTouchEnd, false
  element.addEventListener 'touchcancel', onTouchCancel, false

  guiElement.__unWatchClick = ->
    element.removeEventListener 'touchstart', onTouchStart, false
    element.removeEventListener 'touchmove', onTouchMove, false
    element.removeEventListener 'touchend', onTouchEnd, false
    element.removeEventListener 'touchcancel', onTouchCancel, false

    delete guiElement.__unWatchClick

module.exports = TouchClick
