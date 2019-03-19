spy = require '../../../../common/test_helpers/spy'
FakeTimers = require '../../../../common/test_helpers/fakeTimers'

describe 'TryingWebSocket', ->
  TryingWebSocket = require '../../../../rpc/client/states/tryingWebSocket'

  createState = (connection, polling, webSocket, w, timers)->
    timers ?= wait: -> clear: (->)
    TryingWebSocket connection, polling, webSocket, w, timers

  it 'should polling.connect if no web-socket constructors', ->
    polling = connect: spy()

    createState {}, polling, {}, {}

    expect(polling.connect.calls).to.not.empty

  it 'should polling.subscribe if throw in calling web-socket constructor', ->
    polling = connect: spy()
    w = {location: {}, WebSocket: -> throw new Error()}

    createState {}, polling, {}, w

    expect(polling.connect.calls).to.not.empty

  it 'should use w.MozWebSocket if no w.WebSocket', ->
    MozWebSocket = spy()

    createState {}, {}, {}, {location: {}, MozWebSocket}

    expect(MozWebSocket.calls).to.not.empty

  it 'should polling.connect if occurs socket.onerror', ->
    polling = connect: spy()
    socket = {}
    createState {}, polling, {}, {location: {}, WebSocket: -> socket}

    socket.onerror()

    expect(polling.connect.calls).to.not.empty

  it 'should polling.connect if occurs socket.onclose', ->
    polling = connect: spy()
    socket = {}
    createState {}, polling, {}, {location: {}, WebSocket: -> socket}

    socket.onclose()

    expect(polling.connect.calls).to.not.empty

  it 'should switch to webSocket if all ok', ->
    connection = {}
    polling = subscribe: spy(), send: spy()
    webSocket = connect: spy()
    ws = {}
    w = {location: {}, WebSocket: (-> ws)}
    createState connection, polling, webSocket, w

    ws.onopen()

    expect(webSocket.connect.calls).to.eql [[ws]]

  it 'should switch to polling after 2 sec of trying', ->
    connection = {}
    polling = connect: spy()
    w = {location: {}, WebSocket: (->)}
    fakeTimers = FakeTimers()
    createState connection, polling, {}, w, fakeTimers

    fakeTimers.tick 3000

    expect(polling.connect.calls).to.not.empty

  it 'should clear 2 sec timer on web socket connect', ->
    connection = {}
    polling = connect: spy()
    webSocket = connect: spy()
    ws = {}
    w = {location: {}, WebSocket: (-> ws)}
    fakeTimers = FakeTimers()
    createState connection, polling, webSocket, w, fakeTimers

    ws.onopen()
    fakeTimers.tick 3000

    expect(polling.connect.calls).to.be.empty
