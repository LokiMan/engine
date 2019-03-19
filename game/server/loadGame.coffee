coffee = require 'coffeescript'

loadGame = ({
  dir, file, readFile = require('fs').readFileSync
  gameComponents = {}
  scenes = {}
  prefix = ''
  includes = []
})->
  content = readFile dir + file + '.coffee', encoding: 'utf8'

  loadGameComponents = (componentsInfo)->
    for name, value of componentsInfo
      gameComponents[name] = value
    return

  scene = (id, components)->
    sceneID = if prefix is '' then id else prefix + '/' + id

    if scenes[sceneID]?
      throw new Error "Duplicated scene id = #{sceneID}"

    scenes[sceneID] = components

#    scenes[sceneID] = {
#      components
#      dir
#    }

  sandbox =
    components: loadGameComponents
    scene: scene
    include: (name)->
      includes.push name + '/index'

      loadGame {
        dir: dir + name + '/', file: 'index', readFile
        gameComponents, scenes
        prefix: if prefix is '' then name else prefix + '/' + name
        includes
      }

  coffee.eval content, {sandbox}

  return {gameComponents, scenes, includes}

module.exports = loadGame
