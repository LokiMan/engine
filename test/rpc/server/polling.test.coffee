spy = require '../../../common/test_helpers/spy'
FakeTimers = require '../../../common/test_helpers/fakeTimers'

describe 'Polling server', ->
  Polling = require '../../../rpc/server/polling'

  fakeTimers = null

  beforeEach ->
    fakeTimers = FakeTimers()

  createPolling = ({
    router = {get: {}, post: {}}, onConnect = (->)
    RandomString = (-> -> '1234567890')
  } = {})->
    Polling router, onConnect, fakeTimers.wait, RandomString
    {router}

  connectPolling = ->
    connection = null
    onConnect = (conn)->
      connection = conn
      connection.onClose = spy()
      connection.onMessage = spy()
      connection.send 'init'
    {router} = createPolling {onConnect}

    cid = null
    res = createRes end: ((m)-> cid = m[0...10])
    router.get['/connection/connect'] {}, res
    {router, cid, connection, res}

  createRes = ({end = spy()} = {})->
    res = {
      on: ((name, cb)-> res['on' + name[0].toUpperCase() + name[1..]] = cb)
      removeListener: spy (name, cb)->
        eventName = 'on' + name[0].toUpperCase() + name[1..]
        expect(res[eventName]).to.equal cb
        delete res[eventName]
      setHeader: spy()
      end
    }
    return res

  describe '/connect', ->
    it 'should use randomString for generate cid', ->
      randomString = spy()
      {router} = createPolling {RandomString: (-> randomString)}

      router.get['/connection/connect'] {}, createRes()

      expect(randomString.calls).to.not.empty

    it 'should res end on connection.close()', ->
      connection = null
      onConnect = (conn)->
        connection = conn
        connection.onClose = spy()
      {router} = createPolling {onConnect}
      router.get['/connection/connect'] {}, res = createRes()

      connection.close()

      expect(res.end.calls).to.not.empty

  describe 'get/', ->
    it 'should end res if no polling', ->
      {router} = createPolling()
      res = end: spy()

      router.get['/connection/:cid'] {params: {cid: 'Not exists'}}, res

      expect(res.end.calls).to.not.empty

    it 'should ending res after 25 sec without messaging', ->
      {router, cid} = connectPolling()
      router.get['/connection/:cid'] {params: {cid}}, res = {end: spy(), on: ->}

      fakeTimers.tickByStep 25000, 5000

      expect(res.end.calls).to.not.empty

    it 'should ending res after sending message', ->
      {router, cid, connection} = connectPolling()
      res = createRes()
      router.get['/connection/:cid'] {params: {cid}}, res

      connection.send '1'

      expect(res.end.calls).to.not.empty

    it 'should skip ending res after message and 25 sec timout', ->
      {router, cid, connection} = connectPolling()
      res = createRes()
      router.get['/connection/:cid'] {params: {cid}}, res

      connection.send '1'
      fakeTimers.tickByStep 25000, 5000

      expect(res.end.calls).to.have.lengthOf 1

    it 'should skip closing connection on sending message', ->
      {router, cid, connection} = connectPolling()
      res = createRes end: (-> res.onClose?())
      router.get['/connection/:cid'] {params: {cid}}, res

      connection.send '1'

      expect(connection.onClose.calls).to.be.empty

    it 'should call connection.onClose on close res', ->
      {router, connection, res, cid} = connectPolling()

      res = createRes()
      router.get['/connection/:cid'] {params: {cid}}, res

      res.onClose()

      expect(connection.onClose.calls).to.not.empty

  describe 'buffered', ->
    it 'should switch to buffered after connect', ->
      {router, cid, connection} = connectPolling()
      connection.send '1'
      connection.send '2'

      router.get['/connection/:cid'] {params: {cid}}, res = {on: ->, end: spy()}

      expect(res.end.calls).to.eql [ ['[1,2]'] ]

    it 'should close connection after 5 sec in buffered', ->
      {connection} = connectPolling()

      fakeTimers.tickByStep 5000, 1000

      expect(connection.onClose.calls).to.not.empty

    it 'should save messages to buffer between re-connection', ->
      {router, cid, connection} = connectPolling()
      res = createRes()
      router.get['/connection/:cid'] {params: {cid}}, res
      connection.send '1'

      connection.send '2'
      connection.send '3'
      connection.send '4'
      router.get['/connection/:cid'] {params: {cid}}, res = {end: spy()}

      expect(res.end.calls).to.eql [['[2,3,4]']]

    it 'should switch to buffered after sending message', ->
      {router, cid, connection} = connectPolling()

      router.get['/connection/:cid'] {params: {cid}}, createRes()
      connection.send '1'

      connection.send '2'
      connection.send '3'

      router.get['/connection/:cid'] {params: {cid}}, res = {on: ->, end: spy()}

      expect(res.end.calls).to.eql [ ['[2,3]'] ]

    it 'should close connection after 5 sec after sent message', ->
      {router, connection, cid} = connectPolling()

      router.get['/connection/:cid'] {params: {cid}}, createRes()
      connection.send '1'

      fakeTimers.tickByStep 5000, 1000

      expect(connection.onClose.calls).to.not.empty

    it 'should send buffer[0] if his length is 1', ->
      {router, cid, connection} = connectPolling()
      connection.send '5'

      router.get['/connection/:cid'] {params: {cid}}, res = {on: ->, end: spy()}

      expect(res.end.calls).to.eql [ ['5'] ]

  describe 'post', ->
    it 'should skip sending if no message in req.body', ->
      {connection, router} = connectPolling()

      router.post['/connection/:cid'] {body: {}, params: {}}, {end: ->}

      expect(connection.onMessage.calls).to.be.empty

    it 'should skip sending if no polling', ->
      {connection, router} = connectPolling()

      router.post['/connection/:cid'] {body: {message: '123'}, params: {}},
        {end: ->}

      expect(connection.onMessage.calls).to.be.empty

    it 'should call connection.onMessage if has message ond polling', ->
      {connection, cid, router} = connectPolling()

      router.post['/connection/:cid'] {
        body: {message: '123'},
        params: {cid}
      }, {end: ->}

      expect(connection.onMessage.calls).to.eql [['123']]
