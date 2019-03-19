dates = require '../common/dates'
pad = require '../common/pad'

Logger = ->
  savedStacks = {}

  exception = (err)->
    stack = err['stack'] ? err.toString()
    hash = stack.substr(0, 128) + stack.length
    unless savedStacks[hash]
      savedStacks[hash] = stack
      console.error '%s» %s', _time(), stack
    return

  info = (args...)->
    console.info _time() + '»', args...

  error = (args...)->
    console.error _time() + '»', args...

  {exception, info, error}

_time = ->
  d = dates.nowDate()
  date = "#{pad(d.getFullYear())}/#{pad(d.getDate())}/#{pad(d.getMonth() + 1)}"
  time = "#{pad(d.getHours())}:#{pad(d.getMinutes())}:#{pad(d.getSeconds())}"

  return "#{date}, #{time}"

module.exports = Logger
