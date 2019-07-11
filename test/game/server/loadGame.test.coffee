spy = require '../../../common/test_helpers/spy'

describe 'Read Game', ->
  loadGame = require '../../../game/server/loadGame'

  readGame = (content)->
    loadGame readFile: -> content

  it 'should read game components if they set', ->
    result = readGame """
components
  first: true
  second: {}
"""

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
