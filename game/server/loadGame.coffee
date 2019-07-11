coffee = require 'coffeescript'
path = require 'path'

loadGame = (
  {srcDir, gameFile, components = {}, fs = require('fs'), load = (->{})}
)->
  gameComponents = {}
  scenes = {}
  componentsConstructors = {}

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
    components: loadGameComponents
    scene: scene

  coffee.eval content, {sandbox}

  return {gameComponents, scenes, componentsConstructors}

module.exports = loadGame
