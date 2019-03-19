RepositoryFactory = require './repository'

Storage = (
  rootData, onChange = (->)
  cloneDeep = (require '../common/cloneDeep')
  Observer = (require './observer')
)->
  getRef = (path)->
    obj = rootData
    for k in path
      obj = obj[k]
    return obj

  createObserved = (path, initial)->
    if initial? and not has path
      set path, initial
    Observer (getRef path), onChange, path

  get = (path)->
    cloneDeep getRef path

  set = (path, value)->
    copyValue = cloneDeep value

    _onPath path, (obj, key)->
      if obj[key] isnt copyValue
        obj[key] = copyValue
        onChange 'set', path, copyValue

    return copyValue

  has = (path)->
    return getRef(path)?

  update = (path, object)->
    copyObject = cloneDeep object

    obj = rootData
    for k in path
      obj = obj[k]

    for name, value of copyObject
      obj[name] = cloneDeep value

    onChange 'update', path, copyObject

    return

  del = (path)->
    _onPath path, (obj, key)->
      delete obj[key]

    onChange 'del', path

  inc = (path, value = 1)->
    copyValue = +value

    result = _onPath path, (obj, key)->
      obj[key] += copyValue

    onChange 'inc', path, copyValue

    return result

  dec = (path, value = 1)->
    copyValue = +value

    result = _onPath path, (obj, key)->
      obj[key] -= copyValue

    onChange 'dec', path, copyValue

    return result

  push = (path, value)->
    copyValue = cloneDeep value

    result = _onPath path, (obj, key)->
      obj[key].push copyValue

    onChange 'push', path, copyValue

    return result

  pop = (path)->
    result = _onPath path, (obj, key)->
      obj[key].pop()

    onChange 'pop', path

    return result

  splice = (path, index, count)->
    result = _onPath path, (obj, key)->
      obj[key].splice index, count

    onChange 'splice', path, index, count

    return result

  unshift = (path, value)->
    copyValue = cloneDeep value

    result = _onPath path, (obj, key)->
      obj[key].unshift copyValue

    onChange 'unshift', path, copyValue

    return result

  shift = (path)->
    result = _onPath path, (obj, key)->
      obj[key].shift()

    onChange 'shift', path

    return result

  _onPath = (path, cb)->
    obj = rootData
    length = path.length
    key = path[length - 1]
    for i in [0 ... (length - 1)]
      obj = obj[path[i]]
    cb obj, key

  storage = {
    getRef, createObserved
    get, set, has, update, del, inc, dec, push, pop, splice, unshift, shift
  }

  storage.Repository = RepositoryFactory storage, onChange, Observer

  storage

module.exports = Storage
