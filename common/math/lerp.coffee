lerp = (start, finish, t)->
  (start - finish) * t + finish

module.exports = lerp