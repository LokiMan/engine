WebSocketState = (connection, socket)->
  socket.on 'message', (message)->
    connection.onMessage message

  connection.flushBuffer (messages)->
    socket.send messages

  onFinish = ->
    connection.close()

  socket.on 'close', onFinish

  connection.send = (message)->
    socket.send message

  connection.disconnect = ->
    socket.removeListener 'close', onFinish
    socket.send 'disconnect'
    socket.close()

module.exports = WebSocketState
