FindComponent = (srcDirs, name, existsSync = require('fs').existsSync)->
  findFile = (path)->
    return existsSync(path + '.coffee') or existsSync(path + '.js')

  if name.lastIndexOf('_') > 0
    isNested = true
    replaced = name.replace /(?!^)_+/g, (m)-> '/' + m[1..]
    index = replaced.lastIndexOf '/'
    addPath = replaced[..index]
    name = replaced[(index + 1)..]
  else
    addPath = ''

  tryFind = (pathTo)->
    pathToServer = "#{pathTo}server/#{name}"

    if findFile pathToServer
      result = {pathToServer}

    pathToClient = "#{pathTo}client/#{name}"

    if findFile pathToClient
      if result?
        result.pathToClient = pathToClient
      else
        result = {pathToClient, isClientOnly: true}
    else if result?
      result.isServerOnly = true

    result

  for srcDir in srcDirs
    return result if (result = tryFind "#{srcDir}#{addPath}#{name}/")

    if isNested
      return result if (result = tryFind "#{srcDir}#{addPath}")

  return null

module.exports = FindComponent
