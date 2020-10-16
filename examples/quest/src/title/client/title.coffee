Title = (text, {gui})->
  {center, div} = gui

  titleDiv = null

  center ->
    titleDiv = div html: text

module.exports = Title
