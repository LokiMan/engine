Submit = (domElement, _, guiElement)->
  guiElement['submit'] = ->
    domElement.submit()

module.exports = Submit
