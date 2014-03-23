assert = require('chai').assert
readFileSync = require('fs').readFileSync

index = require '../lib'

depsPath = 'bower_components/closure-library/closure/goog/deps.js'

describe 'index', ->
  it 'should generate DI container src', ->
    depsSrc = readFileSync depsPath, encoding: 'utf8'

    writeFileSync = (path, src) ->
      assert.equal path, depsPath
      src = src.replace depsSrc, ''
      assert.equal src, "goog.addDependency('../bower_components/closure-library/closure/goog/deps.js', ['app.DiContainer'], ['goog.asserts', 'goog.functions', 'goog.storage.Storage', 'goog.storage.mechanism.Mechanism'])\n"

    expected = readFileSync 'test/expected/dicontainer.js', encoding: 'utf8'
    src = index depsPath,
      name: 'app.DiContainer'
      resolve: ['goog.storage.Storage']
      depsPrefix: '../'
    , writeFileSync

    assert.equal expected, src
