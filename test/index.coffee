assert = require('chai').assert
readFileSync = require('fs').readFileSync

index = require '../lib'

depsPath = 'bower_components/closure-library/closure/goog/deps.js'

describe 'index', ->
  it 'should generate DI container src', ->
    depsSrc = readFileSync depsPath, encoding: 'utf8'

    src = index depsSrc,
      name: 'app.DiContainer'
      resolve: ['goog.storage.Storage']
      baseJsDir: 'bower_components/closure-library/closure/goog'

    expected = readFileSync 'test/expected/dicontainer.js', encoding: 'utf8'
    assert.equal src, expected
