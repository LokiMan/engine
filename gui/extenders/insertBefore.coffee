insertBefore = (domElement, element2)->
  if element2.insertBefore?
    domElement.parentNode.insertBefore element2, domElement
  else
    element2.update insertBefore: domElement

module.exports = insertBefore
