DISCONNECT_TIME = 5000
REFRESH_TIME = 25000

Polling = (router, onConnect, wait, uuidFor)->
  pollings = Object.create null

  randomString = uuidFor pollings

  _toBuffered = ({connection, buffer})->
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
        _toBuffered polling

      close: ->
        delete pollings[cid]
        connection.onClose()
    }

    polling = {
      connection
      buffer: []
      timer: wait DISCONNECT_TIME, connection.close
    }

    pollings[cid] = polling

    savedSend = connection.send

    onConnect connection, req

    if connection.send is savedSend # not send() on connect
      _send res, cid
      _toBuffered polling

  router.get['/connection/:cid'] = (req, res)->
    {cid} = req.params

    if (polling = pollings[cid])?
      {buffer, timer, connection} = polling

      timer.reStart()

      if buffer.length > 0
        if buffer.length is 1
          res.end buffer[0]
        else
          res.end "[#{buffer.toString()}]"
        buffer.length = 0
      else
        onClose = ->
          connection.onClose()

        res.on 'close', onClose

        refreshTimer = wait REFRESH_TIME, -> res.end()

        connection.send = (message)->
          refreshTimer.clear()
          res.removeListener 'close', onClose
          _send res, message

          _toBuffered polling
    else
      res.end()

  router.post['/connection/:cid'] = (req, res)->
    {message} = req.body
    {cid} = req.params

    if message? and (polling = pollings[cid])?
      polling.connection.onMessage message

    res.end()

module.exports = Polling
