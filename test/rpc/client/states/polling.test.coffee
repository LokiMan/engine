spy = require '../../../../common/test_helpers/spy'

describe 'Polling', ->
  Polling = require '../../../../rpc/client/states/polling'

  describe 'connect', ->
    it 'should set connection send to self.send', ->
      connection = {}
      polling = Polling connection, get: (->)

      polling.connect()

      expect(connection.send).to.be.a 'function'

    it 'should subscribe', ->
      connection = onMessage: spy()
      callback = null
      ajax = get: (url, _callback)-> callback = _callback
      polling = Polling connection, ajax
      polling.connect()

      callback 'msg1'

      expect(connection.onMessage.calls).to.eql [['msg1']]

  describe 'send', ->
    it 'should call ajax.post', ->
      post = spy()
      polling = Polling {}, {post}

      polling.send 'msg1'

      expect(post.calls).to.eql [['/connection', {message: 'msg1'}]]
