spy = require '../../common/test_helpers/spy'

describe 'Persistence object observer', ->
  Observer = require '../../storage/observer'

  describe 'set', ->
    it 'should call callback on set new value', ->
      callback = spy()
      object = Observer {}, callback
      object.a = 1
      expect(callback.calls).to.eql [['set', ['a'], 1]]

    it 'should not call callback on set same value', ->
      callback = spy()
      object = Observer {a: 1}, callback
      object.a = 1
      expect(callback.calls).to.be.empty

    it 'should change origin', ->
      origin = {}
      object = Observer origin, ->
      object.a = 1
      expect(origin.a).to.eql 1

    it 'should set correct path for deeper object', ->
      callback = spy()

      object = Observer {}, callback

      object.a = {}
      object.a.b = 2

      expect(callback.calls[1]).to.eql ['set', ['a', 'b'], 2]

  describe 'delete', ->
    it 'should call callback on delete field', ->
      callback = spy()

      object = Observer {c: 3}, callback

      delete object.c

      expect(callback.calls).to.eql [  [ 'del', ['c'] ] ]

    it 'should change origin on delete', ->
      origin = {c: 3}
      object = Observer origin, ->
      delete object.c
      expect(origin).to.eql {}

  it 'should callback on array functions with different arguments', ->
    callback = spy()

    array = Observer [], callback

    array.push 5
    array.pop()
    array.splice 1, 2

    expect(callback.calls).to.eql [
      ['push', [], 5]
      ['pop', []]
      ['splice', [], 1, 2]
    ]

  it 'should send path to callback on array functions', ->
    callback = spy()

    origin = {pa: th: []}
    obj = Observer origin, callback
    array = obj.pa.th

    array.push 5
    array.pop()
    array.splice 1, 2

    expect(callback.calls).to.eql [
      ['push', ['pa', 'th'], 5]
      ['pop', ['pa', 'th']]
      ['splice', ['pa', 'th'], 1, 2]
    ]

  it 'should change origin array', ->
    origin = [1, 2, 3, 4, 5]
    array = Observer origin, ->

    array.push 6
    array.pop()
    array.pop()
    array.splice 1, 2

    expect(origin).to.eql [1, 4]

  it 'should return target object on toJSON()', ->
    origin = a: b: 2
    object = Observer origin, ->
    expect(object.a.toJSON()).to.equal origin.a

  it 'should return simple value on get', ->
    origin = a: b: 2
    object = Observer origin, ->

    expect(object.a.b).to.equal 2

  it 'should return same proxy on same path', ->
    origin =
      a:
        b: 2
    object = Observer origin, ->

    expect(object.a).to.equal object.a

  it 'should return new proxy after re set new object', ->
    origin =
      a:
        b: 2
    object = Observer origin, ->

    expect(object.a).to.eql b: 2

    object.a = b: 3

    expect(object.a).to.eql b: 3

  it 'should return undefined after deleting object', ->
    origin =
      a:
        b: 2
    object = Observer origin, ->

    expect(object.a).to.eql b: 2

    delete object.a

    expect(object.a).to.be.undefined

  it 'should return result of array function', ->
    origin = {pa: th: [1, 2, 3]}
    obj = Observer origin, ->
    array = obj.pa.th

    result1 = array.push 5
    result2 = array.pop()
    result3 = array.splice 1, 2

    expect([result1, result2, result3]).to.eql [4, 5, [2, 3]]
