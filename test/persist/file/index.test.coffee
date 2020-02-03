spy = require '../../../common/test_helpers/spy'

describe 'FilePersist', ->
  FilePersist = require '../../../persist/file'

  it 'should create changes.json if it is not exists', ->
    fs =
      writeFileSync: spy()
      readFileSync: (-> '{}')
      existsSync: (-> false)
      createWriteStream: (->)

    FilePersist './data', fs

    expect(fs.writeFileSync.calls[0]).to.eql ['data/changes.json', '']

  it 'should apply changes if they exists', ->
    fs =
      writeFileSync: spy()
      readFileSync: (p)->
        if p is 'data/data.json' then '{}' else '[0,["set",["a"],{}]]\n'
      existsSync: (-> true)
      createWriteStream: (->)

    FilePersist './data', fs

    expect(fs.writeFileSync.calls).to.eql [
      ['data/data.json', JSON.stringify({a: {}}, null, '\t')]
    ]

  it 'should create backup for files in production', ->
    checkBackup 'production'

  checkBackup = (envName)->
    renameSync = spy()
    backupName = '12-33-33'

    fs =
      writeFileSync: (->)
      renameSync: renameSync
      readFileSync: (-> '{}')
      existsSync: (-> false)
      createWriteStream: (->)

    p = env: NODE_ENV: envName

    FilePersist './', fs, {nowDate: -> toISOString: -> backupName}, p

    expect(renameSync.calls).to.eql [
      ['data.json', "#{backupName}_data.json"]
      ['changes.json', "#{backupName}_changes.json"]
    ]

  it 'should create backup for files in test', ->
    checkBackup 'test'

  it 'should create backup before writing changes', ->
    calls = []

    fs =
      writeFileSync: -> calls.push 'writeFileSync'
      renameSync: -> calls.push 'renameSync'
      readFileSync: (p)->
        if p is 'data/data.json' then '{}' else '[0,["set",["a"],{}]]\n'
      existsSync: (-> true)
      createWriteStream: (->)

    FilePersist './data', fs, {nowDate: -> toISOString: -> ''},
      env: NODE_ENV: 'test'

    expect(calls).to.eql ['renameSync', 'renameSync', 'writeFileSync']

  it 'should write files before creating backup and after', ->
    calls = []

    fs =
      writeFileSync: (p)-> calls.push "writeFileSync/#{p}"
      renameSync: -> calls.push 'renameSync'
      readFileSync: -> '{}'
      existsSync: (-> false)
      createWriteStream: (->)

    FilePersist './data', fs, {nowDate: -> toISOString: -> ''},
      env: NODE_ENV: 'test'

    expect(calls).to.eql [
      'writeFileSync/data/changes.json', 'renameSync', 'renameSync'
      'writeFileSync/data/data.json'
    ]
