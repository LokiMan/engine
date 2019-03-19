CreateElementFactory = (GuiElement, document = window.document)->
  createElement = (tag, props, next)->
    if not next? and typeof props is 'function'
      next = props
      props = null

    domElement = document.createElement tag

    guiElement = GuiElement domElement

    if props?
      guiElement.update props

    GuiElement._appendToCurrent domElement

    if next?
      guiElement.append next

    return guiElement

  createElement._textNode = (text)->
    domElement = document.createTextNode text
    GuiElement._appendToCurrent domElement
    return

  createTableElement = (funcName)->
    (props, next)->
      if not next? and typeof props is 'function'
        next = props
        props = null

      domElement = GuiElement[funcName]()

      guiElement = GuiElement domElement

      if props?
        guiElement.update props

      if next?
        guiElement.append next

      return guiElement

  createElement._tr = createTableElement '_insertRow'
  createElement._td = createTableElement '_insertCell'

  return createElement

module.exports = CreateElementFactory
