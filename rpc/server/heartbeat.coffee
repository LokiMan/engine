{interval} = require '../../common/timers'
{nowDate} = require '../../common/dates'

heartbeat = (wss)->
  noop = (->)

  heartbeat = ->
    @isAlive = true
    @isAliveTime = nowDate().toISOString()

  wss.on 'connection', (ws)->
    ws.isAlive = true
    ws.on 'pong', heartbeat

  return interval 30000, ->
    wss.clients.forEach (ws)->
      if ws.isAlive
        ws.isAlive = false
        ws.ping noop
      else
        ws.terminate()

module.exports = heartbeat
