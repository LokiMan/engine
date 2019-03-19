Style = (styleExtenders)-> (element, styles, guiElement)->
  {style} = element

  guiElement.style ?= {}

  for k, v of styles
    guiElement.style[k] = v

    if (extender = styleExtenders[k])?
      extender style, v, element, guiElement
    else
      style[k] = v

  return

module.exports = Style
