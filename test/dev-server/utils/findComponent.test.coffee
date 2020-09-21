findComponent = require '../../../dev-server/utils/findComponent'

describe 'findComponent', ->
  it 'should search component by components constructors', ->
    pathParts = 'battles/battle/mechanics/deck/server/deck'.split '/'
    componentsConstructors = battles__buttons: {}, battles_battle: {}

    result = findComponent pathParts, componentsConstructors

    expect(result).to.equal 'battles/battle'

  it 'should correct work with double __', ->
    pathParts = 'battles/_buttons/server/_buttons'.split '/'
    componentsConstructors = battles__buttons: {}, battles_battle: {}

    result = findComponent pathParts, componentsConstructors

    expect(result).to.equal 'battles/_buttons'

  it 'should return null if cannot found component', ->
    pathParts = 'battles/component/server/component'.split '/'
    componentsConstructors = {}

    result = findComponent pathParts, componentsConstructors

    expect(result).to.be.null

  it 'should find mostly deeper nested component', ->
    pathParts = 'battles/mechanics/damage/server/damage'.split '/'
    componentsConstructors = battles: {}, battles_mechanics: {}

    result = findComponent pathParts, componentsConstructors

    expect(result).to.equal 'battles/mechanics'
