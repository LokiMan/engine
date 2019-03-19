pathToRegexp = (route, keys = [])->
  route = route.replace /:(\w+)(\?)?/g, (found, name, questionMark)->
    if questionMark == '?'
      keys.push {name, optional: true}
      return '?(\\w+)?'
    else
      keys.push {name}
      return '(\\w+)'

  return ///^#{route}\/?$///i

module.exports = pathToRegexp