UpdateScene = (
  scenesComponentsConstructors, scene, remote, sceneContainer, gameComponents,
  animate, gui
)->
  componentsContainers = {}

  updateComponent = (name, value)->
    if (component = scene[name])? and component.updateComponent?
      component.updateComponent value
    else
      if (container = componentsContainers[name])?
        container.remove()

      sceneContainer.append ->
        div id: "#{name}_s", (container)->
          arg = {
            container
            components: gameComponents
            scene
            gui
            remote: remote.makeFor name
          }
          component = scenesComponentsConstructors[name] value, arg
          component.container = container

          scene[name] = component
          componentsContainers[name] = container
    return

  (components)->
    animate.clearAll()

    componentsObj = {}
    for [name, value] in components
      componentsObj[name] = value

    console.info 'scene:', componentsObj

    for name, component of scene when name isnt '__world'
      if not componentsObj[name]?
        scene[name].removeComponent?()
        delete scene[name]
        componentsContainers[name].remove()
        delete componentsContainers[name]

    for [name, value] in components
      updateComponent name, value

    return

module.exports = UpdateScene
