Ajax = (w = window)->
  getXmlHttp = ->
    xmlHttp = undefined
    try
      xmlHttp = new w.XMLHttpRequest()
    catch
      try
        axo = ['Active'].concat('Object').join('X')
        xmlHttp = new w[axo]? 'Microsoft.XMLHTTP'
      catch
        xmlHttp = false

    return xmlHttp

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

    if method in ['POST', 'PUT']
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

  return ajax

module.exports = Ajax
