spy = require '../../../common/test_helpers/spy'

describe 'Read Game', ->
  loadGame = require '../../../game/server/loadGame'

  readGame = (content, existsSync = (-> true))->
    fakeFS =
      readFileSync: -> content
      existsSync: existsSync

    loadGame srcDir: '', fs: fakeFS

  it 'should read game components if they set', ->
    result = readGame '''
components
  first: true
  second: {}
'''

    expect(result.gameComponents).to.eql {
      first: true
      second: {}
    }

  it 'should set game components to empty object if they do not set', ->
    result = readGame ''

    expect(result.gameComponents).to.eql {}

  it 'should throw if not found component', ->
    fn = ->
      readGame 'components notFound: 1', -> false

    expect(fn).to.throw 'not found'

  it 'should read scenes if they set', ->
    result = readGame """
scene 'first',
  cmp1: true
  cmp2: {}
"""

    expect(result.scenes).to.eql {
      first:
        cmp1: true
        cmp2: {}
    }

  it 'should throw on duplicate scene', ->
    fn = ->
      readGame """
scene 'first',
  cmp1: true
scene 'first',
  cmp1: true
"""
    expect(fn).to.throw 'Duplicated scene'

  it 'should use full path of external components', ->
    fakeFS =
      readFileSync: -> """
config {externals: ['../extProject/src']}
components {ext: true}"""
      existsSync: spy (p)-> p.includes 'extProject'

    loadGame {srcDir: '/games/game1/src/', fs: fakeFS}

    expect(fakeFS.existsSync.calls[4...6]).to.eql [
      ['/games/extProject/src/ext/server/ext.coffee']
      ['/games/extProject/src/ext/client/ext.coffee']
    ]

  it 'should load part components', ->
    fakeFS =
      readFileSync: -> """
part 'root'
components {ext: true}"""
      existsSync: spy (p)-> p.includes 'root'

    loadGame {srcDir: '/', fs: fakeFS}

    expect(fakeFS.existsSync.calls).to.eql [
      ['/ext/server/ext.coffee']
      ['/ext/server/ext.js']
      ['/ext/client/ext.coffee']
      ['/ext/client/ext.js']
      ['/root/ext/server/ext.coffee']
      ['/root/ext/client/ext.coffee']
    ]

  it 'should load nested part components', ->
    fakeFS =
      readFileSync: -> """
part 'root/sub/sub2'
components {ext: true}"""
      existsSync: spy (p)-> p.includes 'root/sub'

    result = loadGame {srcDir: '/', fs: fakeFS}

    expect(fakeFS.existsSync.calls).to.eql [
      ['/ext/server/ext.coffee']
      ['/ext/server/ext.js']
      ['/ext/client/ext.coffee']
      ['/ext/client/ext.js']
      ['/root/sub/sub2/ext/server/ext.coffee']
      ['/root/sub/sub2/ext/client/ext.coffee']
    ]

    expect(result.gameComponents).to.eql {root_sub_sub2_ext: true}

  it "should convert 'externals' to array if it's a string", ->
    fakeFS =
      readFileSync: -> """
config {externals: '../extProject/src'}
components {ext: true}"""
      existsSync: spy (p)-> p.includes 'extProject'

    loadGame {srcDir: '/games/game1/src/', fs: fakeFS}

    expect(fakeFS.existsSync.calls[4...6]).to.eql [
      ['/games/extProject/src/ext/server/ext.coffee']
      ['/games/extProject/src/ext/client/ext.coffee']
    ]
