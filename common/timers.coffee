dates = require './dates'

w = if (typeof window isnt 'undefined' and window.document?)
  window
else
  global

perf = w.performance
if perf and (perfNow = (perf.now or perf.webkitNow))?
  now = perfNow.bind perf
else
  now = dates.now

Timers =
  now: now

  wait: (ms, func)->
    timer = w.setTimeout func, ms

    clear = ->
      w.clearTimeout timer
      timer = null

    reStart = ->
      if timer?
        clear()

      timer = w.setTimeout func, ms

    return {clear, reStart}

  interval: (ms, func)->
    timer = w.setInterval func, ms

    clear = ->
      w.clearInterval timer
      timer = null

    reStart = ->
      if timer?
        clear()

      timer = w.setInterval func, ms

    return {clear, reStart}

module.exports = Timers
