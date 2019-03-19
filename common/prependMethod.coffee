module.exports = (object, funcName, prependedFunc)->
  storedFunc = object[funcName]
  object[funcName] = (args...)->
    prependedFunc.apply this, args
    storedFunc?.apply this, args

  return storedFunc
