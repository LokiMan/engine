PlayerFactory = (gameComponents, goTo)->
  onPlayerComponents = []
  for name, component of gameComponents
    if component.onPlayer?
      onPlayerComponents.push {name, component}

  playersCache = Object.create null

  getByUID = (uid)->
    if not (player = playersCache[uid])?
      player = Object.defineProperty {}, 'id', get: -> uid

      playersCache[uid] = player

      goTo.onPlayer player

      for {component} in onPlayerComponents
        component.onPlayer player

    return player

  {getByUID}

module.exports = PlayerFactory
