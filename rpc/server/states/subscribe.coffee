{HEARTBEAT_TIME} = require '../config'

SubscribeState = (wait)-> (connection, res)->
  res.setHeader 'Content-Type', 'text/plain'

  timer = wait HEARTBEAT_TIME, ->
    res.end()

  onFinish = ->
    connection.close()

  res.on 'finish', onFinish

  connection.send = (message)->
    timer.clear()
    res.removeListener 'finish', onFinish
    res.end message
    connection.setSendToBuffer()

  connection.flushBuffer (messages)->
    connection.send messages

  connection.disconnect = ->
    res.removeListener 'finish', onFinish
    res.end 'disconnect'

module.exports = SubscribeState
