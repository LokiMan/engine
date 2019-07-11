coffee = require 'coffeescript'

loadGame = ({
  srcDir, gameFile, readFile = require('fs').readFileSync
})->
  gameComponents = {}
  scenes = {}

  content = readFile srcDir + gameFile + '.coffee', encoding: 'utf8'

  loadGameComponents = (componentsInfo)->
    for name, value of componentsInfo
      gameComponents[name] = value
    return

  scene = (id, components)->
    sceneID = id

    if scenes[sceneID]?
      throw new Error "Duplicated scene id = #{sceneID}"

    scenes[sceneID] = components

  sandbox =
    components: loadGameComponents
    scene: scene

  coffee.eval content, {sandbox}

  return {gameComponents, scenes}

module.exports = loadGame
