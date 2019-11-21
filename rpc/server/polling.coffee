DISCONNECT_TIME = 5000
REFRESH_TIME = 25000

Polling = (
  router, onConnect
  RandomString = (require '../../common/rand').RandomString
  wait = (require '../../common/timers').wait
)->
  pollings = Object.create null

  randomString = RandomString pollings

  _toBuffered = (polling, cid)->
    {connection, buffer} = polling

    connection.close = ->
      delete pollings[cid]
      connection.onClose()

    polling.timer = wait DISCONNECT_TIME, connection.close

    connection.send = (message)->
      buffer.push message

  _send = (res, message)->
    res.setHeader 'Content-Type', 'text/plain'
    res.end message

  router.get['/connection/connect'] = (req, res)->
    cid = randomString 10

    connection = {
      send: (message)->
        _send res, cid + message
        _toBuffered polling, cid
    }

    polling = {
      connection
      buffer: []
    }

    pollings[cid] = polling

    onConnect connection, req

    if not polling.timer? # not sent init on connect
      _send res, cid
      _toBuffered polling, cid

  router.get['/connection/:cid'] = (req, res)->
    {cid} = req.params

    if (polling = pollings[cid])?
      {buffer, timer, connection} = polling

      if buffer.length > 0
        if buffer.length is 1
          res.end buffer[0]
        else
          res.end "[#{buffer.toString()}]"
        buffer.length = 0
        timer.reStart()
      else
        timer.clear()

        onClose = ->
          connection.onClose()

        res.on 'close', onClose

        refreshTimer = wait REFRESH_TIME, -> res.end()

        connection.send = (message)->
          refreshTimer.clear()
          res.removeListener 'close', onClose
          _send res, message

          _toBuffered polling, cid
    else
      res.end()

  router.post['/connection/:cid'] = (req, res)->
    {message} = req.body
    {cid} = req.params

    if message? and (polling = pollings[cid])?
      polling.connection.onMessage message

    res.end()

module.exports = Polling
