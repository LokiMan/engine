spy = require '../../common/test_helpers/spy'

describe 'Storage', ->
  Storage = require '../../storage/storage'

  createStorage = (data, onChange)->
    Storage data, onChange

  describe 'createObserved', ->
    it 'should call Observer on data', ->
      data = {'uid1': [1, 2, 3]}
      storage = Storage {data}, (onChange = ->), undefined, Observer = spy()

      storage.createObserved ['data']

      expect(Observer.calls).to.eql [[data, onChange, ['data']]]

    it 'should set initial if no path', ->
      initial = {a: 1}
      data = {}
      storage = Storage {data}, (->), undefined, ((a)-> a)

      result = storage.createObserved ['data2'], initial

      expect(result).to.eql initial

  describe 'get', ->
    it 'should return value by path', ->
      data = {p: a: t: h: {a: 1}}
      storage = createStorage data

      result = storage.get ['p', 'a', 't', 'h']

      expect(result).to.eql data.p.a.t.h

    it 'should cloneDeep returned value', ->
      obj2 = {}
      storage = Storage {a: b: {}}, (->), -> obj2

      result = storage.get ['a', 'b']

      expect(result).to.equal obj2

  describe 'set', ->
    it 'should change data by path', ->
      data = {pa: th: 1}
      storage = createStorage data

      storage.set ['pa', 'th'], 2

      expect(data.pa.th).to.equal 2

    it 'should return set value', ->
      storage = createStorage {a: 1}

      result = storage.set ['a'], 2

      expect(result).to.equal 2

    it "should call onChange function with 'set', path and new value", ->
      onChange = spy()
      storage = createStorage {pa: th: 3}, onChange

      storage.set ['pa', 'th'], 7

      expect(onChange.calls).to.eql [
        ['set', ['pa', 'th'], 7]
      ]

    it 'should cloneDeep obtain value', ->
      obj2 = {}
      storage = Storage {a: b: {}}, (->), -> obj2

      result = storage.set ['a', 'b'], {}

      expect(result).to.equal obj2

    it 'should no call onChange on set equal value', ->
      onChange = spy()
      storage = createStorage {pa: th: 3}, onChange

      storage.set ['pa', 'th'], 3

      expect(onChange.calls).to.be.empty

    it 'should not call onChange if path not exists', ->
      onChange = spy()
      storage = createStorage {pa: th: 3}, onChange

      try
        storage.set ['path', 'not_exists'], 1

      expect(onChange.calls).to.be.empty

  describe 'has', ->
    it 'should return true if path exists', ->
      storage = createStorage {pa: th: 1}

      result = storage.has ['pa', 'th']

      expect(result).to.be.true

    it 'should return false if path not exists', ->
      storage = createStorage {pa: th: 1}

      result = storage.has ['pa', 'th2']

      expect(result).to.be.false

  describe 'update', ->
    it 'should change data only with set fields', ->
      data = {pa: th: {a: 1, b: 1, c: 1, d: 1}}
      storage = createStorage data

      storage.update ['pa', 'th'], {b: 2, d: '4'}

      expect(data.pa.th).to.eql {a: 1, b: 2, c: 1, d: '4'}

    it "should call onChange function with 'update', path and object", ->
      onChange = spy()
      storage = createStorage {pa: th: {a: 1, b: 1, c: 1, d: 1}}, onChange

      storage.update ['pa', 'th'], {b: 2, d: '4'}

      expect(onChange.calls).to.eql [
        ['update', ['pa', 'th'], {b: 2, d: '4'}]
      ]

    it 'should cloneDeep obtain object', ->
      spyClone = spy()
      storage = Storage {pa: th: {a: 1, b: 1, c: 1, d: 1}}, (->), spyClone
      updObject = {b: 2, d: '4'}

      storage.update ['pa', 'th'], updObject

      expect(spyClone.calls[0][0]).to.equal updObject

    it 'should not call onChange if path not exists', ->
      onChange = spy()
      storage = createStorage {pa: th: {a: 1, b: 1, c: 1, d: 1}}, onChange

      try
        storage.update ['th', 'not_exists'], {b: 2, d: '4'}

      expect(onChange.calls).to.be.empty

  describe 'del', ->
    it 'should delete key from object', ->
      data = {pa: th: 1}
      storage = createStorage data

      storage.del ['pa', 'th']

      expect(data.pa.th).to.be.undefined

    it "should call onChange with 'del' and path", ->
      onChange = spy()
      storage = createStorage {pa: th: 1}, onChange

      storage.del ['pa', 'th']

      expect(onChange.calls).to.eql [
        ['del', ['pa', 'th']]
      ]

    it 'should not call onChange if path not exists', ->
      onChange = spy()
      storage = createStorage {pa: th: 1}, onChange

      try
        storage.del ['path', 'not_exists']

      expect(onChange.calls).to.be.empty

  describe 'inc', ->
    it 'should increment data', ->
      data = {pa: th: 3}
      storage = createStorage data

      storage.inc ['pa', 'th'], 4

      expect(data.pa.th).to.equal 7

    it 'should return new value', ->
      storage = createStorage {pa: th: 3}

      result = storage.inc ['pa', 'th'], 4

      expect(result).to.equal 7

    it "should call onChange with 'inc' and value", ->
      onChange = spy()
      storage = createStorage {pa: th: 3}, onChange

      storage.inc ['pa', 'th'], 1

      expect(onChange.calls).to.eql [
        ['inc', ['pa', 'th'], 1]
      ]

    it 'should increment on 1 by default', ->
      data = {pa: th: 3}
      storage = createStorage data

      storage.inc ['pa', 'th']

      expect(data.pa.th).to.equal 4

    it 'should not call onChange if path not exists', ->
      onChange = spy()
      storage = createStorage {pa: th: 3}, onChange

      try
        storage.inc ['path', 'not_exists'], 1

      expect(onChange.calls).to.be.empty

  describe 'dec', ->
    it 'should decrement data', ->
      data = {pa: th: 7}
      storage = createStorage data

      storage.dec ['pa', 'th'], 4

      expect(data.pa.th).to.equal 3

    it 'should return new value', ->
      storage = createStorage {pa: th: 5}

      result = storage.dec ['pa', 'th'], 3

      expect(result).to.equal 2

    it "should call onChange with 'inc' and value", ->
      onChange = spy()
      storage = createStorage {pa: th: 3}, onChange

      storage.dec ['pa', 'th'], 1

      expect(onChange.calls).to.eql [
        ['dec', ['pa', 'th'], 1]
      ]

    it 'should decrement on 1 by default', ->
      data = {pa: th: 3}
      storage = createStorage data

      storage.dec ['pa', 'th']

      expect(data.pa.th).to.equal 2

    it 'should not call onChange if path not exists', ->
      onChange = spy()
      storage = createStorage {pa: th: 3}, onChange

      try
        storage.dec ['path', 'not_exists'], 1

      expect(onChange.calls).to.be.empty

  describe 'push', ->
    it 'should push value to data', ->
      data = {pa: th: [1, 2]}
      storage = createStorage data

      storage.push ['pa', 'th'], 3

      expect(data.pa.th).to.eql [1, 2, 3]

    it 'should return new length of array', ->
      storage = createStorage {pa: th: [1, 2, 3]}

      result = storage.push ['pa', 'th'], 4

      expect(result).to.equal 4

    it "should call onChange with 'push' and value", ->
      onChange = spy()
      storage = createStorage {pa: th: [1, 2]}, onChange

      storage.push ['pa', 'th'], 1

      expect(onChange.calls).to.eql [
        ['push', ['pa', 'th'], 1]
      ]

    it 'should cloneDeep obtain value', ->
      spyClone = spy()
      storage = Storage {a: b: [1, 2]}, (->), spyClone

      storage.push ['a', 'b'], 3

      expect(spyClone.calls).to.eql [ [3] ]

    it 'should not call onChange if path not exists', ->
      onChange = spy()
      storage = createStorage {pa: th: [1, 2]}, onChange

      try
        storage.push ['path', 'not_exists'], 1

      expect(onChange.calls).to.be.empty

  describe 'pop', ->
    it 'should pop from data', ->
      data = {pa: th: [1, 2]}
      storage = createStorage data

      storage.pop ['pa', 'th']

      expect(data.pa.th).to.eql [1]

    it 'should return popped value', ->
      storage = createStorage {pa: th: [1, 2, 3]}

      result = storage.pop ['pa', 'th']

      expect(result).to.equal 3

    it "should call onChange with 'pop'", ->
      onChange = spy()
      storage = createStorage {pa: th: [1, 2]}, onChange

      storage.pop ['pa', 'th']

      expect(onChange.calls).to.eql [
        ['pop', ['pa', 'th']]
      ]

    it 'should not call onChange if path not exists', ->
      onChange = spy()
      storage = createStorage {pa: th: [1, 2]}, onChange

      try
        storage.pop ['path', 'not_exists']

      expect(onChange.calls).to.be.empty

  describe 'splice', ->
    it 'should change data', ->
      data = {pa: th: [1, 2, 3, 4]}
      storage = createStorage data

      storage.splice ['pa', 'th'], 1, 2

      expect(data.pa.th).to.eql [1, 4]

    it 'should return spliced elements', ->
      storage = createStorage {pa: th: [1, 2, 3, 4]}

      result = storage.splice ['pa', 'th'], 1, 2

      expect(result).to.eql [2, 3]

    it "should call onChange with 'splice', index and count", ->
      onChange = spy()
      storage = createStorage {pa: th: [1, 2]}, onChange

      storage.splice ['pa', 'th'], 1, 1

      expect(onChange.calls).to.eql [
        ['splice', ['pa', 'th'], 1, 1]
      ]

    it 'should not call onChange if path not exists', ->
      onChange = spy()
      storage = createStorage {pa: th: [1, 2]}, onChange

      try
        storage.splice ['path', 'not_exists'], 1, 1

      expect(onChange.calls).to.be.empty

  describe 'unshift', ->
    it 'should unshift value to data', ->
      data = {pa: th: [1, 2]}
      storage = createStorage data

      storage.unshift ['pa', 'th'], 3

      expect(data.pa.th).to.eql [3, 1, 2]

    it 'should return new length of array', ->
      storage = createStorage {pa: th: [1, 2]}

      result = storage.unshift ['pa', 'th'], 4

      expect(result).to.equal 3

    it "should call onChange with 'unshift' and value", ->
      onChange = spy()
      storage = createStorage {pa: th: [1, 2]}, onChange

      storage.unshift ['pa', 'th'], 1

      expect(onChange.calls).to.eql [
        ['unshift', ['pa', 'th'], 1]
      ]

    it 'should cloneDeep obtain value', ->
      spyClone = spy()
      storage = Storage {a: b: [1, 2]}, (->), spyClone

      storage.unshift ['a', 'b'], 3

      expect(spyClone.calls).to.eql [ [3] ]

    it 'should not call onChange if path not exists', ->
      onChange = spy()
      storage = createStorage {pa: th: [1, 2]}, onChange

      try
        storage.unshift ['path', 'not_exists'], 1

      expect(onChange.calls).to.be.empty

  describe 'shift', ->
    it 'should shift from data', ->
      data = {pa: th: [1, 2]}
      storage = createStorage data

      storage.shift ['pa', 'th']

      expect(data.pa.th).to.eql [2]

    it 'should return popped value', ->
      storage = createStorage {pa: th: [1, 2, 3]}

      result = storage.shift ['pa', 'th']

      expect(result).to.equal 1

    it "should call onChange with 'shift'", ->
      onChange = spy()
      storage = createStorage {pa: th: [1, 2]}, onChange

      storage.shift ['pa', 'th']

      expect(onChange.calls).to.eql [
        ['shift', ['pa', 'th']]
      ]

    it 'should not call onChange if path not exists', ->
      onChange = spy()
      storage = createStorage {pa: th: [1, 2]}, onChange

      try
        storage.shift ['path', 'not_exists']

      expect(onChange.calls).to.be.empty
