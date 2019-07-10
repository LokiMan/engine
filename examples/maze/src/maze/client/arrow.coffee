Arrow = (remote)-> ([x, y], name)->
  img
    src: "arrow_#{name}.png"
    pos: [x, y, 128, 128]
    visible: true
    style:
      opacity: '0.6'
      cursor: 'pointer'
    click: ->
      remote name

module.exports = Arrow
