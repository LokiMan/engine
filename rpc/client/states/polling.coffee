Polling = (connection, ajax, Reconnect)->
  connect = ->
    connection.send = send
    subscribe '/connect'

  subscribe = (arg = '')->
    ajax.get '/connection' + arg, (response)->
      if response is 'disconnect'
        Reconnect.disconnect connection
      else if response is 'reconnect'
        Reconnect connection
      else
        if response isnt ''
          connection.onMessage response
        subscribe()
    , ->
      Reconnect connection

  send = (message)->
    ajax.post '/connection', {message}

  {connect, send}

module.exports = Polling
