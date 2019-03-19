spy = require '../../common/test_helpers/spy'

describe 'Append Function', ->
  prependMethod = require '../../common/prependMethod'

  it 'should call previous function', ->
    prev = spy()
    obj = func: prev
    prependMethod obj, 'func', (->)

    obj.func 1, 2

    expect(prev.calls).to.eql [[1, 2]]
    
  it 'should return prev function', ->
    prev = (->)
    obj = func: prev

    result = prependMethod obj, 'func', (->)

    expect(result).to.equal prev

  it 'should not throw if no prev func', ->
    fn = ->
      obj = {}
      prependMethod obj, 'func', (->)

      obj.func 1, 2

    expect(fn).to.not.throw()

  it 'should use current this', ->
    _call1 = null
    _call2 = null
    obj = func: (-> _call2 = this)
    newObj = {}
    prependMethod obj, 'func', (-> _call1 = this)

    obj.func.call newObj

    expect(_call1).to.eql newObj
    expect(_call2).to.eql newObj
