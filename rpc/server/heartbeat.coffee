heartbeat = (wss, interval)->
  noop = (->)

  heartbeat = ->
    @isAlive = true

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
