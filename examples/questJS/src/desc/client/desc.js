const Desc = function(text, {gui}) {
  const {div} = gui

  return div({
    html: text,
    style: {
      margin: '20px 0'
    }
  })
}

module.exports = Desc
