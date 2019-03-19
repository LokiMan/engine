spy = require '../../../common/test_helpers/spy'

describe 'Read Game', ->
  loadGame = require '../../../game/server/loadGame'

  readGame = (content)->
    loadGame dir: '', file: '', readFile: -> content

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

  it 'should read included scenes', ->
    content = [
      """
scene 'first',
  cmp1: true
scene 'second',
  cmp1: true

include 'dir'
""",
      """
scene 'third',
  cmp2: true
"""
    ]

    readFile = ->
      content.shift()

    {scenes} = loadGame {dir: 'path/', file: 'file', readFile}

    expect(scenes).to.eql {
      first: {cmp1: true} #, dir: 'path/'
      second: {cmp1: true} #, dir: 'path/'
      'dir/third': {cmp2: true} #, dir: 'path/dir/'
    }
