getXmlHttp = ->
  xmlhttp = undefined
  try
    xmlhttp = new XMLHttpRequest()
  catch
    try
      axo = ['Active'].concat('Object').join('X')
      xmlhttp = new window[axo]? 'Microsoft.XMLHTTP'
    catch
      xmlhttp = false

  return xmlhttp

_encodeComponents = (data) ->
  result = []
  for k of data
    if data.hasOwnProperty(k)
      result.push k + '=' + encodeURIComponent data[k]
  return result.join '&'

request = (method, url, data = null, success = null, error = null)->
  req = getXmlHttp()
  return if not req

  req.onreadystatechange = ->
    if req.readyState is 4
      if req.status is 200
        success? req.responseText
      else
        error? req.status, req.responseText

  if typeof data is 'function'
    error = success
    success = data
    data = null

  if data? and typeof data isnt 'string'
    data = _encodeComponents data

  if method is 'GET' and data?
    url += '?' + data
    data = null

  req.open method, url, true

  if method isnt 'GET'
    req.setRequestHeader 'X-Requested-With', 'XMLHttpRequest'
    req.setRequestHeader 'Content-type', 'application/x-www-form-urlencoded'

  req.send data

  return {
    abort: ->
      req.onreadystatechange = null
      req.abort()
  }

_gen = (method)->
  (url, data, success, error)->
    request method, url, data, success, error

get = _gen 'GET'

ajax = get

ajax.get = get
ajax.post = _gen 'POST'
ajax.put = _gen 'PUT'
ajax.del = _gen 'DELETE'
ajax.head = _gen 'HEAD'

module.exports = ajax
