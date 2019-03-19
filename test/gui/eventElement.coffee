EventElement = (element = {})->
  events = {}

  element.addEventListener = (name, cb)->
    if not events[name]?
      events[name] = cb
    else if typeof events[name] is 'function'
      events[name] = [events[name], cb]
    else
      events[name].push cb

  element.removeEventListener = (name, cb)->
    return if not events[name]?

    if typeof events[name] is 'function'
      if events[name] is cb
        delete events[name]
    else
      index = events[name].indexOf cb
      if index >= 0
        if events[name].length is 1
          delete events[name]
        else
          events[name].splice index, 1

  return events

module.exports = EventElement
