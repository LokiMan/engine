constructGame = (gameComponents, scenes, componentsConstructors, Engine)->
  # game components
  createGameComponent = (name, value)->
    componentConstructor = componentsConstructors[name]

    return if componentConstructor.isClientOnly
      toClient: -> value
    else
      componentConstructor value, (Engine name)

  for name, value of gameComponents
    gameComponents[name] = createGameComponent name, value


  #scenes components
  sceneComponentsConstructors = {}

  createSceneComponent = (name, value)->
    if not (constructor = sceneComponentsConstructors[name])?
      componentConstructor = componentsConstructors[name]
      constructor = if componentConstructor.isClientOnly
        -> toClient: -> value
      else
        componentConstructor (Engine name)
      sceneComponentsConstructors[name] = constructor

    constructor value

  constructScene = (id, scene)->
    toClient = []

    for name, value of scene
      component = createSceneComponent name, value
      scene[name] = component
      if not componentsConstructors[name].isServerOnly
        toClient.push [name, component]

    scene.id = id
    scene.toClient = toClient

  for id, scene of scenes
    constructScene id, scene

  return

module.exports = constructGame
