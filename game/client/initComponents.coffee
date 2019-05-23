initComponents = (constructors, components, remote, info, scene, gui)->
  createComponent = (name, value)->
    div id: "#{name}_g", (container)->
      arg = {
        container
        components
        scene
        gui
        remote: remote.makeFor name
      }

      component = constructors[name] value, arg
      components[name] = component
      component.container = container

  console.info 'game:', info.reduce ((res, [name, value])-> res[name] = value; res), {}

  for [name, value] in info
    createComponent name, value

  return

module.exports = initComponents
