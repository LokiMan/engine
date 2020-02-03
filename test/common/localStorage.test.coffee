spy = require '../../common/test_helpers/spy'

describe 'LocalStorage', ->
  LocalStorage = require '../../common/localStorage'

  it 'should can store complex object', ->
    object = {a: 1, b: [2, 3], c: 'asd'}
    localStorage = LocalStorage null
    localStorage.set 'key', object

    result = localStorage.get 'key'

    expect(result).to.eql object

  it 'should not retrieve the same object', ->
    object = {a: 1, b: [2, 3], c: 'asd'}
    localStorage = LocalStorage {}
    localStorage.set 'key', object

    result = localStorage.get 'key'

    expect(result).to.not.equal object

  it 'should return undefined after removing item', ->
    object = {a: 1}
    localStorage = LocalStorage {}
    localStorage.set 'key', object
    localStorage.remove 'key'

    result = localStorage.get 'key'

    expect(result).to.be.undefined

  it 'should use obtained storage', ->
    getItem = spy()
    setItem = spy()
    removeItem = spy()
    localStorage = LocalStorage {getItem, setItem, removeItem}

    localStorage.set 'key', {a: 2}
    localStorage.get 'key'
    localStorage.remove 'key'

    expect([getItem.calls, setItem.calls, removeItem.calls]).to.eql [
      [['key']]
      [['test', '1'], ['key', '{"a":2}']]
      [['test'], ['key']]
    ]

