deepFreeze = (object)->
  propNames = Object.getOwnPropertyNames object

  for name in propNames
    value = object[name]

    if value? and typeof value is 'object'
      object[name] = deepFreeze value

  Object.freeze object

module.exports = deepFreeze
