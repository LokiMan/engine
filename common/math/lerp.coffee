# from 0 to 1, where 0 - it's start and 1 - it's finish
lerp = (start, finish, t)->
  (finish - start) * t + start

lerp.arrays = (from, to, t)->
  from.map (f, i) -> lerp f, to[i], t

module.exports = lerp
