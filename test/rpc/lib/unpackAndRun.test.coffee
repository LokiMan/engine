spy = require '../../../common/test_helpers/spy'

describe 'UnpackAndRun', ->
  UnpackAndRun = require '../../../rpc/lib/unpackAndRun'

  it 'should catch errors on wrong parsing', ->
    unpackAndRun = UnpackAndRun (->)

    fn = ->
      unpackAndRun 'a'

    expect(fn).to.not.throw()

  it 'should split target action if dot present', ->
    onCommand = spy()
    unpackAndRun = UnpackAndRun onCommand

    unpackAndRun JSON.stringify ['target1.action1', 1, 2]

    expect(onCommand.calls).to.eql [
      ['target1', 'action1', [1, 2]]
    ]

  it 'should no split if action without dot', ->
    onCommand = spy()
    unpackAndRun = UnpackAndRun onCommand

    unpackAndRun JSON.stringify ['action2', 1, 2]

    expect(onCommand.calls).to.eql [
      ['', 'action2', [1, 2]]
    ]

  it 'should run each command separate if they are array', ->
    onCommand = spy()
    unpackAndRun = UnpackAndRun onCommand

    unpackAndRun JSON.stringify [
      ['target3.action3', 1, 'b'],
      ['action4', 'a', 2]
    ]

    expect(onCommand.calls).to.eql [
      ['target3', 'action3', [1, 'b']]
      ['', 'action4', ['a', 2]]
    ]