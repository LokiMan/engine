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
