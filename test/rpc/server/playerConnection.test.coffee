spy = require '../../../common/test_helpers/spy'
FakeTimers = require '../../../common/test_helpers/fakeTimers'
appendMethod = require '../../../common/appendMethod'

describe 'Player Connection', ->
  PlayerConnection = require '../../../rpc/server/playerConnection'
  WebSocketFactory = require '../../../rpc/server/websocket'
  Polling = require '../../../rpc/server/polling'

  fakeTimers = null

  beforeEach ->
    fakeTimers = FakeTimers()

  it 'should just close connection if no player', ->
    connectPlayer = PlayerConnection (-> null)

    connectPlayer (connection = close: spy())

    expect(connection.close.calls).to.not.empty

  createWebSocketConnection = ({
    player = {uid: 'testUid1'}, components, connections = new Map
  } = {})->
    obtainPlayer = (-> player)

    if not components?
      components =
        notify: (->), execute: (->), gameComponentsToClient: (->)
        sceneToClient: (->)

    wait = fakeTimers.wait
    connectPlayer = PlayerConnection obtainPlayer, components, connections, wait
    WebSocket = null
    WebSocketFactory {on: (_, cb)-> WebSocket = cb}, connectPlayer

    createTransport = ->
      socket =
        send: spy()
        close: spy -> socket.onClose?()
        on: ((name, cb)-> @['on' + name[0].toUpperCase() + name[1..]] = cb)

      WebSocket socket, {}
      return socket

    {transport: createTransport(), player, connections, createTransport}

  createPollingConnection = ({
    player = {uid: 'testUid1'}, components, connections = new Map
  } = {})->
    obtainPlayer = (-> player)

    if not components?
      components =
        notify: (->), execute: (->), gameComponentsToClient: (->)
        sceneToClient: (->)

    wait = fakeTimers.wait
    connectPlayer = PlayerConnection obtainPlayer, components, connections, wait
    router = {get: {}, post: {}}
    Polling router, connectPlayer, undefined, wait

    createTransport = ->
      transport = send: spy(), close: (-> res2.end())

      cid = null
      res =
        end: ((m)-> cid = m[0...10]; transport.send m[10...])
        setHeader: (->)
      router.get['/connection/connect'] {}, res

      res2 = {
        on: ((name, cb)-> res2['on' + name[0].toUpperCase() + name[1..]] = cb)
        removeListener: spy (name, cb)->
          eventName = 'on' + name[0].toUpperCase() + name[1..]
          expect(res2[eventName]).to.equal cb
          delete res2[eventName]
        setHeader: spy()
        end: (m) ->
          transport.send m if m?
          res2.onClose?()
      }

      router.get['/connection/:cid'] {params: {cid}}, res2

      return transport

    {transport: createTransport(), player, connections, createTransport}

  checkByTransport = (createTransportConnection)->
    it "should send 'disconnect' to previous connection if exists", ->
      player = {}
      connections = new Map
      {transport} = createTransportConnection {player, connections}

      createTransportConnection {player, connections}

      expect(transport.send.calls[1]).to.eql ['disconnect']

    it 'should send from components online() after init', ->
      connections = new Map

      {transport} = createTransportConnection {
        components:
          notify: (player)-> connections.get(player).send JSON.stringify [5, 6]
          gameComponentsToClient: (-> [1, 2])
          sceneToClient: (-> [3, 'a'])
          execute: (->)
        connections
      }

      expect(transport.send.calls).to.eql [
        [ '["init",[[1,2],[3,"a"]]]' ]
        ['[5,6]']
      ]

    it 'should skip notify online if has previous connection', ->
      {player, connections} = createTransportConnection()
      components =
        notify: spy()
        gameComponentsToClient: (->), sceneToClient: (->), execute: (->)

      createTransportConnection {player, components, connections}

      expect(components.notify.calls).to.be.empty

    it 'should unpack message', ->
      components =
        execute: spy()
        gameComponentsToClient: (->), sceneToClient: (->), notify: (->)
      {connections, player} = createTransportConnection {components}

      connections.get(player).onMessage JSON.stringify ['target.action', 1, 2]

      expect(components.execute.calls).to.eql [
        [player, 'target', 'action', [1, 2]]
      ]

    it 'should notify offline after 5 sec', ->
      components =
        notify: spy()
        gameComponentsToClient: (->), sceneToClient: (->), execute: (->)
      {transport, player} = createTransportConnection {components}

      transport.close()
      fakeTimers.tickByStep 5000, 1000

      expect(components.notify.calls[1]).to.eql [player, 'offline']

    it 'should not offline notify if was reconnect', ->
      components =
        notify: spy()
        gameComponentsToClient: (->), sceneToClient: (->), execute: (->)
      {
        transport, player, createTransport
      } = createTransportConnection {components}
      transport.close()

      createTransport()
      fakeTimers.tickByStep 5000, 1000

      expect(components.notify.calls).to.eql [[player, 'online']]

    it 'should not has connection on closed transport', ->
      {transport, player, connections} = createTransportConnection()

      transport.close()

      expect(connections.has(player)).to.be.false

  checkByTransport createWebSocketConnection

  it 'should close previous connection', ->
    {transport, createTransport} = createWebSocketConnection()

    createTransport()

    expect(transport.close.calls).to.not.empty

  checkByTransport createPollingConnection
