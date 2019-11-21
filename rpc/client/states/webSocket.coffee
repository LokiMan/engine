WebSocketState = (onMessage, Reconnect, Disconnect)->
  (socket)->
    socket.onerror = socket.onclose = ->
      Reconnect()

    socket.onmessage = ({data})->
      if data is 'disconnect'
        Disconnect()
      else if data is 'reconnect'
        Reconnect()
      else
        onMessage data

    send: (message)->
      socket.send message

module.exports = WebSocketState
