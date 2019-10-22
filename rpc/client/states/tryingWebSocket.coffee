TryingWebSocket = (
  connection
  polling
  webSocket
  w = window
  {wait} = require '../../../common/timers'
)->
  Constructor = w.WebSocket ? w.MozWebSocket
  if not Constructor?
    return polling.connect()

  try
    protocol = 'ws'
    if w.location.protocol is 'https:'
      protocol += 's'

    socket = new Constructor "#{protocol}://#{w.location.host}/"
  catch
    return polling.connect()

  req = null

  timer = wait 3000, ->
    if not req?
      req = polling.connect()

  socket.onerror = socket.onclose = ->
    timer.clear()
    if not req?
      req = polling.connect()

  socket.onopen = ->
    timer.clear()
    req?.abort()
    webSocket.connect socket

  connection.send = (->)

module.exports = TryingWebSocket
