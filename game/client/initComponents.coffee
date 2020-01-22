initComponents = ({div}, constructors, components, info, Engine, logger)->
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

  asObject = info.reduce ((res, [name, value])-> res[name] = value; res), {}
  logger.info 'game:', asObject

  for [name, value] in info
    createComponent name, value

  return

module.exports = initComponents
