Time = (_, {common: {dates}})->
  toClient = ->
    now = dates.nowDate()
    now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds()

  getTime = ->
    now = dates.nowDate()
    return {h: now.getHours(), m: now.getMinutes()}

  {toClient, getTime}

module.exports = Time
