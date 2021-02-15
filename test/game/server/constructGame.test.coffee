spy = require '../../../common/test_helpers/spy'

describe 'Construct Game', ->
  constructGame = require '../../../game/server/constructGame'

  it 'should call game component constructors if no is client only', ->
    value = {a: 1}
    constructorSpy = spy()
    enginePart = {}
    Engine = -> enginePart

    constructGame {name: value}, {}, {name: constructor: constructorSpy}, Engine

    expect(constructorSpy.calls).to.deep.equal [[value, enginePart]]

  it 'should not call constructor if is client only', ->
    constructorSpy = spy()
    constructorSpy.isClientOnly = true

    constructGame {name: ''}, {}, {name: constructorSpy}

    expect(constructorSpy.calls).to.be.empty

  it 'should return value on toClient if is client only', ->
    value = {a: 1}
    gameComponents = {name: value}
    constructorSpy = {isClientOnly: true}

    constructGame gameComponents, {}, {name: constructorSpy}

    expect(gameComponents.name.toClient()).to.equal value

  it 'should create scene components from double factory', ->
    value = {a: 1}
    constructorSpy = spy (-> constructorSpy)
    enginePart = {}
    Engine = -> enginePart

    constructGame {}, {scene1: {name: value}},
      {name: constructor: constructorSpy}, Engine

    expect(constructorSpy.calls).to.deep.equal [[enginePart], [value, 'scene1']]

  it 'should return value on toClient if is client only', ->
    value = {a: 1}
    value2 = {b: 2}
    scenes =
      scene1: {name: value}
      scene2: {name: value2}

    constructGame {}, scenes,
      name: {isClientOnly: true}
      name2: {isClientOnly: true}

    expect(scenes.scene1.name.toClient()).to.equal value
    expect(scenes.scene2.name.toClient()).to.equal value2

  it 'should push to toClient only not is server only components', ->
    scenes = scene1: {name1: 1, name2: 2, name3: 3}
    component1 = (->)
    component2 = (->)
    component3 = (->)

    constructGame {}, scenes, {
      name1: constructor: -> -> component1
      name2: isServerOnly: true, constructor: -> -> component2
      name3: constructor: -> -> component3
    }, -> {}

    expect(scenes.scene1.toClient).to.deep.equal [
      ['name1', component1], ['name3', component3]
    ]

  it 'should pass scene id to scene component constructor', ->
    constructorSpy = spy()

    constructGame {},
      {scene1: {name: 'value'}},
      {name: constructor: -> constructorSpy},
      (->)

    expect(constructorSpy.calls).to.eql [['value', 'scene1']]
