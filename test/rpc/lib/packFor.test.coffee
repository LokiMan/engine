describe 'PakFor', ->
  PackFor = require '../../../rpc/lib/packFor'

  packFor = null

  beforeEach ->
    packFor = PackFor 'name'

  it 'should add component name if omitted', ->
    result = packFor ['cmd', 'arg']

    expect(result).to.equal '["name.cmd","arg"]'

  it 'should not add component name if present', ->
    result = packFor ['otherName.cmd', 'arg']

    expect(result).to.equal '["otherName.cmd","arg"]'

  it 'should process all commands if they are array of arrays', ->
    result = packFor [[['cmd', 1], ['name2.cmd2', 2]]]

    expect(result).to.eql '[["name.cmd",1],["name2.cmd2",2]]'

