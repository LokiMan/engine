LocalStorage = (storage = window['localStorage'])->
  isLocalStorageSupported = ->
    return false if not storage?

    testKey = 'test'
    try
      storage.setItem testKey, '1'
      storage.removeItem testKey
      return true
    catch
      return false

  if not isLocalStorageSupported()
    storage = do ->
      items = {}
      {
        setItem: (key, value) ->
          items[key] = value
        getItem: (key) ->
          items[key]
        removeItem: (key) ->
          delete items[key]
      }

  get = (key)->
    str = storage.getItem key

    try
      return JSON.parse str
    catch
      return str

  set = (key, value)->
    storage.setItem key, JSON.stringify value

  remove = (key)->
    storage.removeItem key

  {get, set, remove}

module.exports = LocalStorage
