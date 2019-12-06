spy = require '../../../common/test_helpers/spy'

describe 'OnChange', ->
  OnChange = require '../../../persist/file/onChange'
  Storage = require '../../../storage/storage'

  it 'should add to next tick only if buffer empty', ->
    nextTick = spy()
    onChange = OnChange {}, {nextTick}

    onChange()
    onChange()

    expect(nextTick.calls).to.have.lengthOf 1

  it 'should write changes in storage', ->
    write = spy()
    cb = null
    storage = Storage {}, OnChange {write}, {nextTick: (_cb)-> cb = _cb}

    storage.set ['a'], {}
    cb()

    expect(write.calls).to.eql [['[0,["set",["a"],{}]]\n']]

  it 'should increment write num', ->
    write = spy()
    cb = null
    storage = Storage {}, OnChange {write}, {nextTick: (_cb)-> cb = _cb}

    storage.set ['a'], {}
    cb()
    storage.set ['b'], []
    cb()

    expect(write.calls).to.eql [
      ['[0,["set",["a"],{}]]\n']
      ['[1,["set",["b"],[]]]\n']
    ]

  it 'should write several changes into one line', ->
    write = spy()
    cb = null
    storage = Storage {}, OnChange {write}, {nextTick: (_cb)-> cb = _cb}

    storage.set ['a'], {}
    storage.set ['b'], []
    cb()

    expect(write.calls).to.eql [
      ['[0,["set",["a"],{}],["set",["b"],[]]]\n']
    ]

  it 'should transform undefined to null for stringify it', ->
    write = spy()
    cb = null
    storage = Storage {}, OnChange {write}, {nextTick: (_cb)-> cb = _cb}

    storage.set ['a'], {}
    storage.set ['a'], undefined
    cb()

    expect(write.calls).to.eql [['[0,["set",["a"],{}],["set",["a"],null]]\n']]
