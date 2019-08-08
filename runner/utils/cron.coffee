later = require 'later'

later.date.localTime()

Cron = ->
  intervals = []

  cron = (text, callback)->
    intervals.push later.setInterval callback, later.parse.text text

  cron.clear = ->
    for interval in intervals
      interval.clear()
    intervals.length = 0

  return cron

module.exports = Cron
