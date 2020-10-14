describe 'rand', ->
  Rand = require '../../../runner/utils/rand'

  describe 'uuidFor', ->
    {uuidFor} = Rand {}

    it 'should check exists item', ->
      chars = 'abcdefghijklmnopqrstuvwxyz0123456789_-ABCDEFGHIJKLMNOPQRSTUVWXY'
      charsMax = chars.length
      collection = {}
      for i in [0...charsMax]
        collection[chars[i]] = true

      randomString = uuidFor collection

      id2 = randomString 1

      expect(id2).to.equal 'Z'
