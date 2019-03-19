spy = require '../../../../common/test_helpers/spy'
EventEmitter = require '../../../../common/eventEmitter'

describe 'WebSocketState', ->
  WebSocketState = require '../../../../rpc/server/states/webSocket'

  it 'should call socket.send on send', ->
    message = 'msg'
    connection = flushBuffer: (->)
    socket = send: spy(), on: (->)
    WebSocketState connection, socket

    connection.send message

    expect(socket.send.calls).to.eql [[message]]

  it "should call connection.onMessage on event 'message'", ->
    message = 'msg'
    connection = onMessage: spy(), flushBuffer: (->)
    socket = EventEmitter()
    WebSocketState connection, socket

    socket.emit 'message', message

    expect(connection.onMessage.calls).to.eql [[message]]

  it 'should call connection.close on socket close', ->
    connection = flushBuffer: (->), close: spy()
    events = {}
    socket = on: (event, cb)-> events[event] = cb
    WebSocketState connection, socket

    events['close']()

    expect(connection.close.calls).to.not.empty
