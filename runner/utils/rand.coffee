{nanoid} = require 'nanoid/non-secure'

module.exports = (rand)->
  rand.string = nanoid
  rand.uuid = nanoid

  rand.uuidFor = (collection)->
    (length)->
      loop
        str = nanoid length

        # защита, от случайного создания уже существующей записи
        break if not collection[str]?

      return str

  return rand
