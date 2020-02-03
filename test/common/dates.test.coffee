describe 'Dates', ->
  dates = require '../../common/dates'

  it 'should create formatted string', ->
    result = dates.formatYMDHMS dates.fromString '10/10/10 2:3:1'
    expect(result).to.equal '2010-10-10 02:03:01'

  describe 'parseDuration', ->
    it "should parse 'seconds'", ->
      result = dates.parseDuration '17 seconds'
      expect(result).to.equal 17000

    it "should parse 'sec'", ->
      result = dates.parseDuration '21 sec'
      expect(result).to.equal 21000

    it "should parse 'minutes'", ->
      result = dates.parseDuration '5 minutes'
      expect(result).to.equal 5 * 60 * 1000

    it "should parse 'm'", ->
      result = dates.parseDuration '15 min'
      expect(result).to.equal 15 * 60 * 1000

    it "should parse 'ms'", ->
      result = dates.parseDuration '15 ms'
      expect(result).to.equal 15

    it 'should parse several values', ->
      result = dates.parseDuration '2 min 17 seconds'
      expect(result).to.equal 2 * 60 * 1000 + 17 * 1000

    it 'should parse several values', ->
      result = dates.parseDuration '1 w 10 days 37 min 33 seconds'
      expect(result).to.equal 1471053000

    it 'should throw error on invalid text', ->
      fn = ->
        dates.parseDuration '1 time'

      expect(fn).to.throw 'On parse duration text'

    it 'should throw error on empty text', ->
      fn = ->
        dates.parseDuration ''

      expect(fn).to.throw 'On parse duration text'
