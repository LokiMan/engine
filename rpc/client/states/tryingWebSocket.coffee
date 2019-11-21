TryingWebSocket = (wait, w, WebSocket, Polling)->
  Constructor = w.WebSocket ? w.MozWebSocket
  if not Constructor?
    return Polling()

  try
    protocol = 'ws'
    if w.location.protocol is 'https:'
      protocol += 's'

    socket = new Constructor "#{protocol}://#{w.location.host}/"
  catch
    return Polling()

  req = null

  timer = wait 3000, ->
    req = Polling()

  socket.onerror = socket.onclose = ->
    timer.clear()
    if not req?
      req = Polling()

  socket.onopen = ->
    timer.clear()
    req?.abort()
    WebSocket socket

module.exports = TryingWebSocket
