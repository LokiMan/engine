spy = require '../../common/test_helpers/spy'

describe 'Prepend Async Method', ->
  prependAsyncMethod = require '../../common/prependAsyncMethod'

  it 'should call previous function', ->
    prev = spy()
    obj = func: prev
    prependAsyncMethod obj, 'func', (->)

    await obj.func 1, 2

    expect(prev.calls).to.eql [[1, 2]]

  it 'should skip call prev function without resolve promise', ->
    prev = spy()
    obj = func: prev
    prependAsyncMethod obj, 'func', (->)

    obj.func 1, 2

    expect(prev.calls).to.be.empty

  it 'should return prev function', ->
    prev = (->)
    obj = func: prev

    result = prependAsyncMethod obj, 'func', (->)

    expect(result).to.equal prev

  it 'should not throw if no prev func', ->
    fn = ->
      obj = {}
      prependAsyncMethod obj, 'func', (->)

      obj.func 1, 2

    expect(fn).to.not.throw()

  it 'should use current this', ->
    _call1 = null
    _call2 = null
    obj = func: (-> _call2 = this)
    newObj = {}
    prependAsyncMethod obj, 'func', (-> _call1 = this)

    await obj.func.call newObj

    expect(_call1).to.eql newObj
    expect(_call2).to.eql newObj
