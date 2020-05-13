spy = require '../../common/test_helpers/spy'

describe 'Append Async Method', ->
  appendAsyncMethod = require '../../common/appendAsyncMethod'

  it 'should call previous function', ->
    prev = spy()
    obj = func: prev
    appendAsyncMethod obj, 'func', (->)

    await obj.func 1, 2

    expect(prev.calls).to.eql [[1, 2]]

  it 'should skip call new function without resolve promise', ->
    obj = func: -> 3
    appendAsyncMethod obj, 'func', newFunc = spy()

    obj.func 1, 2

    expect(newFunc.calls).to.be.empty

  it 'should call new function with result of prev', ->
    obj = func: -> 3
    appendAsyncMethod obj, 'func', newFunc = spy()

    await obj.func 1, 2

    expect(newFunc.calls).to.eql [[1, 2, 3]]

  it 'should return prev function', ->
    prev = (->)
    obj = func: prev

    result = appendAsyncMethod obj, 'func', (->)

    expect(result).to.equal prev

  it 'should not throw if no prev func', ->
    fn = ->
      obj = {}
      appendAsyncMethod obj, 'func', (->)

      obj.func 1, 2

    expect(fn).to.not.throw()

  it 'should call append result array as array', ->
    obj = func: -> [3, 4]
    appendAsyncMethod obj, 'func', newFunc = spy()

    await obj.func 1, 2

    expect(newFunc.calls).to.eql [[1, 2, [3, 4]]]

  it 'should use current this', ->
    obj = func: (-> 1)
    newObj = {}

    appendAsyncMethod obj, 'func', (-> this)

    result = await obj.func.call newObj

    expect(result).to.eql newObj
