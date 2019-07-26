spy = require '../../../common/test_helpers/spy'

describe 'remote', ->
  Remote = require '../../../rpc/lib/remote'

  it 'should stringify array-command on call', ->
    connection = send: spy(), on: (->)
    remote = Remote connection
    command = ['a', 1, '2']

    remote command...

    expect(connection.send.calls).to.eql [[JSON.stringify(command)]]

  it 'should parse command on onMessage', ->
    connection = {}
    Remote connection, onCommand = spy()

    connection.onMessage JSON.stringify(['name.fnc', 1, 'b'])

    expect(onCommand.calls).to.eql [
      [{target: 'name', action: 'fnc', args: [1, 'b']}]
    ]

  it 'should catch errors on parsing', ->
    connection = {}
    Remote connection, onCommand = spy()

    fn = ->
      connection.onMessage 'a.b = 1'

    expect(fn).to.not.throw()

  it 'should can call several commands if get array of them', ->
    connection = {}
    Remote connection, onCommand = spy()

    connection.onMessage JSON.stringify [
      ['name.fnc1', 1]
      ['name.fnc2', 'b']
    ]

    expect(onCommand.calls).to.eql [
      [{target: 'name', action: 'fnc1', args: [1]}]
      [{target: 'name', action: 'fnc2', args: ['b']}]
    ]

  it 'should skip target if no dot in command name', ->
    connection = {}
    Remote connection, onCommand = spy()

    connection.onMessage JSON.stringify(['fnc', 1, 'b'])

    expect(onCommand.calls).to.eql [
      [{target: '', action: 'fnc', args: [1, 'b']}]
    ]
