WebSocketState = (connection, Reconnect)->
  messageNum = 0

  connect = (socket)->
    socket.onerror = socket.onclose = ->
      Reconnect connection

    socket.onmessage = ({data})->
      if data is 'disconnect'
        Reconnect.disconnect connection
      else if data is 'reconnect'
        Reconnect connection
      else
        connection.onMessage data

    connection.send = (message)->
      messageNum++
      socket.send JSON.stringify({message, messageNum})

  {connect}

module.exports = WebSocketState
