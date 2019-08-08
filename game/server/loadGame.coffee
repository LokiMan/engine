coffee = require 'coffeescript'
path = require 'path'

loadGame = ({
  srcDir, gameFile, env, fs = require('fs'), load = (->{})
  config = {}
})->
  gameComponents = {}
  scenes = {}

  componentsConstructors = {}
  componentsRequires = []

  loadComponentConstructor = (name)->
    return if componentsConstructors[name]?

    if (relPath = config.components?[name])?
      pathTo = path.join (srcDir + '../'), relPath

      index = relPath.lastIndexOf '/'
      nameFile = relPath[(index + 1)..]
    else
      [pathTo, nameFile] = findComponentDir name

    pathToServer = "#{pathTo}/server/#{nameFile}"
    if fs.existsSync pathToServer + '.coffee'
      componentConstructor = load pathToServer

      if not fs.existsSync "#{pathTo}/client/#{nameFile}.coffee"
        componentConstructor.isServerOnly = true
    else if fs.existsSync "#{pathTo}/client/#{nameFile}.coffee"
      componentConstructor = isClientOnly: true
    else
      throw new Error "Component '#{name}' not found."

    if not componentConstructor.isServerOnly
      relPath = path.relative srcDir, pathTo
      reqPath = if relPath[0] is '.' then relPath else "./#{relPath}"
      reqLine = "  #{name}: require '#{reqPath}/client/#{nameFile}'"
      componentsRequires.push reqLine

    componentsConstructors[name] = componentConstructor

  findComponentDir = (name)->
    pathName = name.replace /(?!^)_/g, '/'

    pathTo = "#{srcDir}#{pathName}"

    index = pathName.lastIndexOf '/'
    nameFile = if index is -1 then pathName else pathName[(index + 1)..]

    [pathTo, nameFile]

  content = fs.readFileSync srcDir + gameFile + '.coffee', encoding: 'utf8'

  loadGameComponents = (componentsInfo)->
    for name, value of componentsInfo
      loadComponentConstructor name
      gameComponents[name] = value
    return

  scene = (id, sceneComponents)->
    sceneID = id

    if scenes[sceneID]?
      throw new Error "Duplicated scene id = #{sceneID}"

    for name, value of sceneComponents
      loadComponentConstructor name

    scenes[sceneID] = sceneComponents

  loadConfig = (configData)->
    for key, value of configData
      config[key] = value
    return

  sandbox =
    env: env
    config: loadConfig
    components: loadGameComponents
    scene: scene

  coffee.eval content, {sandbox}

  requiresSource = """
(require 'game/client/index') {
#{componentsRequires.join '\n'}
}
"""

  return {gameComponents, scenes, componentsConstructors, requiresSource}

module.exports = loadGame
