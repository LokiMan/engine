UIPanes = ({div, span, br, link}, interval)->
  modalPane = (next)->
    div style:
      zIndex: 150
      position: 'fixed'
      left: 0
      top: 0
      width: '100%'
      height: '100%'
      backgroundColor: 'rgba(0, 0, 0, 0.5)'
    , ->
      div
        style:
          position: 'relative'
          width: '202px'
          top: '50%'
          padding: '20px'
          margin: '0 auto'
          backgroundColor: 'white'
          color: 'black'
          transform: 'translateY(-50%)'
      , next

  reconnect: ->
    modalPane ->
      span text: 'Соединение с сервером'

      text = ''
      dotsSpan = span {text}

      interval 500, ->
        text += '.'
        if text is '....'
          text = ''
        dotsSpan.update {text}

  disconnect: (onReload)->
    modalPane (parent)->
      parent.update
        pos: width: 270
        style: textAlign: 'center'

      span text: 'Соединение с сервером потеряно'
      br()
      br()
      link text: 'Обновить', click: onReload

module.exports = UIPanes
