spy = require '../../../common/test_helpers/spy'
FakeTimers = require '../../../common/test_helpers/fakeTimers'

describe 'Heartbeat', ->
  Heartbeat = require '../../../rpc/server/heartbeat'

  fakeTimers = null

  beforeEach ->
    fakeTimers = FakeTimers()

  it 'should terminate sockets if they is not alive', ->
    onConnection = null
    wss = {
      on: ( (_, cb)-> onConnection = cb)
      clients: []
    }

    connect = ->
      ws = {
        on: ((name, cb)-> ws['on' + name[0].toUpperCase() + name[1..]] = cb)
        ping: (->)
        terminate: spy()
      }
      onConnection ws
      wss.clients.push ws
      return ws

    Heartbeat wss, fakeTimers.interval

    ws1 = connect()
    ws2 = connect()
    ws3 = connect()

    fakeTimers.tickByStep 30000, 30000

    ws2.onPong()

    fakeTimers.tickByStep 30000, 30000

    expect(ws1.terminate.calls).to.not.empty
    expect(ws2.terminate.calls).to.be.empty
    expect(ws3.terminate.calls).to.not.empty
