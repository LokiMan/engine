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
gui.gameContainer = GameContainer gameContainerGuiElement

sceneContainer = SceneContainer scene, gameComponents
gui.sceneContainer = sceneContainer

animate = Animate()
gui.animate = animate

Game = (scenesComponentsConstructors, gameComponentsConstructors)->
  remote = Remote Connection(), ({target, action, args})->
    (scene[target] ? gameComponents[target])?[action]? args...

  initGame = ([componentsInfo, sceneInfo])->
    initComponents gameComponentsConstructors, gameComponents,
      remote, componentsInfo, scene, gui

    updateScene = UpdateScene scenesComponentsConstructors, scene, remote,
      sceneContainer, gameComponents, animate, gui

    updateScene sceneInfo

    scene.__world = {updateScene}

    document.onkeydown = (e)->
      for [name] in componentsInfo by -1
        component = gameComponents[name]
        if component.onKeyDown?(e) is true
          break

      for name, component of scene when name isnt '__world'
        component.onKeyDown? e
      return

  scene.__world = {initGame}

module.exports = Game
