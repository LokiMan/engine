EventEmitter = require '../../common/eventEmitter'

WIDTH = 1024
MIN_HEIGHT = 748

GameContainer = (
  guiElement
  w = window
  document = w.document
  timers = (require '../../common/timers')
)->
  calcHeight = ->
    Math.max MIN_HEIGHT, document.documentElement.clientHeight

  height = calcHeight()

  guiElement.update
    pos: {width: WIDTH, height}
    style:
      position: 'relative'
      margin: '0 auto'
      overflow: 'hidden'

  timerResize = null

  w.onresize = ->
    timerResize?.clear()

    timerResize = timers.wait 100, ->
      height = calcHeight()
      guiElement.update pos: {height}
      guiElement.emit 'resize', height

  EventEmitter guiElement

module.exports = GameContainer
