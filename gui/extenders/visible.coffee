Visible = ({style}, value, guiElement)->
  style.display = if value then '' else 'none'

  guiElement.isVisible = value

module.exports = Visible
