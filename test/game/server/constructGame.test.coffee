spy = require '../../../common/test_helpers/spy'

describe 'Construct Game', ->
  constructGame = require '../../../game/server/constructGame'

  it 'should call game component constructors if no is client only', ->
    value = {a: 1}
    constructorSpy = spy()
    enginePart = {}

    constructGame {name: value}, {}, {name: constructorSpy}, -> enginePart

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

    constructGame {}, {scene1: {name: value}}, {name: constructorSpy}, Engine

    expect(constructorSpy.calls).to.deep.equal [[enginePart], [value]]

  it 'should return value on toClient if is client only', ->
    value = {a: 1}
    scenes = scene1: {name: value}
    constructorSpy = {isClientOnly: true}

    constructGame {}, scenes, {name: constructorSpy}

    expect(scenes.scene1.name.toClient()).to.equal value

  it 'should push to toClient only not is server only components', ->
    scenes = scene1: {name1: 1, name2: 2, name3: 3}
    component1 = (->)
    component2 = (->)
    component3 = (->)

    component2Factory = -> component2
    component2Factory.isServerOnly = true

    constructGame {}, scenes, {
      name1: -> -> component1
      name2: component2Factory
      name3: -> -> component3
    }, -> {}

    expect(scenes.scene1.toClient).to.deep.equal [
      ['name1', component1], ['name3', component3]
    ]

