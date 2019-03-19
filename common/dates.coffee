dates =
  now: ->
    Date.now()

  nowDate: ->
    new Date()

  fromValue: (value)->
    new Date value

  fromString: (string)->
    new Date string

  create: (year, month, date, hours, minutes, seconds, milliseconds)->
    new Date year, month, date, hours, minutes, seconds, milliseconds

module.exports = dates
