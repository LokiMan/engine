describe 'Path to regexp', ->
  pathToRegexp = require '../../router/pathToRegexp'

  describe 'simple regexp', ->
    keys = null
    result = null

    beforeEach ->
      keys = []
      result = pathToRegexp 'path/:id', keys

    it 'should create simple regexp', ->
      expect(result).to.eql /^path\/(\w+)\/?$/i

    it 'should generate list of keys', ->
      expect(keys).to.eql [{name: 'id'}]

  it 'should create regexp for several params', ->
    keys = []
    result = pathToRegexp 'path/:id/:id2/:id3', keys

    expect(result).to.eql /^path\/(\w+)\/(\w+)\/(\w+)\/?$/i
    expect(keys).to.eql [{name: 'id'}, {name: 'id2'}, {name: 'id3'}]

  it 'should create regexp for optional param', ->
    keys = []
    result = pathToRegexp 'path/:id/:id2?', keys

    expect(result).to.eql /^path\/(\w+)\/?(\w+)?\/?$/i
    expect(keys).to.eql [{name: 'id'}, {name: 'id2', optional: true}]

  it 'should match url with trailing slash', ->
    result = pathToRegexp 'path/foo', []

    expect(result).to.eql /^path\/foo\/?$/i

  it 'should skip trailing slash for optional param', ->
    result = pathToRegexp '/forum/:room/:page?'

    expect(result).to.eql /^\/forum\/(\w+)\/?(\w+)?\/?$/i

  it "should create regexp to capture all symbols on flag '*'", ->
    result = pathToRegexp '/:arg*'

    expect(result).to.eql /^\/(.*)\/?$/i
