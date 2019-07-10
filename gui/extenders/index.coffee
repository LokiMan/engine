MouseClick = require './click/mouse'
TouchClick = require './click/touch'

MouseDraggableFactory = require './draggable/mouse'
TouchDraggable = require './draggable/touch'

userSelect = require './style/userSelect'

styleExtenders =
  gray: require './style/gray'
  transform: require './style/transform'
  userSelect: userSelect
  backgroundImage: require './style/backgroundImage'

module.exports = (isTouch, document)->
  MouseDraggable = MouseDraggableFactory document, userSelect

  extenders =
    pos: require './pos'
    style: (require './style') styleExtenders
    click: if isTouch then TouchClick else MouseClick
    rightClick: require './rightClick'
    visible: require './visible'
    text: require './text'
    html: require './html'
    animated: require './animated'
    value: require './value'
    draggable: if isTouch then TouchDraggable else MouseDraggable
    scrollTop: require './scrollTop'
    offsetRect: require './offsetRect'
    smoothVerticalScrolling: require './smoothVerticalScrolling'
    zIndex: require './zIndex'
    insertBefore: require './insertBefore'
    submit: require './_internal/submit'

  if not isTouch
    extenders.mouseOver = require './mouseOver'
    extenders.mouseOut = require './mouseOut'
    extenders.hover = require './hover'

  return extenders
