spy = require '../../common/test_helpers/spy'

describe "Event emitter", ->
  EventEmitter = require '../../common/eventEmitter'

  eventEmitter = undefined

  beforeEach ->
    eventEmitter = EventEmitter()

  it "should do reaction on emit", ->
    eventEmitter.on 'event', spyCb = spy()

    eventEmitter.emit 'event', 'a1', 2

    expect(spyCb.calls).to.eql [['a1', 2]]

  it "should do reaction of all subscribers on event", ->
    eventEmitter.on 'event', spy1 = spy()
    eventEmitter.on 'event', spy2 = spy()

    eventEmitter.emit 'event', 'a1', 2

    expect(spy1.calls).to.eql [['a1', 2]]
    expect(spy2.calls).to.eql [['a1', 2]]

  it "should skip reaction for unsubscribed subscribers", ->
    spy1 = spy()
    spy2 = spy()
    eventEmitter.on 'event', spy1
    eventEmitter.on 'event', spy2
    eventEmitter.removeListener 'event', spy1

    eventEmitter.emit 'event', 'a1', 2

    expect(spy1.calls).to.be.empty
    expect(spy2.calls).to.eql [['a1', 2]]

  it "should skip reaction of events that add during emit", ->
    spy2 = spy()
    eventEmitter.on 'event', ->
      eventEmitter.on 'event', spy2

    eventEmitter.emit 'event', 'a1', 2

    expect(spy2.calls).to.be.empty

  it "should remove events in removeListener after emit", ->
    spy1 = spy ->
      eventEmitter.removeListener 'event', spy2

    spy2 = spy()

    eventEmitter.on 'event', spy1
    eventEmitter.on 'event', spy2

    eventEmitter.emit 'event', 'a1', 2
    eventEmitter.emit 'event', 'a2', 3

    expect(spy1.calls).to.eql [['a1', 2], ['a2', 3]]
    expect(spy2.calls).to.eql [['a1', 2]]

  it "should call only one time on once", ->
    eventEmitter.once 'event', spy1 = spy()

    eventEmitter.emit 'event', 'a1', 2
    eventEmitter.emit 'event', 'a1', 2

    expect(spy1.calls).to.eql [['a1', 2]]

  it "should correct work on emit during emit", ->
    fn = ->
      eventEmitter.on 'event', ->
        eventEmitter.emit 'event2'

      eventEmitter.on 'event2', ->

      eventEmitter.emit 'event', 'a1', 2

    expect(fn).to.not.throw()

  it "should work emit without args", ->
    fn = spy()

    eventEmitter.on 'event', fn
    eventEmitter.emit 'event'

    expect(fn.calls).to.eql [[]]

  it "should work emit with one arg", ->
    fn = spy()

    eventEmitter.on 'event', fn
    eventEmitter.emit 'event', 'a1'

    expect(fn.calls).to.eql [['a1']]

  it "should work emit with two args", ->
    fn = spy()

    eventEmitter.on 'event', fn
    eventEmitter.emit 'event', 'a1', 2

    expect(fn.calls).to.eql [['a1', 2]]

  it "should work emit with three args", ->
    fn = spy()

    eventEmitter.on 'event', fn
    eventEmitter.emit 'event', 'a1', 2, {}

    expect(fn.calls).to.eql [['a1', 2, {}]]

  it "should work emit with four args", ->
    fn = spy()

    eventEmitter.on 'event', fn
    eventEmitter.emit 'event', 'a1', 2, [], 3.2

    expect(fn.calls).to.eql [['a1', 2, [], 3.2]]

  it "should work emit with five args", ->
    fn = spy()

    eventEmitter.on 'event', fn
    eventEmitter.emit 'event', 1, 2, 3, 4, 5

    expect(fn.calls).to.eql [[1, 2, 3, 4, 5]]

  it "should work with three listeners", ->
    fn1 = spy()
    fn2 = spy()
    fn3 = spy()

    eventEmitter.on 'event', fn1
    eventEmitter.on 'event', fn2
    eventEmitter.on 'event', fn3

    eventEmitter.emit 'event', 'arg'

    expect(fn1.calls).to.eql [['arg']]
    expect(fn2.calls).to.eql [['arg']]
    expect(fn3.calls).to.eql [['arg']]
