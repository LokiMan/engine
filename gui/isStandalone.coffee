module.exports = (w)->
  if 'standalone' of w.navigator
    !!w.navigator.standalone
  else if w.matchMedia?
    w.matchMedia('(display-mode: standalone)').matches
  else
    false
