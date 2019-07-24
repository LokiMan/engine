coffee = require 'coffeescript'
path = require 'path'

loadGame = (
  {srcDir, gameFile, components = {}, env, fs = require('fs'), load = (->{})}
)->
  gameComponents = {}
  scenes = {}

  componentsConstructors = {}
  componentsRequires = []

  loadComponentConstructor = (name)->
    return if componentsConstructors[name]?

    dir = if (relPath = components[name])?
      path.join (srcDir + '../'), (relPath + '/')
    else
      srcDir

    pathTo = "#{dir}#{name}"

    pathToServer = "#{pathTo}/server/#{name}"
    if fs.existsSync pathToServer + '.coffee'
      componentConstructor = load pathToServer

      if not fs.existsSync "#{pathTo}/client/#{name}.coffee"
        componentConstructor.isServerOnly = true
    else if fs.existsSync "#{pathTo}/client/#{name}.coffee"
      componentConstructor = isClientOnly: true
    else
      throw new Error "Component '#{name}' not found."

    componentConstructor.pathTo = pathTo

    if not componentConstructor.isServerOnly
      relPath = path.relative srcDir, pathTo
      reqPath = if relPath[0] is '.' then relPath else "./#{relPath}"
      componentsRequires.push "  #{name}: require '#{reqPath}/client/#{name}'"

    componentsConstructors[name] = componentConstructor

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

  sandbox =
    env: env
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
