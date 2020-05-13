spy = require '../../common/test_helpers/spy'

describe 'Append method', ->
  appendMethod = require '../../common/appendMethod'

  it 'should call previous function', ->
    prev = spy()
    obj = func: prev
    appendMethod obj, 'func', (->)

    obj.func 1, 2

    expect(prev.calls).to.eql [[1, 2]]

  it 'should call new function with result of prev', ->
    obj = func: -> 3
    appendMethod obj, 'func', newFunc = spy()

    obj.func 1, 2

    expect(newFunc.calls).to.eql [[1, 2, 3]]

  it 'should return prev function', ->
    prev = (->)
    obj = func: prev

    result = appendMethod obj, 'func', (->)

    expect(result).to.equal prev

  it 'should not throw if no prev func', ->
    fn = ->
      obj = {}
      appendMethod obj, 'func', (->)

      obj.func 1, 2

    expect(fn).to.not.throw()

  it 'should call append result array as array', ->
    obj = func: -> [3, 4]
    appendMethod obj, 'func', newFunc = spy()

    obj.func 1, 2

    expect(newFunc.calls).to.eql [[1, 2, [3, 4]]]

  it 'should use current this', ->
    obj = func: (-> 1)
    newObj = {}

    appendMethod obj, 'func', (-> this)

    result = obj.func.call newObj

    expect(result).to.eql newObj
