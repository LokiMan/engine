lerp = require '../../../common/math/lerp'
appendMethod = require '../../../common/appendMethod'

Animate = (raf, now, interval)->
  activeAnimations = []
  lastTime = 0

  intervalTimer = undefined
  requestID = undefined

  wantToStop = [] #[[animation, needFinish]]

  stop = -> # need call finish before removing animation
    wantToStop.push [this, true]

  #$ - need because 'break' is a keyword
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
    currentTime = now()
    lastTime = currentTime

    update currentTime

    if activeAnimations.length != 0
      requestID = raf.request requestUpdate
    else
      intervalTimer.clear()

  animate = (duration, finish, componentName)->
    startTime = now()

    if activeAnimations.length == 0
      lastTime = startTime
      requestID = raf.request requestUpdate

      intervalTimer = interval 1000, ->
        currentTime = now()
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
      duration, startTime, tick, finish, stop, break: break$
      componentName
      then: (resolve)->
        appendMethod this, 'finish', resolve
    }

    activeAnimations.push animateObj

    return animateObj

  animate.fromTo = (
    {duration, from, to, tick: originalTick, finish}, componentName
  )->
    if Array.isArray from
      tick = (t)->
        originalTick (lerp(from[i], e, t) for e, i in to)
    else
      tick = (t)->
        originalTick lerp from, to, t

    animate {duration, tick, finish}, undefined, componentName

  animate.removeBy = (componentName)->
    for anim in activeAnimations
      if anim.componentName is componentName
        anim.break()
    return

  return animate

module.exports = Animate
