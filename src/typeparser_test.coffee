typeParser = require './typeparser'

suite 'typeParser', ->

  typesPaths = null
  sources = null
  readFileSync = null

  setup ->
    typesPaths =
      'app.A': 'app/a.js'
      'B': 'app/b.js'
    sources =
      'app/a.js': """
        /**
         * @param {B} b
         * @param {B} b
         * @constructor
         */
        app.A = function(
      """

      'app/b.js': """
        /**
         * @constructor
         */
        var B = function(
      """
    readFileSync = (file) ->
      sources[file]

  parse = (type, resolving) ->
    typeParser(typesPaths, readFileSync) type, resolving

  arrangeType = (type, src) ->
    typesPaths[type] = type
    sources[type] = src

  test 'should parse app.A', ->
    parsed = parse 'app.A'
    assert.deepEqual parsed,
      arguments: [
        name: 'b'
        typeExpression: 'B'
        type: 'B'
      ,
        name: 'b'
        typeExpression: 'B'
        type: 'B'
      ]
      invokeAs: 'class'
      implements: []

  test 'should parse B', ->
    parsed = parse 'B'
    assert.deepEqual parsed,
      arguments: []
      invokeAs: 'class'
      implements: []
  #
  test 'should handle missing file', ->
    readFileSync = (file) -> throw Error 'anything wrong'
    assert.throw ->
      parsed = parse 'app.A'
    , "File 'app/a.js' failed to load."


  test 'should handle missing type definition in source', ->
    readFileSync = (file) -> """
      /**
       * @param {B} b
       * @param {B} b
       * @constructor
       */
      fok.A = function(
    """
    assert.throw ->
      parsed = parse 'app.A'
    , "Type 'app.A' definition not found in file: 'app/a.js'."

  test 'should handle esprima parser error', ->
    readFileSync = (file) -> """
      !
      app.A = function(
    """
    assert.throw ->
      parsed = parse 'app.A'
    , """
      Esprima failed to parse type 'app.A'.
      Line 2: Unexpected end of input
    """

  test 'should handle missing any annotation in source', ->
    readFileSync = (file) -> """
      app.A = function(
    """
    assert.throw ->
      parsed = parse 'app.A'
    , "Type 'app.A' annotation not found in file: 'app/a.js'."

  test 'should handle missing type annotation in source', ->
    readFileSync = (file) -> """
      /**
       * @type {string}
       */
      var a;
      app.A = function(
    """
    assert.throw ->
      parsed = parse 'app.A'
    , "Type 'app.A' annotation not found in file: 'app/a.js'."

  test 'should ignore optional types', ->
    arrangeType 'app.C', """
      /**
       * @param {Foo=} foo
       * @constructor
       */
      app.C = function(
    """
    parsed = parse 'app.C'
    assert.deepEqual parsed,
      arguments: []
      invokeAs: 'class'
      implements: []

  test 'should handle NonNullableType types', ->
    typesPaths['Foo'] = true
    arrangeType 'app.D', """
      /**
       * @param {!Foo} foo
       * @constructor
       */
      app.D = function(
    """
    parsed = parse 'app.D'
    assert.deepEqual parsed,
      arguments: [
        name: 'foo'
        typeExpression: '!Foo'
        type: 'Foo'
      ]
      invokeAs: 'class'
      implements: []

  test 'should ignore not yet resolvable', ->
    arrangeType 'Foo', """
      /**
       * @param {Array.<Element>} elements
       * @param {*} bla
       * @param {?} c
       * @param {function():number} d
       * @constructor
       */
      Foo = function(
    """
    parsed = parse 'Foo'
    assert.deepEqual parsed,
      arguments: [
        name: 'elements'
        typeExpression: 'Array.<Element>'
        type: null
      ,
        name: 'bla'
        typeExpression: '*'
        type: null
      ,
        name: 'c'
        typeExpression: '?'
        type: null
      ,
        name: 'd'
        typeExpression: 'function():number'
        type: null
      ]
      invokeAs: 'class'
      implements: []

  test 'should ignore resolvable but not provided', ->
    arrangeType 'Foo', """
      /**
       * @param {Element} element
       * @constructor
       */
      Foo = function(
    """
    parsed = parse 'Foo'
    assert.deepEqual parsed,
      arguments: [
        name: 'element'
        typeExpression: 'Element'
        type: null
      ]
      invokeAs: 'class'
      implements: []

  suite 'invoke', ->
    test 'should detect class', ->
      arrangeType 'Class', """
        /**
         * @constructor
         */
        Class = function(
      """
      parsed = parse 'Class'
      assert.deepEqual parsed,
        arguments: []
        invokeAs: 'class'
        implements: []

    test 'should detect function', ->
      arrangeType 'createFoo', """
        /**
         * @type {Function}
         */
        createFoo = function(
      """
      parsed = parse 'createFoo'
      assert.deepEqual parsed,
        arguments: []
        invokeAs: 'function'
        implements: []

    test 'should detect function type', ->
      arrangeType 'createFoo', """
        /**
         * @type {function()}
         */
        createFoo = function(
      """
      parsed = parse 'createFoo'
      assert.deepEqual parsed,
        arguments: []
        invokeAs: 'function'
        implements: []

    test 'should return value if not resolved', ->
      arrangeType 'createFoo', """
        /**
         * Constants for event names.
         * @enum {string}
         */
        createFoo = {

      """
      parsed = parse 'createFoo'
      assert.deepEqual parsed,
        arguments: []
        invokeAs: 'value'
        implements: []

  suite 'interface', ->
    test 'should be invoked as interface', ->
      arrangeType 'Interface', """
        /**
         * @interface
         */
        Interface = function(

      """
      parsed = parse 'Interface'
      assert.deepEqual parsed,
        arguments: []
        invokeAs: 'interface'
        implements: []

  suite 'implements', ->
    test 'should be invoked as interface', ->
      arrangeType 'Implements', """
        /**
         * @constructor
         * @implements {A}
         * @implements {B}
         */
        Implements = function(

      """
      parsed = parse 'Implements'
      assert.deepEqual parsed,
        arguments: []
        invokeAs: 'class'
        implements: ['A', 'B']
