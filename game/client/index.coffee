PackFor = require '../../rpc/lib/packFor'
Rpc = require '../../rpc/client'
LocalStorage = require '../../common/localStorage'
Ajax = require '../../common/ajax'
dates = require '../../common/dates'
Timers = require '../../common/timers'
rand = require '../../common/rand'

GameContainer = require './gameContainer'
SceneContainer = require './sceneContainer'
Raf = require './animate/raf'
Animate = require './animate/animate'
EngineFactory = require './engineParts'
UpdateScene = require './updateScene'
initComponents = require './initComponents'

Game = (componentsConstructors)->
  scene = {}
  gameComponents = {}

  perf = window.performance
  if perf? and (perfNow = (perf.now or perf.webkitNow))?
    now = perfNow.bind perf
  else
    now = dates.now

  timers = Timers window

  gameContainerGui = gui.GuiElement document.body.firstElementChild
  gui.gameContainer = GameContainer gameContainerGui, gui.isStandalone, timers

  sceneContainer = SceneContainer scene, gameComponents
  gui.sceneContainer = sceneContainer

  _game = null

  localStorage = LocalStorage()
  ajax = Ajax()

  send = Rpc gui, ajax, timers, rand, (target, action, args)->
    f = scene[target]?[action] ? gameComponents[target]?[action] ? _game[action]
    f? args...

  raf = Raf now, timers.wait
  animate = Animate raf, now, timers.interval

  Engine = EngineFactory gameComponents, scene, gui, animate, send, PackFor, {
    dates
    timers
    ajax
    localStorage
    rand
  }

  init = ([componentsInfo, sceneInfo])->
    initComponents gui, componentsConstructors, gameComponents, componentsInfo,
      Engine, console

    updateScene = UpdateScene gui, componentsConstructors, scene,
      sceneContainer, animate, Engine, console

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
