constructGame = (gameComponents, scenes, componentsConstructors, Engine)->
  createComponent = (name, value)->
    componentConstructor = componentsConstructors[name]

    return if componentConstructor.isClientOnly
      toClient: -> value
    else
      componentConstructor value, (Engine name)

  for name, value of gameComponents
    gameComponents[name] = createComponent name, value

  constructScene = (id, scene)->
    toClient = []

    for name, value of scene
      component = createComponent name, value
      scene[name] = component
      if not componentsConstructors[name].isServerOnly
        toClient.push [name, component]

    scene.id = id
    scene.toClient = toClient

  for id, scene of scenes
    constructScene id, scene

  return

module.exports = constructGame
