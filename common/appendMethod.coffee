module.exports = (object, funcName, appendedFunc)->
  storedFunc = object[funcName]
  object[funcName] = (args...)->
    args.push storedFunc?.apply this, args
    appendedFunc.apply this, args

  return storedFunc
