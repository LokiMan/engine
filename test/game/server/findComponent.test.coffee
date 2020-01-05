spy = require '../../../common/test_helpers/spy'

describe 'Find Component', ->
  findComponent = require '../../../game/server/findComponent'

  it 'should return pathToServer for found component', ->
    result = findComponent ['/'], 'name', -> true

    expect(result.pathToServer).to.equal '/name/server/name'
  
  it 'should try to find both coffee and js files', ->
    existsSync = spy -> false

    findComponent ['/'], 'name', existsSync

    expect(existsSync.calls).to.eql [
      [ '/name/server/name.coffee' ], [ '/name/server/name.js' ]
      [ '/name/client/name.coffee' ], [ '/name/client/name.js' ]
    ]

  it 'should try to find in all of paths', ->
    existsSync = spy -> false

    findComponent ['src/', '../'], 'name', existsSync

    expect(existsSync.calls).to.eql [
      [ 'src/name/server/name.coffee' ], [ 'src/name/server/name.js' ]
      [ 'src/name/client/name.coffee' ], [ 'src/name/client/name.js' ]
      [ '../name/server/name.coffee' ], [ '../name/server/name.js' ]
      [ '../name/client/name.coffee' ], [ '../name/client/name.js' ]
    ]

  it 'should return isServerOnly if no clients file', ->
    existsSync = (path)-> return not path.includes 'client'

    result = findComponent ['/'], 'name', existsSync

    expect(result).to.eql isServerOnly: true, pathToServer: '/name/server/name'

  it 'should return isClientOnly if only client file', ->
    existsSync = (path)-> return not path.includes 'server'

    result = findComponent ['/'], 'name', existsSync

    expect(result).to.eql isClientOnly: true, pathToClient: '/name/client/name'

  it "should try to find nested component if '_' exists in path", ->
    existsSync = spy (p)-> p is '/nested/moreNested/client/component.js'

    findComponent ['/'], 'nested_moreNested_component', existsSync

    expect(existsSync.calls).to.eql [
      [ '/nested/moreNested/component/server/component.coffee' ]
      [ '/nested/moreNested/component/server/component.js' ]
      [ '/nested/moreNested/component/client/component.coffee' ]
      [ '/nested/moreNested/component/client/component.js' ]

      [ '/nested/moreNested/server/component.coffee' ]
      [ '/nested/moreNested/server/component.js' ]
      [ '/nested/moreNested/client/component.coffee' ]
      [ '/nested/moreNested/client/component.js' ]
    ]

  it 'should return pathToServer for nested component', ->
    existsSync = (path)->
      return path.includes '/nested/moreNested/component/server'

    result = findComponent ['/'], 'nested_moreNested_component', existsSync

    expect(result).to.eql {
      isServerOnly: true
      pathToServer: '/nested/moreNested/component/server/component'
    }

  it "should not considered as nested if '_' is first symbol", ->
    existsSync = (path)->
      return path.includes '/_notNested/server'

    result = findComponent ['/'], '_notNested', existsSync

    expect(result).to.eql {
      isServerOnly: true
      pathToServer: '/_notNested/server/_notNested'
    }
