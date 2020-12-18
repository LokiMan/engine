spy = require '../../../common/test_helpers/spy'

describe 'Engine', ->
  EngineParts = require '../../../game/server/engineParts'

  createEngineParts = (connections, logger)->
    PackFor = (componentName)-> (command)-> [componentName, command]
    EngineParts {PackFor, connections, logger}

  it 'should call remote callFor with name', ->
    send = spy()
    connections = get: -> {send}
    Engine = createEngineParts connections
    {remote} = Engine 'name1'

    remote {}, 1, 'a'

    expect(send.calls).to.eql [[['name1', [1, 'a']]]]

  it 'should call broadcast with name', ->
    send = spy()
    connections = get: -> {send}
    Engine = createEngineParts connections
    {broadcast} = Engine 'name1'

    broadcast [{}], 2, 'b'

    expect(send.calls).to.eql [[['name1', [2, 'b']]]]

  it 'should skip excepted player on broadcastExcept', ->
    get = spy()
    {broadcastExcept} = createEngineParts({get})()
    players = [{a: 1}, {b: 2}, {c: 3}]

    broadcastExcept players, players[1]

    expect(get.calls).to.eql [[players[0]], [players[2]]]

  it 'should call broadcastOnline with name', ->
    send = spy()
    connections = values: -> [{send}]
    Engine = createEngineParts connections
    {broadcastOnline} = Engine 'name1'

    broadcastOnline 2, 'b'

    expect(send.calls).to.eql [[['name1', [2, 'b']]]]

  it "should send 'reSync' on deSync", ->
    send = spy()
    info = spy()
    connections = get: -> {send}
    Engine = createEngineParts connections, {info}
    {deSync} = Engine 'name1'

    deSync {id: 1, scene: id: 2}

    expect(send.calls).to.eql [['["reSync"]']]
    expect(info.calls).to.eql [['deSync(1, 2.name1):']]

  it 'should not thrown if no connection for player', ->
    connections = get: -> null
    Engine = createEngineParts connections, {info: (->)}
    {deSync} = Engine 'name1'

    fn = ->
      deSync {id: 1, scene: id: 2}

    expect(fn).to.not.throw()

