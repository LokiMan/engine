findComponent = (pathParts, componentsConstructors)->
  paths = [pathParts...]

  loop
    if paths.join('_') of componentsConstructors
      return paths.join '/'

    paths.pop()

    break if paths.length is 0

  return null

module.exports = findComponent
