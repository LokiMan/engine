FakeTimers = require '../../../common/test_helpers/fakeTimers'
spy = require '../../../common/test_helpers/spy'

describe 'Animate', ->
  Animate = require '../../../game/client/animate/index'
  lerp = require '../../../common/math/lerp'

  timers = undefined
  animate = undefined

  beforeEach ->
    timers = FakeTimers()

    fakeRaf = {
      request: (callback)->
        timers.wait 16, callback
    }

    animate = Animate timers, fakeRaf

  it 'should call tick each frame', ->
    tick = spy()
    animate {duration: 100, tick}

    timers.tick 48

    expect(tick.calls.length).to.equal 3

  it 'should call finish on finish', ->
    animate 100, finish = spy()

    timers.tick Math.ceil(100 / 16) * 16

    expect(finish.calls.length).to.equal 1

  it 'should work with object as arg', ->
    obj = {duration: 100, tick: spy()}
    animate obj

    timers.tick 48

    expect(obj.tick.calls.length).to.equal 3

  it 'should call update even if raf in pause', ->
    timers = FakeTimers()

    fakeRaf = {
      request: (callback)->
        timers.wait +Infinity, callback

      cancel: (timer)->
        timer.clear()
    }

    animate = Animate timers, fakeRaf

    tick = spy()
    animate {duration: 100, tick}

    timers.tick 1000

    expect(tick.calls).to.not.empty

  it 'should call update with current time in paused raf', ->
    timers = FakeTimers()

    fakeRaf = {
      request: (callback)->
        timers.wait +Infinity, callback
    }

    animate = Animate timers, fakeRaf

    tick = spy()
    animate {duration: 2000, tick}

    timers.tick 1000

    expect(tick.calls).to.eql [ [ 0.5 ] ]

  describe 'fromTo', ->
    it 'should evaluate values', ->
      obj = {duration: 100, from: 0, to: 10, tick: spy()}
      animate.fromTo obj

      timers.tick 16

      t = (100 - 16) / 100
      expect(obj.tick.calls[0][0]).to.be.closeTo lerp(0, 10, t), 0.001

    it 'should evaluate all values on array', ->
      obj = {duration: 100, from: [1, 2], to: [10, 20], tick: spy()}
      animate.fromTo obj

      timers.tick 16

      expect(obj.tick.calls[0][0]).to.have.lengthOf 2

  describe 'stop', ->
    it 'should remove animate on stop', ->
      tick = spy()
      animation = animate {duration: 100, tick}
      timers.tick 16

      animation.stop()
      timers.tick 16

      expect(tick.calls).to.have.lengthOf 1

    it 'should call finish from stopped animation', ->
      finish = spy()
      animation = animate 100, finish

      timers.tick 16
      animation.stop()
      timers.tick 16

      expect(finish.calls).to.not.empty

    it 'should not call finish from break animation', ->
      finish = spy()
      animation = animate 100, finish

      timers.tick 16
      animation.break()
      timers.tick 16

      expect(finish.calls).to.be.empty
