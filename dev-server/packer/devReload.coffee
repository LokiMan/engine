focused = true
needReload = false

reload = ->
  window.location.reload()

window.onfocus = ->
  focused = true
  if needReload
    reload()

window.onblur = ->
  focused = false

port = if window.location.port then ':' + window.location.port else ''
socket = new WebSocket('ws://' + window.location.hostname + port + '/dev?#path')

socket.onmessage = (event) ->
  msg = event.data
  if msg == 'reload'
    if focused
      reload()
    else
      needReload = true
      if document.title[0] != '*'
        document.title = '* ' + document.title
  else if msg.startsWith 'Ошибка'
    document.body.innerHTML = '<pre><font color="red">' + (msg.replace /\n/g, '<br/>') + '</font></pre>'
