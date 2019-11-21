Polling = (onMessage, ajax, Reconnect, Disconnect)->
  ->
    cid = null

    req = ajax.get '/connection/connect', (response)->
      cid = response[0...10]
      onMessage response[10...]
      subscribe()
    , Reconnect

    subscribe = ->
      req = ajax.get "/connection/#{cid}", (response)->
        if response is 'disconnect'
          Disconnect()
        else if response is 'reconnect'
          Reconnect()
        else
          if response isnt ''
            onMessage response
          subscribe()
      , Reconnect

    abort: ->
      req.abort()

    send: (message)->
      ajax.post "/connection/#{cid}", {message}

module.exports = Polling
