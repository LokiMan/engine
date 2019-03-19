RandFromArrayMulti = (rand)->
  (array, count)->
    result = new Array count
    found = {}

    for i in [0 ... count]
      loop
        element = rand.fromArray array
        break if not found[element]?

      result[i] = element
      found[element] = true

    return result

module.exports = RandFromArrayMulti
