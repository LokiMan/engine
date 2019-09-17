pathToRegexp = (route, keys = [])->
  route = route.replace /:(\w+)(\?|\*)?/g, (found, name, flag)->
    if flag is '?'
      keys.push {name, optional: true}
      return '?(\\w+)?'
    else if flag is '*'
      keys.push {name, optional: true}
      return '(\.*)'
    else
      keys.push {name}
      return '(\\w+)'

  return ///^#{route}\/?$///i

module.exports = pathToRegexp