mergeDeep = require '../../common/mergeDeep'
spy = require '../../common/test_helpers/spy'

describe 'Repository', ->
  RepositoryFactory = require '../../storage/repository'

  describe 'Repository', ->
    createRepository = ({
      collection = '', storage = {}, onChange = (->)
      Observer = (->{}), Class = (->{})
    })->
      storage = mergeDeep {has: ->, set: ->}, storage
      Repository = RepositoryFactory storage, onChange, Observer
      Repository collection, Class

    describe 'construct', ->
      it 'should create empty collection if it is not exists', ->
        storage = {set: spy()}

        createRepository {collection: 'data', storage}

        expect(storage.set.calls).to.eql [[['data'], {}]]

    describe 'get', ->
      it 'should return null if no data in storage', ->
        storage = {getRef: -> null}
        repository = createRepository {collection: 'data', storage}

        result = repository.get 'uid1'

        expect(result).to.be.null

      it 'should observe object', ->
        data = {}
        storage = {getRef: -> data}
        Observer = spy()
        onChange = (->)
        repository = createRepository {
          collection: 'data', storage, Observer, onChange
        }

        repository.get 'uid1'

        expect(Observer.calls).to.eql [[data, onChange, ['data', 'uid1']]]

      it 'should construct object with observable data', ->
        observable = {}
        storage = {getRef: -> {}}
        Observer = -> observable
        Class = spy -> {}
        repository = createRepository {
          collection: 'data', storage, Observer, Class
        }

        repository.get 'uid1'

        expect(Class.calls[0][0]).to.equal observable

      it 'should use cache for results', ->
        data = {}
        storage = {getRef: -> data}
        repository = createRepository {
          collection: 'data', storage
        }

        result1 = repository.get 'uid1'
        result2 = repository.get 'uid1'

        expect(result2).to.equal result1

    describe 'add', ->
      it 'should call storage set', ->
        storage = {has: (-> {}), set: spy()}
        repository = createRepository {collection: 'data', storage}

        repository.add 'uid1', {}

        expect(storage.set.calls).to.eql [[['data', 'uid1'], {}]]

      it 'should add toClient that return data', ->
        data = {a: 1, b: [2, 3]}
        storage = {has: (-> {}), set: -> data}
        repository = createRepository {collection: 'data', storage}
        object = repository.add 'uid1', data

        result = object.toClient()

        expect(result).to.equal data

    describe 'remove', ->
      it 'should call storage.del', ->
        storage = {has: (-> {}), del: spy()}
        repository = createRepository {collection: 'data', storage}

        repository.remove 'uid1'

        expect(storage.del.calls).to.eql [[['data', 'uid1']]]

