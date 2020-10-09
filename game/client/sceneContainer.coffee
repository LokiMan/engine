{append} = require '../../common/appendPrepend'

SceneContainer = (scene, gameComponents)->
  sceneContainer = div
    id: 'scene'
    pos: [0, 0, '100%', '100%']
    style:
      overflowX: 'hidden'
      overflowY: 'auto'

  append sceneContainer, 'update', (props)->
    return if not props.pos?

    height = props.pos['height'] ? props.pos[3]
    if height?
      for name, component of scene
        component.onSceneResize? height

      for name, component of gameComponents
        component.onSceneResize? height

      return

  return sceneContainer

module.exports = SceneContainer
