constructGame = (gameComponents, scenes, componentsConstructors, Engine)->
  # game components
  createGameComponent = (name, value)->
    component = componentsConstructors[name]

    return if component.isClientOnly
      toClient: -> value
    else
      component.constructor value, (Engine name)

  for name, value of gameComponents
    gameComponents[name] = createGameComponent name, value


  #scenes components
  sceneComponentsConstructors = {}

  clientOnlyConstructor = (v)-> toClient: -> v

  createSceneComponent = (name, value, sceneId)->
    if not (constructor = sceneComponentsConstructors[name])?
      component = componentsConstructors[name]
      constructor = if component.isClientOnly
        clientOnlyConstructor
      else
        component.constructor (Engine name)
      sceneComponentsConstructors[name] = constructor

    constructor value, sceneId

  constructScene = (id, scene)->
    toClient = []

    for name, value of scene
      component = createSceneComponent name, value, id
      scene[name] = component
      if not componentsConstructors[name].isServerOnly
        toClient.push [name, component]

    scene.id = id
    scene.toClient = toClient

  for id, scene of scenes
    constructScene id, scene

  return

module.exports = constructGame
