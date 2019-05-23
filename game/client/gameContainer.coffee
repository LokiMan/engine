EventEmitter = require '../../common/eventEmitter'

WIDTH = 1024
MIN_HEIGHT = 748

GameContainer = (
  guiElement
  isStandalone
  w = window
  document = w.document
  timers = (require '../../common/timers')
)->
  calcHeight = ->
    Math.max MIN_HEIGHT, document.documentElement.clientHeight

  height = calcHeight()
  prevHeight = height

  isPrevented = false

  prevent = (e)->
    if not e._isScroller
      e.preventDefault()

  if isStandalone and document.documentElement.clientHeight >= MIN_HEIGHT
    document.body.addEventListener 'touchmove', prevent, passive: false
    isPrevented = true

  guiElement.update
    pos: {width: WIDTH, height}
    style:
      position: 'relative'
      margin: '0 auto'
      overflow: 'hidden'

  timerResize = null

  onResize = ->
    timerResize?.clear()

    timerResize = timers.wait 100, ->
      height = calcHeight()

      if height isnt prevHeight
        prevHeight = height

        guiElement.update pos: {height}
        guiElement.emit 'resize', height

        return if not isStandalone

        if document.documentElement.clientHeight >= MIN_HEIGHT
          if not isPrevented
            document.body.addEventListener 'touchmove', prevent, passive: false
            isPrevented = true
        else if isPrevented
          document.body.removeEventListener 'touchmove', prevent, passive: false
          isPrevented = false

  w.onresize = onResize
  w.addEventListener 'orientationchange', onResize

  EventEmitter guiElement

module.exports = GameContainer
