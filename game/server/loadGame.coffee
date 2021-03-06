coffee = require 'coffeescript'
path = require 'path'
vm = require 'vm'

findComponent = require './findComponent'

loadGame = ({
  srcDir, gameFile, env, fs = require('fs'), load = (->{}), config = {}
})->
  gameComponents = {}
  scenes = {}
  componentsConstructors = {}
  componentsRequires = []
  includes = []
  partName = null

  loadComponentConstructor = (name)->
    return true if componentsConstructors[name]?

    srcDirs = [srcDir].concat(config.externals ? [])
    component = findComponent srcDirs, name, fs.existsSync

    if component?
      {pathToServer, pathToClient} = component
      if pathToServer?
        component.constructor = load pathToServer

      if pathToClient?
        relPath = path.relative srcDir, pathToClient
        reqPath = if relPath[0] is '.' then relPath else "./#{relPath}"
        componentsRequires.push "  #{name}: require '#{reqPath}'"
    else
      return null

    componentsConstructors[name] = component

  loadGameComponents = (componentsInfo)->
    loadComponents componentsInfo, gameComponents

  scene = (id, sceneComponents)->
    sceneID = id

    if scenes[sceneID]?
      throw new Error "Duplicated scene id = #{sceneID}"

    loadComponents sceneComponents, (scenes[sceneID] = {})

  loadComponents = (componentsInfo, whereToStore)->
    for name, value of componentsInfo
      if loadComponentConstructor name
        whereToStore[name] = value
      else if partName? and loadComponentConstructor "#{partName}_#{name}"
        whereToStore["#{partName}_#{name}"] = value
      else
        throw new Error "Component '#{name}' not found."

    return

  loadConfig = (configData)->
    for key, value of configData
      config[key] = value

    if (externals = config.externals)?
      if typeof externals is 'string'
        externals = config.externals = [externals]
      for p, i in externals
        externals[i] = path.join(srcDir + '../', p) + '/'

    return

  sandbox = vm.createContext
    env: env
    config: loadConfig
    components: loadGameComponents
    scene: scene
    part: (p)-> partName = p.replace /\//g, '_'
    include: (pathTo)->
      includes.push pathTo
      storedPartName = partName
      _loadFile srcDir, pathTo, fs, sandbox
      partName = storedPartName

  _loadFile srcDir, gameFile, fs, sandbox

  requiresSource = """
(require 'game/client/index') {
#{componentsRequires.join '\n'}
}
"""

  return {
    gameComponents, scenes, componentsConstructors, requiresSource, includes
  }

_loadFile = (srcDir, gameFile, fs, sandbox)->
  content = fs.readFileSync srcDir + gameFile + '.coffee', encoding: 'utf8'
  coffee.eval content, {sandbox}

module.exports = loadGame
