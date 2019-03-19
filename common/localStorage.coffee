isLocalStorageSupported = (storage)->
  testKey = 'test'
  try
    storage.setItem testKey, '1'
    storage.removeItem testKey
    return true
  catch
    return false

storage = window['localStorage']

if not storage? or not isLocalStorageSupported storage
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

LocalStorage =
  get: (key)->
    str = storage.getItem key

    if typeof str != 'string'
      return undefined

    try
      return JSON.parse str
    catch
      return str ? undefined

  set: (key, value)->
    storage.setItem key, JSON.stringify value

  remove: (key)->
    storage.removeItem key

module.exports = LocalStorage
