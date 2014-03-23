index = require './index'

suite 'index', ->

  createIntro = null
  createBody = null
  createOutro = null

  setup ->
    createIntro = -> 'intro'
    createBody = ->
      required: ['app.A', 'app.B']
      src: 'body'
    createOutro = -> 'outro'

  runGenerator = ->
    index(createIntro, createBody, createOutro)()

  test 'should call intro with params', (done) ->
    createIntro = (p_required) ->
      assert.deepEqual p_required, ['app.A', 'app.B']
      done()
    runGenerator()

  test 'should generate code', ->
    assert.equal runGenerator().code, 'intro\n\nbody\n\noutro'

  test 'should generate code', ->
    assert.deepEqual runGenerator().required, ['app.A', 'app.B']