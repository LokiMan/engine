RECONNECTION_DELAY = 1000
#@ifndef DEVELOPMENT
RECONNECTION_DELAY_MAX = 5000
#@endif
#@ifdef DEVELOPMENT
RECONNECTION_DELAY_MAX = 1000
#@endif
RANDOMIZATION_FACTOR = 0.5
COEF = RECONNECTION_DELAY * RANDOMIZATION_FACTOR

ReconnectFactory = (ajax, wait, rand, w, toEmpty, uiPanes)->
  disconnected = false

  Reconnect = ->
    return if disconnected

    wait 100, uiPanes.reconnect

    currentTimeout = 0

    reconnect = ->
      nextTimeout = rand(RECONNECTION_DELAY - COEF,  RECONNECTION_DELAY + COEF)
      currentTimeout += nextTimeout
      if currentTimeout >= RECONNECTION_DELAY_MAX
        currentTimeout = RECONNECTION_DELAY_MAX

      wait currentTimeout, ->
        ajax.head '/', ->
          w.location.reload()
        , reconnect

    reconnect()

    return toEmpty()

  Reconnect.disconnect = ->
    disconnected = true

    uiPanes.disconnect ->
      w.location.reload()

    return toEmpty()

  return Reconnect

module.exports = ReconnectFactory
