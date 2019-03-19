querystring = require 'querystring'

parseBody = (req, limit, callback)->
  body = []
  received = 0

  _onData = (chunk)->
    received += chunk.length
    if received > limit
      req.removeListener 'end', _onEnd
      callback 'entity.too.large'
    else
      body.push chunk

  _onEnd = ->
    req.body = querystring.parse Buffer.concat(body).toString()
    callback null

  req
    .on 'data', _onData
    .on 'end', _onEnd

module.exports = parseBody