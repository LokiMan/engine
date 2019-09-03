WebSocketState = (connection, socket)->
  prevMessageNum = 0

  socket.on 'message', (messageData)->
    {message, messageNum} = JSON.parse(messageData)

    if messageNum != (prevMessageNum + 1)
      console.error "ERROR MESSAGE ORDER: #{messageNum}, #{prevMessageNum}, #{message}"
    prevMessageNum++

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

  connection.reconnect = ->
    socket.removeListener 'close', onFinish
    socket.send 'reconnect'
    socket.close()

module.exports = WebSocketState
