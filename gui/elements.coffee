mergeDeep = require '../common/mergeDeep'

Elements = (create)->
  span: (props, next)->
    create 'span', props, next

  p: (props, next)->
    create 'p', props, next

  div: (props, next)->
    create 'div', props, next

  ul: (props, next)->
    create 'ul', props, next

  li: (props, next)->
    create 'li', props, next

  img: (props)->
    if props.src?
      props.src = '/res/img/' + props.src

    create 'img', props

  a: (props)->
    create 'a', props

  link: (props)->
    create 'span', mergeDeep {
      style: {
        textDecoration: 'underline'
        cursor: 'pointer'
      }
    }, props

  textBox: (props)->
    originOnKeyDown = props.onkeydown

    props.onkeydown = (e)->
      originOnKeyDown? e
      e.stopPropagation?()

    create 'input', mergeDeep {
      type: 'text'
      value: ''
    }, props

  radio: (props)->
    create 'input', mergeDeep {
      type: 'radio'
    }, props

  label: (props, next)->
    create 'label', props, next

  hidden: (props)->
    create 'input', mergeDeep {
      type: 'hidden'
    }, props

  button: (props)->
    create 'button', props

  form: (props, next)->
    if not next? and typeof props is 'function'
      next = props
      props = {}

    create 'form', mergeDeep({method: 'POST', submit: true}, props), next

  submit: (props)->
    create 'input', mergeDeep {
      type: 'submit'
    }, props

  iframe: (props, next)->
    create 'iframe', props, next

  select: (props, next)->
    create 'select', props, next

  option: (props)->
    create 'option', props

  center: (props, next)->
    create 'center', props, next

  br: ->
    create 'br'

  nbsp: ->
    create._textNode '\u00A0'

  textNode: (text)->
    create._textNode text

  textArea: (props)->
    create 'textarea', mergeDeep {
      value: ''
    }, props

  hr: (props)->
    create 'hr', props

  table: (props, next)->
    create 'table', props, next

  tr: create?._tr
  td: create?._td

  shadowText: (props, shadowColor = 'black')->
    create 'span', mergeDeep {
      style: {
        fontWeight: 'bold'
        color: 'white'
        fontFamily: '"Trebuchet MS"'
        fontSize: '15px'
        textShadow: "
1px 0px #{shadowColor}, 1px 1px #{shadowColor}, 0px 1px #{shadowColor},
-1px 1px #{shadowColor}, -1px 0px #{shadowColor}, -1px -1px #{shadowColor},
 0px -1px #{shadowColor}, 1px -1px #{shadowColor}"
      }
    }, props

module.exports = Elements
