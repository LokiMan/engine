Time = (serverTime, {common: {dates}})->
  st = Math.round(dates.nowDate().getTime() / 1000 - 0.5)

  getTime = ->
    time = Math.round(dates.nowDate().getTime() / 1000 - 0.5)
    tt = serverTime + time - st
    h = +Math.round(( tt / 3600 ) % 24 - 0.5)
    m = +Math.round(( tt / 60 ) % 60 - 0.5)
    s = +(tt % 60)

    return {h, m, s}

  {getTime}

# Этот компонент не нужно добавлять в рендеринг страницы
Time.skipContainer = true

module.exports = Time
