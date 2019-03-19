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

chars = 'abcdefghijklmnopqrstuvwxyz0123456789_ABCDEFGHIJKLMNOPQRSTUVWXYZ'
charsMax = chars.length - 1

staticArrays =
  10: new Array 10
  20: new Array 20

rand.string = (length)->
  if not (charArray = staticArrays[length])?
    charArray = staticArrays[length] = new Array length

  for i in [0...length]
    charArray[i] = chars[rand(0, charsMax)]

  str = charArray.join ''

  return str

rand.RandomString = (collection)->
  (length)->
    loop
      str = rand.string length

      #защита, от случайного создания уже существующей записи
      break if not collection[str]?

    return str

module.exports = rand
