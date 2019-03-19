cloneDeep = require './cloneDeep'

mergeDeep = (target, sources...)->
  if typeof target is 'object'
    result = cloneDeep target, functions: yes
  else
    result = {}

  for source in sources
    for key, value of source
      if Array.isArray value
        result[key] = [value...]
      else if typeof value is 'object'
        result[key] = mergeDeep (result[key] ? {}), value
      else
        result[key] = value

  return result

module.exports = mergeDeep
