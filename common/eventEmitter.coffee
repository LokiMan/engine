EventEmitter = (origin = {})->
  listeners = {}

  # _ need because 'on' is a keyword
  _on = (event, fn)->
    if not (listener = listeners[event])?
      listeners[event] = fn
    else
      if typeof listener is 'function'
        listeners[event] = [listener, fn]
      else
        listener.push fn

    return origin

  once = (event, fn)->
    _on event, (args...)->
      removeListener event, fn
      fn args...

  emit = (event, args...)->
    if (list = listeners[event])?
      if typeof list is 'function'
        copyList = list
      else
        copyList = list[..]

      len = args.length

      switch len
        when 0 # fast cases
          emitNone copyList
        when 1
          emitOne copyList, args[0]
        when 2
          emitTwo copyList, args[0], args[1]
        when 3
          emitThree copyList, args[0], args[1], args[2]
        else # slower
          emitMany copyList, args

    return null

  removeListener = (event, fn)->
    if (list = listeners[event])?
      if typeof list is 'function'
        delete listeners[event]
      else
        removeIndex = list.indexOf fn
        spliceOne list, removeIndex
        if list.length is 0
          delete listeners[event]

  origin.on = _on
  origin.once = once
  origin.emit = emit
  origin.removeListener = removeListener
  origin.off = removeListener

  return origin

emitNone = (list)->
  if typeof list is 'function'
    list()
  else
    for callback in list
      callback()
    return

emitOne = (list, arg)->
  if typeof list is 'function'
    list arg
  else
    for callback in list
      callback arg
    return

emitTwo = (list, arg1, arg2)->
  if typeof list is 'function'
    list arg1, arg2
  else
    for callback in list
      callback arg1, arg2
    return

emitThree = (list, arg1, arg2, arg3)->
  if typeof list is 'function'
    list arg1, arg2, arg3
  else
    for callback in list
      callback arg1, arg2, arg3
    return

emitMany = (list, args)->
  if typeof list is 'function'
    list args...
  else
    for callback in list
      callback args...
    return

# About 1.5x faster than the two-arg version of Array#splice(). (from node.js)
spliceOne = (list, index) ->
  i = index
  n = list.length - 1

  while i < n
    list[i] = list[i + 1]
    i += 1

  list.pop()

  return

module.exports = EventEmitter
