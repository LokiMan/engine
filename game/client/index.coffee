GameContainer = require './gameContainer'
SceneContainer = require './sceneContainer'
Animate = require './animate'

PackFor = require '../../rpc/lib/packFor'
Rpc = require '../../rpc/client'
EngineFactory = require './engineParts'
UpdateScene = require './updateScene'
initComponents = require './initComponents'

scene = {}
gameComponents = {}

gameContainerGuiElement = gui.GuiElement document.body.firstElementChild
gui.gameContainer = GameContainer gameContainerGuiElement, gui.isStandalone

sceneContainer = SceneContainer scene, gameComponents
gui.sceneContainer = sceneContainer

Game = (componentsConstructors)->
  _game = null

  send = Rpc gui, (target, action, args)->
    f = scene[target]?[action] ? gameComponents[target]?[action] ? _game[action]
    f? args...

  animate = Animate()
  Engine = EngineFactory gameComponents, scene, gui, animate, send, PackFor

  init = ([componentsInfo, sceneInfo])->
    initComponents componentsConstructors, gameComponents, componentsInfo,
      Engine

    updateScene = UpdateScene componentsConstructors, scene, sceneContainer,
      animate, Engine

    updateScene sceneInfo

    _game = {updateScene, reSync: -> window.location.reload()}

    document.onkeydown = (e)->
      for [name] in componentsInfo by -1
        component = gameComponents[name]
        if component.onKeyDown?(e) is true
          break

      for name, component of scene
        component.onKeyDown? e
      return

  _game = {init}

module.exports = Game
