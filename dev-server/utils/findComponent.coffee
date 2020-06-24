findComponent = (pathParts, componentsConstructors)->
  paths = []

  for path in pathParts
    paths.push path

    if paths.join('_') of componentsConstructors
      return paths.join '/'

  return null

module.exports = findComponent
