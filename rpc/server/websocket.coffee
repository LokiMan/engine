WebSocket = (webSocketServer, onConnect)->
  webSocketServer.on 'connection', (socket, req)->
    connection = {
      send: socket.send.bind socket
      close: socket.close.bind socket
    }

    onConnect connection, req

    socket.on 'message', connection.onMessage
    socket.on 'close', ->
      connection.onClose()

module.exports = WebSocket
