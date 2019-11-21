initComponents = (constructors, components, info, Engine)->
  createComponent = (name, value)->
    constructor = constructors[name]

    arg = Engine name

    if constructor.skipContainer
      component = constructor value, arg
    else
      div id: "#{name}_g", (container)->
        arg.container = container
        component = constructor value, arg
        component.container = container

    components[name] = component

  console.info 'game:', info.reduce ((res, [name, value])-> res[name] = value; res), {}

  for [name, value] in info
    createComponent name, value

  return

module.exports = initComponents
