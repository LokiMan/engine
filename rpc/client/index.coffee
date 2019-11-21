UnpackAndRun = require '../lib/unpackAndRun'

TryingWebSocket = require './states/tryingWebSocket'
Polling = require './states/polling'
WebSocket = require './states/webSocket'
ReconnectFactory = require './states/reconnect'

UIPanes = require './uiPanes'

Rpc = (
  gui
  onCommand
  {wait, interval} = (require '../../common/timers')
  ajax = require '../../common/ajax'
  rand = require '../../common/rand'
  w = window
)->
  unpackAndRun = UnpackAndRun onCommand
  uiPanes = UIPanes gui, interval

  EmptyState = -> send: (->)

  currentState = EmptyState()

  State = (stateConstructor)->
    (args...)->
      currentState = stateConstructor args...

  # Convert factory constructors to states
  Reconnect = ReconnectFactory ajax, wait, rand, w, EmptyState, uiPanes
  Disconnect = State Reconnect.disconnect
  ReconnectState = State Reconnect
  WebSocketState = State WebSocket unpackAndRun, ReconnectState, Disconnect
  PollingState = State Polling unpackAndRun, ajax, ReconnectState, Disconnect

  TryingWebSocket wait, w, WebSocketState, PollingState

  (message)->
    currentState.send message

module.exports = Rpc
