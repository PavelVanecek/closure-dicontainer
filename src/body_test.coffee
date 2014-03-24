body = require './body'

suite 'body', ->

  diContainerName = null
  resolve = null
  types = null
  typeParser = null
  requiredBy = null
  factory = null
  resolved = null

  setup ->
    diContainerName = 'app.DiContainer'
    resolve = ['app.A']
    types =
      'app.A':
        arguments: [
          name: 'b'
          typeExpression: 'B'
          type: 'B'
        ,
          name: 'bb'
          typeExpression: 'B'
          type: 'B'
        ,
          name: 'c'
          typeExpression: 'Array.<string>'
          type: null
        ,
          name: 'd'
          typeExpression: 'Element'
          type: 'Element'
        ,
          name: 'e'
          typeExpression: 'Document'
          type: null
        ,
          name: 'f'
          typeExpression: 'F'
          type: 'F'
        ]
        invokeAs: 'class'
      'B':
        arguments: []
        invokeAs: 'class'
      'Element':
        arguments: []
        invokeAs: 'class'
      'create':
        arguments: []
        invokeAs: 'function'
      'enum':
        arguments: []
        invokeAs: 'value'
      'F':
        arguments: []
        invokeAs: 'interface'
      'G':
        arguments: []
        invokeAs: 'class'
        implements: ['F']

    typeParser = (type) ->
      types[type]

    requiredBy =
      'F': ['G']

    factory = null
    resolved = null

  resolveFactory = ->
    factory = body diContainerName, resolve, typeParser, requiredBy
    resolved = factory()

  test 'should resolve dependencies', ->
    resolveFactory()
    assert.equal resolved.src, """
      /**
       * Factory for 'app.A'.
       * @param {Object=} opt_rule
       * @return {app.A}
       */
      app.DiContainer.prototype.resolveAppA = function(opt_rule) {
        var rule = /** @type {{
          resolve: (Object),
          as: (Object|undefined),
          with: ({
            b: (B|undefined),
            bb: (B|undefined),
            c: (Array.<string>|undefined),
            d: (Element|undefined),
            e: (Document|undefined),
            f: (F|undefined)
          }),
          by: (Function|undefined)
        }} */ (opt_rule || this.getRuleFor(app.A));
        var args = [
          rule['with'].b !== undefined ? rule['with'].b : this.resolveB(),
          rule['with'].bb !== undefined ? rule['with'].bb : this.resolveB(),
          rule['with'].c !== undefined ? rule['with'].c : void 0,
          rule['with'].d !== undefined ? rule['with'].d : this.resolveElement(),
          rule['with'].e !== undefined ? rule['with'].e : void 0,
          rule['with'].f !== undefined ? rule['with'].f : this.resolveF()
        ];
        if (this.resolvedAppA) return this.resolvedAppA;
        this.resolvedAppA = /** @type {app.A} */ (this.createInstance(app.A, rule, args));
        return this.resolvedAppA;
      };

      /**
       * Factory for 'B'.
       * @param {Object=} opt_rule
       * @return {B}
       * @private
       */
      app.DiContainer.prototype.resolveB = function(opt_rule) {
        var rule = /** @type {{
          resolve: (Object),
          as: (Object|undefined),
          by: (Function|undefined)
        }} */ (opt_rule || this.getRuleFor(B));
        if (this.resolvedB) return this.resolvedB;
        this.resolvedB = /** @type {B} */ (this.createInstance(B, rule));
        return this.resolvedB;
      };

      /**
       * Factory for 'Element'.
       * @param {Object=} opt_rule
       * @return {Element}
       * @private
       */
      app.DiContainer.prototype.resolveElement = function(opt_rule) {
        var rule = /** @type {{
          resolve: (Object),
          as: (Object|undefined),
          by: (Function|undefined)
        }} */ (opt_rule || this.getRuleFor(Element));
        if (this.resolvedElement) return this.resolvedElement;
        this.resolvedElement = /** @type {Element} */ (this.createInstance(Element, rule));
        return this.resolvedElement;
      };

      /**
       * Factory for 'F' interface.
       * @return {F}
       * @private
       */
      app.DiContainer.prototype.resolveF = function() {
        var rule = this.getRuleFor(F);
        switch (rule.as || G) {
          case G: return this.resolveG(rule);
          default: return null;
        }
      };

      /**
       * Factory for 'G'.
       * @param {Object=} opt_rule
       * @return {G}
       * @private
       */
      app.DiContainer.prototype.resolveG = function(opt_rule) {
        var rule = /** @type {{
          resolve: (Object),
          as: (Object|undefined),
          by: (Function|undefined)
        }} */ (opt_rule || this.getRuleFor(G));
        if (this.resolvedG) return this.resolvedG;
        this.resolvedG = /** @type {G} */ (this.createInstance(G, rule));
        return this.resolvedG;
      };
    """

  test 'should create required', ->
    resolveFactory()
    assert.deepEqual resolved.required, [
      'goog.asserts'
      'goog.functions'
      'app.A'
      'B'
      'Element'
      'F'
      'G'
    ]

  test 'should create unique required', ->
    types =
      'app.A':
        arguments: [
          name: 'b'
          type: 'B'
        ,
          name: 'b'
          type: 'B'
        ]
      'B':
        arguments: []
    resolveFactory()
    assert.deepEqual resolved.required, [
      'goog.asserts', 'goog.functions', 'app.A', 'B'
    ]

  test 'should do not generate code for missing type definition', ->
    resolve = ['app.iAmNotExists']
    resolveFactory()
    assert.equal resolved.src, ""

  test 'should detect circular dependency', ->
    types =
      'app.A':
        arguments: [
          name: 'b'
          type: 'B'
        ]
      'B':
        arguments: [
          name: 'a'
          type: 'app.A'
        ]

    assert.throw resolveFactory, """
      Can't create 'app.A' as it has circular dependency: app.A -> B -> app.A.
    """

  test 'should detect wrong usage', ->
    types =
      'app.A':
        arguments: [
          name: 'diContainer'
          type: 'app.DiContainer'
        ]
      'app.DiContainer':
        arguments: []

    assert.throw resolveFactory, """
      Wrong DI container usage detected. Please do not use DI container as
      service locator. The only right place for DI container is
      composition root.

      blog.ploeh.dk/2010/02/03/ServiceLocatorisanAnti-Pattern.
      blog.ploeh.dk/2011/07/28/CompositionRoot
    """
