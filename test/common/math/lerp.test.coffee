lerp = require '../../../common/math/lerp'

describe 'Lerp', ->
  describe 'single', ->
    it 'should calculate for integers', ->
      result = lerp 0, 10, 0.4
      expect(result).to.equal 4

    it 'should calculate for floats', ->
      result = lerp 0, 1.2, 0.4
      expect(result).to.equal 0.48

  describe 'arrays', ->
    it "should calculate for each array's items", ->
      result = lerp.arrays [0, 0, 2], [10, 1.2, 3], 0.4
      expect(result).to.eql [4, 0.48, 2.4]
