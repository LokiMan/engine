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

  it 'should read scenes if they set', ->
    result = readGame """
scene 'first',
  cmp1: true
  cmp2: {}
"""

    expect(result.scenes).to.eql {
      first:
#        components:
        cmp1: true
        cmp2: {}
#        dir: ''
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

  it 'should read nested components', ->
    existsSpy = spy -> false

    try
      readGame 'components nested_levelTwo_andThree: true', existsSpy

    expect(existsSpy.calls).to.eql [
      ['nested/levelTwo/andThree/server/andThree.coffee']
      ['nested/levelTwo/andThree/server/andThree.js']
      ['nested/levelTwo/andThree/client/andThree.coffee']
      ['nested/levelTwo/andThree/client/andThree.js']
    ]

  it 'should use full path of external components', ->
    fakeFS =
      readFileSync: -> """
config {components: ext: '../extProject/src/sub/comp'}
components {ext: true}"""
      existsSync: spy -> true

    loadGame {srcDir: '', fs: fakeFS}

    expect(fakeFS.existsSync.calls).to.eql [
      ['../../extProject/src/sub/comp/server/comp.coffee']
      ['../../extProject/src/sub/comp/client/comp.coffee']
    ]
