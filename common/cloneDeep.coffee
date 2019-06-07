cloneDeep = (obj, options = {})->
  if not obj? or typeof obj isnt 'object'
    return obj

  if obj instanceof Date
    return new Date obj.getTime()

  if obj instanceof RegExp
    flags = ''
    flags += 'g' if obj.global
    flags += 'i' if obj.ignoreCase
    flags += 'm' if obj.multiline
    flags += 'y' if obj.sticky
    return new RegExp obj.source, flags

  newInstance = new (obj.constructor ? Object)()

  for key, value of obj
    if typeof value isnt 'function' or options.functions
      newInstance[key] = cloneDeep value, options

  return newInstance

module.exports = cloneDeep
