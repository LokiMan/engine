spy = require '../../../../common/test_helpers/spy'
FakeTimers = require '../../../../common/test_helpers/fakeTimers'

describe 'SubscribeState', ->
  SubscribeState = require '../../../../rpc/server/states/subscribe'

  createState = (connection, res, req, timers)->
    timers ?= wait: -> clear: (->)

    subscribeState = SubscribeState timers.wait
    subscribeState connection, res

  describe 'connection.send', ->
    it 'should call res.end', ->
      message = 'msg'
      connection = flushBuffer: (->), setSendToBuffer: (->)
      res = end: spy(), setHeader: (->), on: (->), removeListener: (->)
      createState connection, res

      connection.send message

      expect(res.end.calls).to.eql [[message]]

    it 'should call connection.setSendToBuffer', ->
      message = 'msg'
      connection = flushBuffer: (->), setSendToBuffer: spy()
      res = end: spy(), setHeader: (->), on: (->), removeListener: (->)
      createState connection, res

      connection.send message

      expect(connection.setSendToBuffer.calls).to.not.empty

  it 'should call connection.flushBuffer with callback as res.end', ->
    connection =
      flushBuffer: (cb)-> cb 'msg'
      setSendToBuffer: spy()
    res = end: spy(), setHeader: (->), on: (->), removeListener: (->)

    createState connection, res

    expect(res.end.calls).to.eql [['msg']]
    expect(connection.setSendToBuffer.calls).to.not.empty

  it 'should set header', ->
    connection = flushBuffer: (->)
    res = setHeader: spy(), on: (->)

    createState connection, res, {}

    expect(res.setHeader.calls).to.eql [ ['Content-Type', 'text/plain'] ]

  it 'should call connection.close on res finish', ->
    connection = flushBuffer: (->), close: spy()
    events = {}
    res = setHeader: (->), on: (event, cb)-> events[event] = cb
    createState connection, res

    events['finish']()

    expect(connection.close.calls).to.not.empty

  it 'should res.end after 25 sec', ->
    connection = flushBuffer: (->), setSendToBuffer: (->)
    res = end: spy(), setHeader: (->), on: (->)
    fakeTimers = FakeTimers()
    createState connection, res, {}, fakeTimers

    fakeTimers.tick 25000

    expect(res.end.calls).to.not.empty

  describe 'send', ->
    it 'should clear timer', ->
      connection = flushBuffer: (->), setSendToBuffer: (->)
      res = end: spy(), setHeader: (->), on: (->), removeListener: (->)
      fakeTimers = FakeTimers()
      createState connection, res, {}, fakeTimers

      connection.send 'asd'
      fakeTimers.tick 25000

      expect(res.end.calls.length).to.equal 1

    it 'should call res.removeListener', ->
      connection = flushBuffer: (->), setSendToBuffer: (->)
      res = end: spy(), setHeader: (->), on: (->), removeListener: spy()
      fakeTimers = FakeTimers()
      createState connection, res, {}, fakeTimers

      connection.send 'asd'
      fakeTimers.tick 25000

      expect(res.removeListener.calls.length).to.equal 1
