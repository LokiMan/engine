spy = require '../../../common/test_helpers/spy'

describe 'initComponents', ->
  initComponents = require '../../../game/client/initComponents'

  createComponents = ({
    gui = {}, constructors, info, Engine = (->)
  } = {})->
    components = {}
    initComponents gui, constructors, components, info, Engine, {info: ->}
    return components

  it 'should skip container if constructor.skipContainer', ->
    constructors = test: -> {}
    constructors.test.skipContainer = true

    components = createComponents {
      constructors
      info: [['test', 1]]
    }

    expect(components.test.container).to.be.undefined

  it 'should create container for components', ->
    container = {}
    div = (props, next)-> next container
    components = createComponents {
      gui: {div}
      constructors: test: (-> {}), test2: (-> {})
      info: [['test', 1], ['test2', 2]]
      Engine: (-> {})
    }

    expect(components.test.container).to.equal container
    expect(components.test2.container).to.equal container

  it 'should add engine arg to component constructors', ->
    div = (props, next)-> next {}
    testConstructor = spy -> {}
    engine = {}

    createComponents {
      gui: {div}
      constructors: test: testConstructor
      info: [['test', 1]]
      Engine: (-> engine)
    }

    expect(testConstructor.calls).to.eql [[1, engine]]

