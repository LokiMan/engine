spy = require '../../../common/test_helpers/spy'

describe 'Engine', ->
  EngineFactory = require '../../../game/server/engineParts'

  it 'should call remote callFor with name', ->
    callFor = spy()
    Engine = EngineFactory remotes: get: -> {callFor}
    engine = Engine 'name1'

    engine.remote {}, 1, 'a'

    expect(callFor.calls).to.eql [['name1', [1, 'a']]]

  it 'should call broadcastOnline with name', ->
    packFor = spy()
    Engine = EngineFactory {remotes: values: (-> []), packFor}
    engine = Engine 'name1'

    engine.broadcastOnline 2, 'b'

    expect(packFor.calls).to.eql [['name1', [2, 'b']]]

  it 'should call broadcast with name', ->
    packFor = spy()
    Engine = EngineFactory {packFor}
    engine = Engine 'name1'

    engine.broadcast [], 2, 'b'

    expect(packFor.calls).to.eql [['name1', [2, 'b']]]

