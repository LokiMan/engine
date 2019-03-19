Value = (domElement, value, guiElement)->
  domElement.value = value

  Object.defineProperty guiElement, 'value',
    get: ->
      domElement.value

    set: (v)->
      domElement.value = v

  guiElement.focus = ->
    domElement.focus()

module.exports = Value
