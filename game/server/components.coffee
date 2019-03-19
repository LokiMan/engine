Components = (gameComponents, logger)->
  toClientComponents = []
  listGameComponents = []

  for name, component of gameComponents
    listGameComponents.push component

    if component.toClient?
      toClientComponents.push {name, component}

  gameComponentsToClient = (player)->
    result = []

    for {name, component} in toClientComponents
      result.push [name, component.toClient player]

    return result

  execute = (player, {target, action, args})->
    component = player.scene[target] ? gameComponents[target]

    if component?
      try
        component.$remotes$?[action]? player, args...
      catch e
        logger.exception e

  notifyGameComponents = (player, functionName)->
    for component in listGameComponents
      component[functionName]? player
    return

  {
    gameComponentsToClient, execute
    sceneToClient: Components.sceneToClient
    callSceneComponents: Components.callSceneComponents
    notifyGameComponents
  }

Components.sceneToClient = (player, fromScene)->
  result = []

  for [name, component] in player.scene.toClient
    result.push [name, component.toClient player, fromScene]

  return result

Components.callSceneComponents = (player, functionName, args...)->
  for name, component of player.scene
    component[functionName]? player, args...
  return

module.exports = Components
