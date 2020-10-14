RandFromArrayMulti = require './_internal/randFromArrayMulti'

rand = (m, n)->
  Math.floor(Math.random() * (n - m + 1)) + m

rand.chance = (percent = 50)->
  rand(1, 100) <= percent

randFromArrayMulti = RandFromArrayMulti rand

rand.fromArray = (array, count = 1)->
  if count is 1
    return array[rand(0, array.length - 1)]
  else if count <= array.length
    randFromArrayMulti array, count
  else
    throw new Error "Count(#{count}) more than length(#{array.length})"

rand.shuffle = (array)->
  i = array.length
  while --i > 0
    j = ~~(Math.random() * (i + 1)) # ~~ is a common optimization for Math.floor
    t = array[j]
    array[j] = array[i]
    array[i] = t
  array

module.exports = rand
