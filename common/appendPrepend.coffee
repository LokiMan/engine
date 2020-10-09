@append = (object, funcName, appendedFunc)->
  storedFunc = object[funcName]
  if storedFunc?
    object[funcName] = (args...)->
      args.push storedFunc.apply this, args
      appendedFunc.apply this, args

    return storedFunc
  else
    object[funcName] = appendedFunc

@appendAsync = (object, funcName, appendedFunc)->
  storedFunc = object[funcName]
  if storedFunc?
    object[funcName] = (args...)->
      args.push await storedFunc.apply this, args
      appendedFunc.apply this, args

    return storedFunc
  else
    object[funcName] = appendedFunc

@prepend = (object, funcName, prependedFunc)->
  storedFunc = object[funcName]
  if storedFunc?
    object[funcName] = (args...)->
      prependedFunc.apply this, args
      storedFunc.apply this, args

    return storedFunc
  else
    object[funcName] = prependedFunc

@prependAsync = (object, funcName, prependedFunc)->
  storedFunc = object[funcName]
  if storedFunc?
    object[funcName] = (args...)->
      await prependedFunc.apply this, args
      storedFunc.apply this, args

    return storedFunc
  else
    object[funcName] = prependedFunc
