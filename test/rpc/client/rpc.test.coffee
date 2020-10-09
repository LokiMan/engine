FakeTimers = require '../../../common/test_helpers/fakeTimers'
spy = require '../../../common/test_helpers/spy'
{prepend} = require '../../../common/appendPrepend'

describe 'Client Rpc', ->
  Rpc = require '../../../rpc/client'

  w = null
  socket = null
  ajax = null
  fakeTimers = null
  gui = {div: ((_, cb)-> cb {update: ->}), br: (->)}
  onCommand = null
  rand = null

  beforeEach ->
    gui.span = spy()
    gui.link = (->)

    onCommand = spy()

    socket = {}
    w =
      location: host: 'host', protocol: 'https:', reload: (->)
      WebSocket: (-> socket)

    ajax =
      get: spy -> abort: spy()
      head: spy()
    fakeTimers = FakeTimers()

    rand = (->)

  describe 'Connecting', ->
    createRpc = (_w = w, now = ->)->
      Rpc gui, ajax, fakeTimers, now, rand, onCommand, _w

    createWebSocket = ->
      send = createRpc()
      socket.onopen()
      return send

    createPolling = (init = '')->
      delete w.WebSocket
      firstSuccess = null
      ajax.get = (_, s, e)->
        firstSuccess = s

      send = createRpc()

      success = null
      error = null
      ajax.get = (_, s, e)->
        success = s
        error = e

      firstSuccess '1234567890' + init

      {send, success, error}

    expectConnectPolling = ->
      expect(ajax.get.calls[0][0]).to.equal '/connection/connect'

    expectConnectWebSocket = ->
      expect(socket.onmessage).to.be.a 'function'

    it 'should connect as polling if no WebSocket in window', ->
      delete w.WebSocket

      createRpc()

      expectConnectPolling()

    it 'should use MozWebSocket if exists and no WebSocket', ->
      w.MozWebSocket = w.WebSocket
      delete w.WebSocket

      createWebSocket()

      expectConnectWebSocket()

    it 'should connect as polling if error in WebSocket()', ->
      w.WebSocket = -> throw new Error 'error'

      createRpc()

      expectConnectPolling()

    it 'should connect as polling if no connect socket after 3000 msec', ->
      createRpc()

      fakeTimers.tick 3000

      expectConnectPolling()

    it 'should connect as polling if socket.onerror()', ->
      createRpc()

      socket.onerror()

      expectConnectPolling()

    it 'should connect as polling if socket.onclose()', ->
      createRpc()

      socket.onclose()

      expectConnectPolling()

    it 'should not double polling connect on repeated calling errors', ->
      createRpc()

      socket.onerror()
      socket.onclose()

      expect(ajax.get.calls).to.have.lengthOf 1

    it 'should connect as websocket if can', ->
      createWebSocket()

      expectConnectWebSocket()

    it 'should reconnect to websocket after polling by timer', ->
      createRpc()
      fakeTimers.tick 3000

      socket.onopen()

      expectConnectWebSocket()

    describe 'Sending', ->
      it 'should send from ajax.post if connected as polling', ->
        ajax.post = spy()
        send = createRpc {}

        send 'message'

        expect(ajax.post.calls).to.eql [
          ['/connection/null', {message: 'message'}]
        ]

      it 'should send from websocket if connected as ws', ->
        socket.send = spy()
        send = createWebSocket()

        send 'message'

        expect(socket.send.calls).to.eql [['message']]

    describe 'Receiving', ->
      it 'should extract commands on receive message in ws-state', ->
        createWebSocket()

        socket.onmessage data: JSON.stringify([
          ['target1.action1', 2, 3]
          ['action2', 'a', {b: 4}]
        ])

        expect(onCommand.calls).to.eql [
          ['target1', 'action1', [2, 3]]
          ['', 'action2', ['a', {b: 4}]]
        ]

      it 'should extract commands on receive message in polling-state', ->
        {success} = createPolling()

        success JSON.stringify([
          ['target1.action1', 2, 3]
          ['action2', 'a', {b: 4}]
        ])

        expect(onCommand.calls).to.eql [
          ['target1', 'action1', [2, 3]]
          ['', 'action2', ['a', {b: 4}]]
        ]

    describe 'Disconnect', ->
      checkSwitchToDisconnect = ->
        expect(gui.span.calls).to.eql [[text: 'Соединение с сервером потеряно']]

      it "should switch to disconnect from ws on receive 'disconnect'", ->
        createWebSocket()

        socket.onmessage data: 'disconnect'

        checkSwitchToDisconnect()

      it 'should not send messages on disconnected websocket', ->
        socket.send = spy()
        send = createWebSocket()
        send 'message1'

        socket.onmessage data: 'disconnect'
        send 'message2'

        expect(socket.send.calls).to.eql [['message1']]

      it 'should switch to disconnect from polling', ->
        {success} = createPolling()
        success ''

        success 'disconnect'

        checkSwitchToDisconnect()

      it 'should not send messages on disconnected polling', ->
        ajax.post = spy()
        {send, success} = createPolling()
        send 'message1'

        success 'disconnect'
        send 'message2'

        expect(ajax.post.calls).to.eql [
          ['/connection/1234567890', {message: 'message1'}]
        ]

      it 'should reload location on click reload link', ->
        linkClick = null
        gui.link = ({click})->
          linkClick = click
        w.location.reload = spy()
        createWebSocket()
        socket.onmessage data: 'disconnect'

        linkClick()

        expect(w.location.reload.calls).to.have.lengthOf 1

      it 'should disconnect if take a lot of time between intervals', ->
        dates = [0, 30000]
        now = -> dates.shift()
        createRpc w, now

        fakeTimers.tickByStep 1000, 500

        checkSwitchToDisconnect()

      it 'should not second time disconnect on repeat check', ->
        dates = [0, 30000, 30000]
        now = ->dates.shift()
        createRpc w, now

        fakeTimers.tickByStep 1000, 500
        fakeTimers.tickByStep 1000, 500

        checkSwitchToDisconnect()

      it 'should correct work on multiple calls', ->
        dates = [0, 10000, 20000, 30000]
        now = ->dates.shift()
        createRpc w, now

        fakeTimers.tickByStep 1000, 500
        fakeTimers.tickByStep 1000, 500
        fakeTimers.tickByStep 1000, 500

        expect(gui.span.calls).to.be.empty

    describe 'Reconnect', ->
      it "should switch to reconnect from ws on 'reconnect', after 100 ms", ->
        createWebSocket()

        socket.onmessage data: 'reconnect'
        expect(gui.span.calls).to.be.empty

        checkSwitchToReconnect()

      checkSwitchToReconnect = ->
        fakeTimers.tick 100
        expect(gui.span.calls[0]).to.eql [text: 'Соединение с сервером']

      it 'should switch to reconnect from ws on onerror', ->
        createWebSocket()

        socket.onerror()

        checkSwitchToReconnect()

      it 'should switch to reconnect from ws on onclose', ->
        createWebSocket()

        socket.onclose()

        checkSwitchToReconnect()

      it 'should not send messages on reconnected websocket', ->
        socket.send = spy()
        send = createWebSocket()
        send 'message1'

        socket.onmessage data: 'reconnect'
        send 'message2'

        expect(socket.send.calls).to.eql [['message1']]

      it "should switch to reconnect from polling on 'reconnect'", ->
        {success} = createPolling()

        success 'reconnect'

        checkSwitchToReconnect()

      it 'should switch to reconnect from polling on error', ->
        {error} = createPolling()

        error()

        checkSwitchToReconnect()

      it 'should not send messages on reconnected polling', ->
        ajax.post = spy()
        {send, success} = createPolling()
        send 'message1'

        success 'reconnect'
        send 'message2'

        expect(ajax.post.calls).to.eql [
          ['/connection/1234567890', {message: 'message1'}]
        ]

      it 'should trying to reconnect after random timeout', ->
        rand = -> 10
        {success} = createPolling()
        success 'reconnect'

        fakeTimers.tick 10

        expect(ajax.head.calls[0][0]).to.equal '/'

      it 'should reload location on success reconnect', ->
        w.location.reload = spy()
        rand = -> 1
        createWebSocket()
        socket.onmessage data: 'reconnect'
        onSuccess = null
        ajax.head = (_, s)->
          onSuccess = s
        fakeTimers.tick 1

        onSuccess()

        expect(w.location.reload.calls).to.have.lengthOf 1

      it 'should increase time between trying but not more 1000 msec', ->
        rand = (-> 200)
        gui.span = -> update: (->)
        ajax.head = (_, s, f)-> f()
        waitSpy = spy()
        prepend fakeTimers, 'wait', (time)-> waitSpy time
        createWebSocket()
        socket.onmessage data: 'reconnect'

        fakeTimers.tickByStep 5000, 100

        expect(waitSpy.calls[2..]).to.eql [
          [200], [400], [600], [800], [1000], [1000], [1000], [1000]
        ]
