DISCONNECT_TIME = 5000

Connection = (wait)-> (onFinish)->
  buffer = []
  timer = null

  bufferSend = (message)->
    buffer.push message

  setSendToBuffer = ->
    connection.send = bufferSend
    timer = wait DISCONNECT_TIME, onFinish

  flushBuffer = (cb)->
    timer?.clear()
    timer = null

    if buffer.length > 0
      cb "[#{buffer.toString()}]"
      buffer.length = 0

  close = ->
    setSendToBuffer()

  isClosed = ->
    timer?

  connection = {setSendToBuffer, flushBuffer, close, isClosed}
  return connection

module.exports = Connection
