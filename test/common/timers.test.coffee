spy = require '../../common/test_helpers/spy'

describe 'Timers', ->
  Timers = require '../../common/timers'

  it 'should restart wait timer on reStart', ->
    setTimeout = spy -> {}
    clearTimeout = spy()
    timers = Timers {setTimeout, clearTimeout}

    timer = timers.wait()
    timer.reStart()

    expect([setTimeout.calls.length, clearTimeout.calls.length]).to.eql [2, 1]

  it 'should restart interval timer on reStart', ->
    setInterval = spy -> {}
    clearInterval = spy()
    timers = Timers {setInterval, clearInterval}

    timer = timers.interval()
    timer.reStart()

    expect([setInterval.calls.length, clearInterval.calls.length]).to.eql [2, 1]
