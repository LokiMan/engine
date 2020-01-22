spy = require '../../../common/test_helpers/spy'

describe 'Update Scene', ->
  UpdateScene = require '../../../game/client/updateScene'

  createUpdateScene = ({
    gui = {}, componentsConstructors = {}, scene = {}, animate = {removeBy: ->}
    Engine = (-> {})
  } = {})->
    sceneContainer = append: (next)-> next()
    UpdateScene gui, componentsConstructors, scene, sceneContainer, animate,
      Engine, {info: ->}

  it 'should call remove if component exists and not in new scene', ->
    remove = spy()
    gui = div: (props, next)-> next {remove}
    component1 = {removeComponent: spy()}
    componentsConstructors = {component1: (-> component1), component2: -> {}}
    updateScene = createUpdateScene {gui, componentsConstructors}

    updateScene [['component1', '123']]
    updateScene [['component2', 'asd']]

    expect(remove.calls).to.not.empty
    expect(component1.removeComponent.calls).to.not.empty

  it 'should call component update (if has) on exists component in scene', ->
    component = updateComponent: spy()
    scene = {}
    scene.component1 = component
    updateScene = createUpdateScene {scene}

    value = '123'
    updateScene [['component1', value]]

    expect(component.updateComponent.calls).to.eql [[value]]

  it "should call remove if component exists and presents in new, but hasn't
      updateComponent()", ->
    remove = spy()
    gui = div: (props, next)-> next {remove}
    componentsConstructors = {component1: (->{})}
    updateScene = createUpdateScene {gui, componentsConstructors}

    updateScene [['component1', '123']]
    updateScene [['component1', 'asd']]

    expect(remove.calls).to.not.empty

  it 'should call div with id: name for new components', ->
    div = spy()
    componentsConstructors = {component1: (->)}
    updateScene = createUpdateScene {gui: {div}, componentsConstructors}

    updateScene [['component1', 'asd']]

    expect(div.calls[0][0]).to.eql id: 'component1_s'

  it 'should skip container if constructor.skipContainer', ->
    component = {}
    componentConstructor = (-> component)
    componentConstructor.skipContainer = true
    componentsConstructors = {component1: componentConstructor}
    updateScene = createUpdateScene {componentsConstructors}

    updateScene [['component1', '123']]

    expect(component.container).to.be.undefined
