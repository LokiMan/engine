const Title = function(text, {gui}) {
  const {center, div} = gui

  let titleDiv = null

  return center(function() {
    return titleDiv = div({
      html: text
    })
  })
}

module.exports = Title
