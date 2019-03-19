# Путь к папке engine/ автоматически добавляется к глобальному поиску модулей
dates = require 'common/dates'

Time = (serverTime, {container})->
  container.remove() #unused div

  st = Math.round(dates.nowDate().getTime() / 1000 - 0.5)

  getTime = ->
    time = Math.round(dates.nowDate().getTime() / 1000 - 0.5)
    tt = serverTime + time - st
    h = +Math.round(( tt / 3600 ) % 24 - 0.5)
    m = +Math.round(( tt / 60 ) % 60 - 0.5)
    s = +(tt % 60)

    return {h, m, s}

  {getTime}

module.exports = Time
