RepositoryFactory = (storage, onChange, Observer)-> (collection, Class)->
  if not storage.has [collection]
    storage.set [collection], {}

  cache = {}

  get = (uid)->
    if (object = cache[uid])?
      return object

    data = storage.getRef [collection, uid]

    if data?
      cache[uid] = _create uid, data
    else
      return null

  has = (uid)->
    cache[uid]? or storage.has [collection, uid]

  _create = (uid, data)->
    observableData = Observer data, onChange, [collection, uid]

    object = Class observableData, uid

    object.toClient = ->
      return data

    return object

  add = (uid, data)->
    cache[uid] = _create uid, (storage.set [collection, uid], data)

  remove = (uid)->
    storage.del [collection, uid]
    delete cache[uid]

  {get, add, remove, has}

module.exports = RepositoryFactory
