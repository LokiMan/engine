REFRESH_TIME = 25000

SubscribeState = (wait)-> (connection, res)->
  res.setHeader 'Content-Type', 'text/plain'

  timer = wait REFRESH_TIME, ->
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

  connection.reconnect = ->
    res.removeListener 'finish', onFinish
    res.end 'reconnect'

module.exports = SubscribeState
