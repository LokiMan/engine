spy = require '../../../common/test_helpers/spy'

describe "Fake timers", ->
  FakeTimers = require '../../../common/test_helpers/fakeTimers'

  timers = null
  func = null

  beforeEach ->
    timers = FakeTimers()
    func = spy()

  it "should call wait func after tick", ->
    timers.wait 1, func
    timers.tick 1
    expect(func.calls.length).to.equal 1

  it "should call all functions after tick", ->
    func2 = spy()
    timers.wait 1, func
    timers.wait 1, func2

    timers.tick 1
    expect(func.calls.length).to.equal 1
    expect(func2.calls.length).to.equal 1

  it "shouldn't call wait func after first call", ->
    timers.wait 1, func
    timers.tick 2
    expect(func.calls.length).to.equal 1

  it "should call interval func several times", ->
    timers.interval 1, func
    timers.tick 2
    expect(func.calls.length).to.equal 2

  it "shouldn't call func before the time has come", ->
    timers.wait 2, func
    timers.tick 1
    expect(func.calls.length).to.equal 0

  it "should use common time line", ->
    timers.wait 2, func
    timers.tick 1
    timers.tick 1
    expect(func.calls.length).to.equal 1

  it "should increase internal intervals of timers", ->
    timers.interval 2, func
    timers.tick 6
    expect(func.calls.length).to.equal 3

  it "shouldn't call cleared func", ->
    timer = timers.wait 1, func
    timer.clear()
    timers.tick 1
    expect(func.calls.length).to.equal 0

  it "shouldn't call cleared interval func", ->
    timer = timers.interval 1, func
    timer.clear()
    timers.tick 1
    expect(func.calls.length).to.equal 0

  it "should correct clear several timers", ->
    timer1 = timers.interval 1, func
    timer2 = timers.interval 1, func
    timer1.clear()
    timer2.clear()
    timers.tick 1
    expect(func.calls.length).to.equal 0

  it "should restart timer on reStart", ->
    timer = timers.wait 1, func
    timers.tick 1
    expect(func.calls.length).to.equal 1
    timer.reStart()
    timers.tick 1
    expect(func.calls.length).to.equal 2

  it "should return current time on now()", ->
    result = timers.now()
    expect(result).to.equal 0
    timers.tick 7
    result = timers.now()
    expect(result).to.equal 7