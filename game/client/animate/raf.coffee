Raf = (
  w = window
  timers = require '../../../common/timers'
)->
  rAF = w.requestAnimationFrame
  cAF = w.cancelAnimationFrame
  for vendor in ['ms', 'moz', 'webkit', 'o'] when not rAF
    rAF = w["#{vendor}RequestAnimationFrame"]
    cAF = w["#{vendor}CancelAnimationFrame"] ?
      w["#{vendor}CancelRequestAnimationFrame"]

  if rAF?
    raf = {
      request: (callback)->
        rAF callback

      cancel: (id)->
        cAF id
    }
  else
    targetTime = 0
    raf = {
      request: (callback)->
        targetTime = Math.max targetTime + 16, currentTime = timers.now()
        timers.wait targetTime - currentTime, callback

      cancel: (timer)->
        timer.clear()
    }

  return raf

module.exports = Raf
