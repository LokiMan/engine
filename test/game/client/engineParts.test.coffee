spy = require '../../../common/test_helpers/spy'

describe 'EngineParts', ->
  EngineParts = require '../../../game/client/engineParts'

  it 'should use PackFor for remote', ->
    send = spy()
    obj = {}
    packFor = spy -> obj
    PackFor = spy -> packFor
    engineParts = EngineParts {}, {}, {}, {}, send, PackFor
    {remote} = engineParts 'name'

    command = {}
    remote command

    expect(send.calls[0][0]).to.equal obj
    expect(PackFor.calls[0][0]).to.equal 'name'
    expect(packFor.calls[0][0][0]).to.equal command
    
  it 'should add component name to animate.fromTo', ->
    fromTo = spy()
    engineParts = EngineParts {}, {}, {}, {fromTo}, null, (->)
    {animate} = engineParts 'name'

    animate.fromTo {}

    expect(fromTo.calls).to.eql [[{}, 'name']]

  it 'should add component name to animate as part of object', ->
    animate = spy()
    engineParts = EngineParts {}, {}, {}, animate, null, (->)
    parts = engineParts 'name'

    parts.animate {a: 1}, 2

    expect(animate.calls).to.eql [[{a: 1, componentName: 'name'}, 2]]

  it 'should add component name as third argument if not object', ->
    animate = spy()
    engineParts = EngineParts {}, {}, {}, animate, null, (->)
    parts = engineParts 'name'

    parts.animate 1, 2

    expect(animate.calls).to.eql [[1, 2, 'name']]
