pairSplitRegExp = /; */

parseCookie = (cookieStr)->
  cookie = {}

  return cookie if not cookieStr

  pairs = cookieStr.split pairSplitRegExp

  for pair in pairs
    eqIndex = pair.indexOf '='
    if eqIndex > 0
      key = pair.substr(0, eqIndex).trim()
      if not cookie[key]?
        val = pair.substr(eqIndex + 1, pair.length).trim()
        cookie[key] = val

  return cookie

module.exports = parseCookie
