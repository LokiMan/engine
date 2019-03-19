spy = require '../../../common/test_helpers/spy'

describe 'PlayerFactory', ->
  PlayerFactory = require '../../../game/server/playerFactory'

  createPlayerFactory = ({components = {}, goTo = {onPlayer: ->}} = {})->
    PlayerFactory components, goTo

  it 'should return the same player on second get', ->
    playerFactory = createPlayerFactory()

    player1 = playerFactory.getByUID 'uid'
    player2 = playerFactory.getByUID 'uid'

    expect(player1).to.equal player2

  it 'should set player.id to uid', ->
    playerFactory = createPlayerFactory()
    uid = 'uid'

    player = playerFactory.getByUID uid

    expect(player.id).to.equal uid

  it 'should apply components onPlayer', ->
    components = {
      component1: onPlayer: spy()
      component2: onPlayer: spy()
    }
    playerFactory = createPlayerFactory {components}

    player = playerFactory.getByUID 'uid'

    expect(components.component1.onPlayer.calls).to.eql [[player]]
    expect(components.component2.onPlayer.calls).to.eql [[player]]

  it 'should call goTo.onPlayer with player', ->
    goTo = onPlayer: spy()
    playerFactory = createPlayerFactory {goTo}

    player = playerFactory.getByUID 'uid'

    expect(goTo.onPlayer.calls).to.eql [[player]]
