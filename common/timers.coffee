Timers = (w)->
  wait = (ms, func)->
    timer = w.setTimeout func, ms

    clear = ->
      w.clearTimeout timer
      timer = null

    reStart = (newMS = ms)->
      if timer?
        clear()

      timer = w.setTimeout func, newMS

    return {clear, reStart}

  interval = (ms, func)->
    timer = w.setInterval func, ms

    clear = ->
      w.clearInterval timer
      timer = null

    reStart = (newMS = ms)->
      if timer?
        clear()

      timer = w.setInterval func, newMS

    return {clear, reStart}

  {wait, interval}

module.exports = Timers
