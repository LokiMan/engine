WebSocketState = (connection, Reconnect)->
  connect = (socket)->
    socket.onerror = socket.onclose = ->
      Reconnect connection

    socket.onmessage = ({data})->
      if data is 'disconnect'
        Reconnect.disconnect connection
      else if data is 'ping'
        socket.send 'pong'
      else
        connection.onMessage data

    connection.send = (message)->
      socket.send message

  {connect}

module.exports = WebSocketState
