Extenders = require './extenders'
GuiElementFactory = require './factories/guiElementFactory'
CreateElementFactory = require './factories/createElementFactory'
Elements = require './elements'
IsTouch = require './isTouch'
IsStandalone = require './isStandalone'

isTouch = IsTouch window, document
isStandalone = IsStandalone window

extenders = Extenders isTouch, document

GuiElement = GuiElementFactory extenders, document.body.firstElementChild

createElement = CreateElementFactory GuiElement
module.exports = Elements createElement

module.exports.extenders = extenders
module.exports.GuiElement = GuiElement

module.exports.isTouch = isTouch
module.exports.isStandalone = isStandalone
