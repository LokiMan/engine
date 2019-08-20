GameContainer = require './gameContainer'
SceneContainer = require './sceneContainer'
Animate = require './animate'

Connection = require '../../rpc/client/connection'
Remote = require '../../rpc/lib/remote'
UpdateScene = require './updateScene'
initComponents = require './initComponents'

scene = {}
gameComponents = {}

gameContainerGuiElement = gui.GuiElement document.body.firstElementChild
gui.gameContainer = GameContainer gameContainerGuiElement, gui.isStandalone

sceneContainer = SceneContainer scene, gameComponents
gui.sceneContainer = sceneContainer

animate = Animate()
gui.animate = animate

Game = (componentsConstructors)->
  _game = null

  remote = Remote Connection(), ({target, action, args})->
    f = scene[target]?[action] ? gameComponents[target]?[action] ? _game[action]
    f? args...

  init = ([componentsInfo, sceneInfo])->
    initComponents componentsConstructors, gameComponents,
      remote, componentsInfo, scene, gui

    updateScene = UpdateScene componentsConstructors, scene, remote,
      sceneContainer, gameComponents, animate, gui

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
