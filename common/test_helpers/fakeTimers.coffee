FakeTimers = ->
  time = 0
  timers = []

  wait = (ms, func)->
    _newTimer {ms, func}

  interval = (ms, func)->
    _newTimer {ms, func, interval: ms}

  _newTimer = (timer)->
    timer.ms += time
    timers.push timer
    return {
      clear: ->
        timers.splice (timers.indexOf timer), 1
      reStart: (newMS = timer.ms)->
        @clear()
        timers.push {
          ms: newMS + time, func: timer.func, interval: timer.interval
        }
    }

  tick = (ms)->
    for [1..ms]
      tickMs()

  tickByStep = (ms, step)->
    count = Math.floor(ms / step)
    for [1..count]
      tickMs step

  tickMs = (value = 1)->
    time += value

    i = 0
    len = timers.length
    while i < len
      timer = timers[i]

      if timer.ms <= time
        timer.func()

        if timer.interval?
          timer.ms += timer.interval
        else
          timers.splice i, 1
          i--
          len--

      i++

  now = ->
    time

  return {
    wait
    interval
    tick
    tickByStep
    now
  }

module.exports = FakeTimers