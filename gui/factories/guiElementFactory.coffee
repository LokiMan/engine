GuiElementFactory = (extenders, currentDomElement)->
  GuiElement = (domElement)->
    update: (props)->
      for key, value of props
        if (extender = extenders[key])?
          extender domElement, value, this
        else
          domElement[key] = value
      return

    clear: ->
      while (firstChild = domElement.firstChild)?
        domElement.removeChild firstChild
      return

    append: (what)->
      if typeof what is 'function'
        savedElement = currentDomElement
        currentDomElement = domElement
        appendedElement = what this
        currentDomElement = savedElement
        return appendedElement
      else if what.appendChild?
        what.appendChild domElement
      else
        what.append domElement
        return what

    remove: ->
      domElement.parentNode.removeChild domElement

  GuiElement._appendToCurrent = (domElement)->
    currentDomElement.appendChild domElement

  GuiElement._insertRow = ->
    currentDomElement.insertRow()

  GuiElement._insertCell = ->
    currentDomElement.insertCell()

  return GuiElement

module.exports = GuiElementFactory
