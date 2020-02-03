UpdateScene = (
  {div}, componentsConstructors, scene, sceneContainer, animate, Engine, logger
)->
  componentsContainers = {}

  updateComponent = (name, value)->
    if (component = scene[name])? and component.updateComponent?
      component.updateComponent value
    else
      if (container = componentsContainers[name])?
        container.remove()

      arg = Engine name

      componentConstructor = componentsConstructors[name]

      if componentConstructor.skipContainer
        component = componentConstructor value, arg
      else
        sceneContainer.append ->
          div id: "#{name}_s", (container)->
            arg.container = container
            component = componentConstructor value, arg
            component.container = container
            componentsContainers[name] = container

      scene[name] = component

  (components)->
    componentsObj = {}
    for [name, value] in components
      componentsObj[name] = value

    logger.info 'scene:', componentsObj

    for name, component of scene
      if not componentsObj[name]?
        component.removeComponent?()
        animate.removeBy name
        delete scene[name]
        if (container = componentsContainers[name])?
          container.remove()
          delete componentsContainers[name]

    for [name, value] in components
      updateComponent name, value

    return

module.exports = UpdateScene
