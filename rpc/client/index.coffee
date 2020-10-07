UnpackAndRun = require '../lib/unpackAndRun'

TryingWebSocket = require './states/tryingWebSocket'
Polling = require './states/polling'
WebSocket = require './states/webSocket'
ReconnectFactory = require './states/reconnect'

UIPanes = require './uiPanes'

Rpc = (
  gui
  ajax
  {wait, interval}
  now
  rand
  onCommand
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

  # check on 'sleeping' time - when comp was wake up after sleep
  lastTimeCheck = now()

  checkTimer = interval 1000, ->
    checkTime = now()
    if checkTime - lastTimeCheck > 20000
      Disconnect()
      checkTimer.clear()
    else
      lastTimeCheck = checkTime

  (message)->
    currentState.send message

module.exports = Rpc
