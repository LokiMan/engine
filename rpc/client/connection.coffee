timers = require '../../common/timers'

ajax = require './ajax'

Polling = require './states/polling'
WebSocketState = require './states/webSocket'
TryingWebSocket = require './states/tryingWebSocket'
ReconnectFactory = require './states/reconnect'

Connection = ->
  connection = {}

  Reconnect = ReconnectFactory ajax, timers

  polling = Polling connection, ajax, Reconnect
  webSocket = WebSocketState connection, Reconnect

  TryingWebSocket connection, polling, webSocket
  return connection

module.exports = Connection
