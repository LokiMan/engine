RepositoryFactory = (storage, onChange, Observer)-> (collection, Class)->
  if not storage.has [collection]
    storage.set [collection], {}

  cache = {}

  get = (key)->
    if (object = cache[key])?
      return object

    data = storage.getRef [collection, key]

    if data?
      cache[key] = _create key, data
    else
      return null

  has = (key)->
    cache[key]? or storage.has [collection, key]

  _create = (key, data)->
    observableData = Observer data, onChange, [collection, key]

    object = Class observableData, key

    object.getRawData = ->
      return data

    return object

  add = (key, data)->
    cache[key] = _create key, (storage.set [collection, key], data)

  remove = (key)->
    storage.del [collection, key]
    delete cache[key]

  {get, add, remove, has}

module.exports = RepositoryFactory
