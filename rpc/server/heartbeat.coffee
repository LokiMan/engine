HEARTBEAT_TIME = 30000

Heartbeat = (wss, {interval} = require('../../common/timers'))->
  noop = (->)

  heartbeat = ->
    @isAlive = true

  wss.on 'connection', (ws)->
    ws.isAlive = true
    ws.on 'pong', heartbeat

  return interval HEARTBEAT_TIME, ->
    wss.clients.forEach (ws)->
      if ws.isAlive
        ws.isAlive = false
        ws.ping noop
      else
        ws.terminate()

module.exports = Heartbeat
