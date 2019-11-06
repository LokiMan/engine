lerp = require '../../../common/math/lerp'

TICK_MS_IN_PAUSE = 50

Animate = (
  timers = require '../../../common/timers'
  raf = (require './raf') window, timers
)->
  activeAnimations = []
  lastTime = 0

  intervalTimer = undefined
  requestID = undefined

  wantToStop = [] #[[animation, needFinish]]

  stop = -> # need call finish before removing animation
    wantToStop.push [this, true]

  #$ - need because break is keyword
  break$ = -> # not need call finish before removing animation
    wantToStop.push [this, false]

  update = (currentTime)->
    if wantToStop.length > 0
      for [animation, needFinish] in wantToStop
        if needFinish
          animation.finish?()
        activeAnimations.splice (activeAnimations.indexOf animation), 1
      wantToStop.length = 0

    cnt = activeAnimations.length
    i = 0

    while i < cnt
      animation = activeAnimations[i]
      leftTime = animation.duration - (currentTime - animation.startTime)
      if leftTime <= 0
        animation.tick? 0
        animation.finish?()

        activeAnimations.splice i, 1
        --cnt
      else
        animation.tick? leftTime / animation.duration

        ++i

    null

  requestUpdate = ->
    currentTime = timers.now()
    lastTime = currentTime

    update currentTime

    if activeAnimations.length != 0
      requestID = raf.request requestUpdate
    else
      intervalTimer.clear()

  animate = (duration, finish)->
    now = timers.now()

    if activeAnimations.length == 0
      lastTime = now
      requestID = raf.request requestUpdate

      intervalTimer = timers.interval 1000, ->
        currentTime = timers.now()
        elapsedTime = currentTime - lastTime
        if elapsedTime > 500
          update currentTime

          if activeAnimations.length == 0
            intervalTimer.clear()
            raf.cancel requestID

    if typeof duration is 'object'
      {duration, tick, finish} = duration
    else
      tick = ->

    animateObj = {
      duration, startTime: now, tick, finish, stop, break: break$
    }

    activeAnimations.push animateObj

    return animateObj

  animate.fromTo = ({duration, from, to, tick: originalTick, finish})->
    if Array.isArray from
      tick = (t)->
        originalTick (lerp(from[i], e, t) for e, i in to)
    else
      tick = (t)->
        originalTick lerp from, to, t

    animate {duration, tick, finish}

  animate.clearAll = ->
    activeAnimations.length = 0
    intervalTimer?.clear()
    if requestID?
      raf.cancel requestID

  return animate

module.exports = Animate
