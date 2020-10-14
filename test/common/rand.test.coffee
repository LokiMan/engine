describe 'rand', ->
  rand = require '../../common/rand'

  describe 'fromArray', ->
    it 'should return value if count is 1', ->
      array = [1, 2, 3]

      value = rand.fromArray array, 1

      expect(value).to.be.a 'number'

    it 'should throw error if count more than length', ->
      fn = ->
        array = [1, 2]
        rand.fromArray array, 3

      expect(fn).to.throw 'more than'

    it 'should return array if count is more than 1', ->
      array = [1, 2, 3]

      value = rand.fromArray array, 2

      expect(value).to.be.an 'array'

  describe 'shuffle', ->
    it 'should shuffle in-place', ->
      a1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
      a2 = [a1...]

      rand.shuffle a1

      expect(a1).to.not.eql a2

  describe 'chance', ->
    it 'should not chance on percent = 0', ->
      results = (rand.chance 0 for [1..10])

      expect(results).to.eql (false for [1..10])

    it 'should always true on percent = 100', ->
      results = (rand.chance 100 for [1..10])

      expect(results).to.eql (true for [1..10])

