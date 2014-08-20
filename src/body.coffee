module.exports = (diContainerName, resolve, typeParser, requiredBy) ->

  ->
    # These requires are used in generated DI container.
    required =
      'goog.asserts': true
      'goog.functions': true
    src = []
    typeParserCache = {}
    typeParserCached = (type) ->
      return typeParserCache[type] if type of typeParserCache
      typeParserCache[type] = typeParser type

    for type in resolve
      do (type, resolving = []) ->
        return if detectCircularDependency type, resolving
        return if detectWrongUsage type, diContainerName, resolving
        return if required[type]
        required[type] = true

        definition = typeParserCached type
        return if !definition

        resolving.push type
        typesToResolve = null

        if definition.invokeAs == 'interface'
          typesToResolve = requiredBy[type].filter (requiredType) ->
            typeParserCached(requiredType).implements.indexOf(type) != -1
          src.push createInterfaceResolver type, diContainerName, typesToResolve
        else
          typesToResolve = (
            arg.type for arg in definition.arguments when arg.type)
          isPrivate = resolving.length > 1
          src.push createTypeResolver type, definition, diContainerName, isPrivate

        for typeToResolve in typesToResolve
          arguments.callee typeToResolve, resolving.slice 0

        return

    required: Object.keys required
    src: src.join '\n\n'

###*
  @param {string} type
  @param {Array.<string>} resolving
  @return {boolean}
###
detectCircularDependency = (type, resolving) ->
  if resolving.indexOf(type) > -1
    dependency = resolving.concat(type).join ' -> '
    throw Error """
      Can't create '#{type}' as it has circular dependency: #{dependency}.
    """
    return true
  false

###*
  @param {string} type
  @param {Array.<string>} diContainerName
  @param {Array.<string>} resolving
  @return {boolean}
###
detectWrongUsage = (type, diContainerName, resolving) ->
  if type == diContainerName
    throw Error """
      Wrong DI container usage detected. Please do not use DI container as
      service locator. The only right place for DI container is
      composition root.

      blog.ploeh.dk/2010/02/03/ServiceLocatorisanAnti-Pattern.
      blog.ploeh.dk/2011/07/28/CompositionRoot
    """
    return true
  false

###*
  @param {string} type
  @param {string} diContainerName
  @param {Array.<string>} types
  @return {string}
###
createInterfaceResolver = (type, diContainerName, types) ->
  removeEmptyLines """
    /**
     * Factory for '#{type}' interface.
     * @return {#{type}}
     * @private
     */
    #{diContainerName}.prototype.resolve#{pascalize type} = function() {
      var rule = this.getRuleFor(#{type});
      #{createInterfaceImplementationSwitch type, types}
    };
  """

###*
  @param {string} type
  @param {Object} definition
  @param {string} diContainerName
  @param {boolean} isPrivate Why private? To prevent using DI container as
    service locator.
  @return {string}
###
createTypeResolver = (type, definition, diContainerName, isPrivate) ->
  args = definition.arguments
  removeEmptyLines """
    /**
     * Factory for '#{type}'.
     * @param {Object=} opt_rule
     * @return {#{type}}
     #{if isPrivate then '* @private' else ''}
     */
    #{diContainerName}.prototype.resolve#{pascalize type} = function(opt_rule) {
      var rule = /** @type {{
        resolve: (Object),
        as: (Object|undefined),
        #{createArgsForRule args}
        by: (Function|undefined)
      }} */ (opt_rule || this.getRuleFor(#{type}));
      #{createArgsDefinition args}
      if (this.resolved#{pascalize type}) return this.resolved#{pascalize type};
      this.resolved#{pascalize type} = /** @type {#{type}} */ (this.createInstance(#{
        type
      }, rule#{if args.length then ', args' else ''}));
      return this.resolved#{pascalize type};
    };
  """

###*
  @param {string} type
  @param {Array.<string>} types
  @return {string}
###
createInterfaceImplementationSwitch = (type, types) ->
  return '' if !types.length
  lines = for type in types
    "case #{type}: return this.resolve#{pascalize type}(rule);"

  """
  switch (rule.as || #{type}) {
      #{lines.join '\n    '}
      default: return null;
    }
  """

###*
  @param {Array} args
  @return {string}
###
createArgsForRule = (args) ->
  return '' if !args.length
  lines = for arg in args
    "#{arg.name}: (#{arg.typeExpression}|undefined)"

  """
  with: ({
        #{lines.join ',\n\n      '}
      }),
  """

###*
  @param {Array.<string>} args
  @return {string}
###
createArgsDefinition = (args) ->
  return '' if !args.length
  lines = args.map (arg) ->
    line = "rule['with'].#{arg.name} !== undefined ? rule['with'].#{arg.name} : "
    if arg.type
      line += "this.resolve#{pascalize arg.type || ''}()"
    else
      line += "void 0"
    line

  """
  var args = [
      #{lines.join ',\n\n    '}
    ];
  """

###*
  @param {string} src
  @return {string}
###
removeEmptyLines = (src) ->
  lines = (line for line in src.split '\n' when line.trim())
  lines.join '\n'

###*
  @param {string} str foo.bla.Bar
  @return {string} FooBlaBar
###
pascalize = (str) ->
  str = camelize str
  str.charAt(0).toUpperCase() + str.slice 1

###*
  @param {string} str foo.bla.Bar
  @return {string} fooBlaBar
###
camelize = (str) ->
  camelized = ''
  str.replace /[^\.]+/g, (m, i) ->
    char = m.charAt 0
    camelized += if i == 0 then char.toLowerCase() else char.toUpperCase()
    camelized += m.slice 1
  camelized
