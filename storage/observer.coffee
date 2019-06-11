isChangeArrayFunctions = {
  push: true, pop: true, unshift: true, shift: true, splice: true
}

Observer = (root, onChange, rootPath = [])->
  proxyCache = Object.create(null)

  ProxyObject = (target, path)->
    pathStr = path.join ''

    if not (cache = proxyCache[pathStr])?
      cache = proxyCache[pathStr] = {}
    else if cache.target is target
      return cache.proxy

    handler =
      get: (target, property)->
        if property is 'toJSON'
          return (-> target)

        value = target[property]
        type = typeof value
        if type is 'object' and value isnt null
          return ProxyObject value, path.concat(property)
        else if isArrayFunction type, target, property
          return (args...)->
            result = target[property] args...
            onChange property, path, args...
            return result
        else
          return value

      set: (target, key, value)->
        if value isnt target[key]
          target[key] = value
          onChange 'set', [path..., key], value
        return true

      deleteProperty: (target, key)->
        delete target[key]
        onChange 'del', [path..., key]
        return true

    proxy = new Proxy target, handler

    cache.proxy = proxy
    cache.target = target

    return proxy

  return ProxyObject root, rootPath

isArrayFunction = (type, target, property) ->
  type is 'function' and Array.isArray(target) and
    isChangeArrayFunctions.hasOwnProperty(property)

module.exports = Observer