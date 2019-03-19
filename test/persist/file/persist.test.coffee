spy = require '../../../common/test_helpers/spy'

describe.skip 'Persistent Observer', ->
  Persist = require '../../../persist/file/persist'

  it 'should apply changes if changes.json exists', ->
    fakeFS =
      existsSync: -> true
      openSync: (path)-> path
      ftruncateSync: ->
      writeSync: ->
      closeSync: ->
      createWriteStream: ->
      readFileSync: (path)->
        if path is 'data.json'
          '{ "players": {"plID":{}} }'
        else if path is 'changes.json'
          """
["set",["players","plID","location"],{"path":"center"}]
["set",["players","plID","scene"],{"name":"duel#1"}]

"""

    storage = Persist './', fakeFS
    expect(storage.get ['players', 'plID']).to.eql
      location:
        path: 'center'
      scene:
        name: 'duel#1'

  it 'should write to changes file and call onUpdate on changes in observer', (done)->
    spyWrite = spy()

    fakeFS =
      existsSync: (path)-> return path is 'data.json'
      openSync: (path)-> path
      ftruncateSync: ->
      writeSync: ->
      closeSync: ->
      createWriteStream: -> write: spyWrite
      readFileSync: (path)->
        if path is 'data.json'
          '{ "players": {"plID":{}} }'

    storage = Persist './', fakeFS

    storage.set ['players', 'plID'], {scene: {name: 'scene2'}}

    storage.del ['players', 'plID', 'scene']

    process.nextTick ->
      expect(spyWrite.calls).to.eql [
        ['[["set",["players","plID"],{"scene":{"name":"scene2"}}],["del",["players","plID","scene"]]]\n']
      ]
      done()

  it "should write to file 'null' if get 'undefined'", (done)->
    spyWrite = spy()

    fakeFS =
      existsSync: (path)-> return path is 'data.json'
      openSync: (path)-> path
      ftruncateSync: ->
      writeSync: ->
      closeSync: ->
      createWriteStream: -> write: spyWrite
      readFileSync: (path)->
        if path is 'data.json'
          '{ "players": {"plID":{"scene":{}}} }'

    storage = Persist './', fakeFS

    storage.set ['players', 'plID', 'scene'], undefined

    process.nextTick ->
      expect(spyWrite.calls).to.eql [
        ['["set",["players","plID","scene"],null]\n']
      ]

      done()

  it 'should apply array of commands', ->
    fakeFS =
      existsSync: -> true
      openSync: (path)-> path
      ftruncateSync: ->
      writeSync: ->
      closeSync: ->
      createWriteStream: ->
      readFileSync: (path)->
        if path is 'data.json'
          '{ "players": {"plID":{}} }'
        else if path is 'changes.json'
          """
["set",["players","plID","location"],{"path":"center"}]
[["set",["players","plID","location"],{"path":"center2"}], ["set",["players","plID","location"],{"path":"center3"}]]
"""

    storage = Persist './', fakeFS
    expect(storage.get ['players', 'plID']).to.eql
      location:
        path: 'center3'

  it 'should write transaction as array of commands', (done)->
    spyWrite = spy()

    fakeFS =
      existsSync: (path)-> return path is 'data.json'
      openSync: (path)-> path
      ftruncateSync: ->
      writeSync: ->
      closeSync: ->
      createWriteStream: -> write: spyWrite
      readFileSync: (path)->
        if path is 'data.json'
          '{ "players": {"plID":{"scene":{}}} }'

    storage = Persist './', fakeFS

    storage.set ['players', 'plID', 'scene'], undefined
    storage.set ['players', 'plID', 'scene'], '123'

    process.nextTick ->
      expect(spyWrite.calls).to.eql [
        ['[["set",["players","plID","scene"],null],["set",["players","plID","scene"],"123"]]\n']
      ]

      done()

  it 'should thrown error on broken transaction', ->
    fakeFS =
      existsSync: -> true
      openSync: (path)-> path
      ftruncateSync: ->
      writeSync: ->
      closeSync: ->
      createWriteStream: ->
      readFileSync: (path)->
        if path is 'data.json'
          '{ "players": {"plID":{}} }'
        else if path is 'changes.json'
          """
["set",["players","plID","location"],{"path":"center"}]
[["set",["players","plID","location"],{"path":"center2"}], ["set",["players","plID","location"],{"path":"center3"}]]
[["set",["players","plID","location"],{"path":"center4"}], ["set",["play

"""

    fn = ->
      Persist './', fakeFS

    expect(fn).to.throw 'On parse changes on line'
