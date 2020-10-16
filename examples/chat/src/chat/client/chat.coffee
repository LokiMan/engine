# Путь к папке engine/ автоматически добавляется к глобальному поиску модулей
pad = require 'common/pad'

# компонент 'time' используется для получения на клиенте серверного времени
Chat = (_, {gui, remote, time})->
  {div, textBox} = gui

  messagesDiv = div
    pos: top: 30, height: 500, width: '100%'
    style: backgroundColor: 'lightgray'

  chatInput = textBox
    pos: top: 536, width: '100%'
    onkeydown: (e)->
      message = chatInput.value.trim()
      if (e.keyCode is 13) and (message.length != 0)
        remote 'message', message
        chatInput.value = ''

  chatInput.focus()

  out = (msg)->
    {h, m} = time.getTime()
    timeStr = pad(h) + ':' + pad(m)

    messagesDiv.append ->
      div html: "#{timeStr} &raquo; #{msg}"

  {out}

module.exports = Chat
