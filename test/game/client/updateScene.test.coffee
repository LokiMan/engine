spy = require '../../../common/test_helpers/spy'

describe 'Update Scene', ->
  UpdateScene = require '../../../game/client/updateScene'

  describe 'updateScene', ->
    it.skip 'should call remove if component exists and not in new', ->
      remove = spy()
      gui = div: (props, next)-> next {remove}
      updateScene = UpdateScene {component1: (->{}), component2: -> {}}, {}, gui

      updateScene {component1: '123'}
      updateScene {component2: 'asd'}

      expect(remove.calls).to.not.empty

    it 'should call component update (if has) on exists component in scene', ->
      component = updateComponent: spy()
      scene = {}
      scene.component1 = component
      updateScene = UpdateScene {}, scene, {}, {}, {}, {clearAll: ->}

      value = '123'
      updateScene [['component1', value]]

      expect(component.updateComponent.calls).to.eql [[value]]

    it.skip "should call remove if component exists and presents in new, but hasn't updateComponent()", ->
      remove = spy()
      gui = div: (props, next)-> next {remove}
      updateScene = UpdateScene {component1: -> {}}, {}, gui

      updateScene {component1: '123'}
      updateScene {component1: 'asd'}

      expect(remove.calls).to.not.empty

    it.skip 'should call div with id: name for new components', ->
      div = spy()
      updateScene = UpdateScene {}, {}, {div}

      updateScene {component1: 'asd'}

      expect(div.calls[0][0]).to.eql id: 'component1'
