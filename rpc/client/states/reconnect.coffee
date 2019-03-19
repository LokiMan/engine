emptyFunction = require '../../../common/emptyFunction'
rand = require '../../../common/rand'

RECONNECTION_DELAY = 1000
#@ifndef DEVELOPMENT
RECONNECTION_DELAY_MAX = 5000
#@endif
#@ifdef DEVELOPMENT
RECONNECTION_DELAY_MAX = 1000
#@endif
RANDOMIZATION_FACTOR = 0.5
COEF = RECONNECTION_DELAY * RANDOMIZATION_FACTOR

modalPane = (next)->
  div style:
    zIndex: 150
    position: 'fixed'
    left: 0
    top: 0
    width: '100%'
    height: '100%'
    backgroundColor: 'rgba(0, 0, 0, 0.5)'
  , ->
    div
      style:
        position: 'relative'
        width: '202px'
        top: '50%'
        padding: '20px'
        margin: '0 auto'
        backgroundColor: 'white'
        color: 'black'
        transform: 'translateY(-50%)'
    , next

ReconnectFactory = (ajax, {wait})->
  disconnected = false

  Reconnect = (connection)->
    return if disconnected

    connection.send = emptyFunction

    wait 100, ->
      modalPane ->
        span text: 'Соединение с сервером'

        text = ''
        dotsSpan = span {text}

        setInterval ->
          text += '.'
          if text is '....'
            text = ''
          dotsSpan.update {text}
        , 500

    currentTimeout = 0

    reconnect = ->
      nextTimeout = rand(RECONNECTION_DELAY - COEF,  RECONNECTION_DELAY + COEF)
      currentTimeout += nextTimeout
      if currentTimeout >= RECONNECTION_DELAY_MAX
        currentTimeout = RECONNECTION_DELAY_MAX

      wait currentTimeout, ->
        ajax.head '/', ->
          window.location.reload()
        , reconnect

    reconnect()

  Reconnect.disconnect = (connection)->
    disconnected = true

    connection.send = emptyFunction

    modalPane (parent)->
      parent.update
        pos: width: 270
        style: textAlign: 'center'

      span text: 'Соединение с сервером потеряно'
      br()
      br()
      link text: 'Обновить', click: ->
        window.location.reload()

  return Reconnect

module.exports = ReconnectFactory
