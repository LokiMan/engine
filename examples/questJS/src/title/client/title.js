const Title = (text, {gui: {center, div}}) =>
  center(() => div({
    html: text
  }))

module.exports = Title
