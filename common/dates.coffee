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

  parseDuration: (text)->
    regExp = /(\d+) (\w{2}|\w)\w*/g
    result = 0
    while (match = regExp.exec text)?
      result += match[1] * multipliers[match[2]]

    if result is 0 or isNaN result
      throw new Error "On parse duration text: #{text}"

    return result

multipliers = {}
multipliers.ms = 1
multipliers.s = 1000
multipliers.se = 1000
multipliers.m = 60 * multipliers.s
multipliers.mi = multipliers.m
multipliers.h = 60 * multipliers.m
multipliers.ho = multipliers.h
multipliers.d = 24 * multipliers.h
multipliers.da = multipliers.d
multipliers.w = 7 * multipliers.d
multipliers.we = multipliers.w

module.exports = dates
