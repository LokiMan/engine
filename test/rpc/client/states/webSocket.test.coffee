spy = require '../../../../common/test_helpers/spy'

describe 'WebSocketState', ->
  WebSocketState = require '../../../../rpc/client/states/webSocket'

  describe 'connect', ->
    it 'should set connection.send to call socket.send', ->
      message = 'msg'
      connection = {}
      socket = send: spy()
      webSocket = WebSocketState connection
      webSocket.connect socket

      connection.send message

      expect(socket.send.calls).to.eql [[message]]

    it 'should call connection.onMessage on socket.onmessage', ->
      message = 'msg'
      connection = onMessage: spy()
      socket = {}
      webSocket = WebSocketState connection
      webSocket.connect socket

      socket.onmessage data: message

      expect(connection.onMessage.calls).to.eql [[message]]
