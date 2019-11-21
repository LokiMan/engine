spy = require '../../../common/test_helpers/spy'

describe 'GoTo', ->
  GoTo = require '../../../game/server/goTo'

  it 'should set collection if not exists', ->
    storage = {has: (-> false), set: spy()}

    GoTo storage, {}, '', {}

    expect(storage.set.calls).to.not.equal

  describe 'onPlayer', ->
    it 'should set start scene if no scene', ->
      storage = {has: (-> false), set: spy()}
      goTo = GoTo storage, {}, 'start', {}

      goTo.onPlayer {}

      expect(storage.set.calls[0][1]).to.eql 'start'

    it 'should set player.scene to return current scene', ->
      storage = {has: (-> true), get: -> 'sceneID'}
      scene = {}
      goTo = GoTo storage, {sceneID: scene}, 'start', {}

      goTo.onPlayer player = {}
      expect(player.scene).to.equal scene

    describe 'player.goTo', ->
      it 'should log error if not scene to go', ->
        storage = {has: (-> true), get: -> 'sceneID'}
        scene = {}
        logger = error: spy()
        goTo = GoTo storage, {sceneID: scene}, 'start', {}, {}, logger
        goTo.onPlayer player = {id: 'uid'}

        player.goTo 'not_exists_scene'

        expect(logger.error.calls).to.eql [
          ["Scene doesn't exists: not_exists_scene, uid: uid"]
        ]

      it 'should call current component.leave with next scene', ->
        storage = {has: (-> true), get: (-> 'scene1'), set: spy()}
        components = callSceneComponents: spy(), sceneToClient: -> 'sceneData'
        scenes = {scene1: {id: 'scene1'}, scene2: {id: 'scene2'}}
        remote = spy()
        goTo = GoTo storage, scenes, 'start', components, {get: -> send: remote}
        goTo.onPlayer player = {}

        player.goTo 'scene2'

        expect(components.callSceneComponents.calls).to.eql [
          [player, 'leave', scenes.scene2]
          [player, 'enter', scenes.scene1]
        ]

        expect(storage.set.calls[0][1]).to.eql 'scene2'

        expect(remote.calls).to.eql [
          [JSON.stringify ['updateScene', 'sceneData']]
        ]
