spy = require '../../../../common/test_helpers/spy'

describe 'Raf', ->
  Raf = require '../../../../game/client/animate/raf'

  it 'should use window.requestAnimationFrame if exists', ->
    window = requestAnimationFrame: spy()
    raf = Raf null, null, window

    raf.request()

    expect(window.requestAnimationFrame.calls).to.not.empty

  it 'should use window.cancelAnimationFrame if exists', ->
    window = requestAnimationFrame: 1, cancelAnimationFrame: spy()
    raf = Raf null, null, window

    raf.cancel()

    expect(window.cancelAnimationFrame.calls).to.not.empty

  it 'should use window vendor raf', ->
    window = mozRequestAnimationFrame: spy()
    raf = Raf null, null, window

    raf.request()

    expect(window.mozRequestAnimationFrame.calls).to.not.empty

  it 'should use custom raf if not in window', ->
    time = 100000
    now = -> time
    wait = spy()
    raf = Raf now, wait, {}

    raf.request (cb = ->)
    time += 10
    raf.request cb

    expect(wait.calls).to.eql [[0, cb], [6, cb]]

  it 'should call timer.clear in custom raf', ->
    raf = Raf null, null, {}
    timer = clear: spy()

    raf.cancel timer

    expect(timer.clear.calls).to.not.empty
