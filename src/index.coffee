body = require './body'
create = require './create'
intro = require './intro'
outro = require './outro'
path = require 'path'
typeParser = require './typeparser'

###
  @param {string} depsSrc deps.js source.
  @param {Object=} options Configuration.
  @return {string} Container source.
###
module.exports = (depsSrc, options = {}) ->

  # DI container class name. Remember to require in app.main.
  # Example: goog.require('app.DiContainer');
  options.name ?= 'app.DiContainer'

  # Types to be resolved with autogenerated factory.
  # Example: new app.DiContainer().resolveApp();
  options.resolve ?= ['App']

  # To load all files
  options.baseJsDir ?= ''

  # Key is type, value is file path.
  typesPaths = null

  # Key is type, value is array of types requiring it.
  requiredBy = null

  [typesPaths, requiredBy] = parseDeps options.name, depsSrc, options.baseJsDir

  typeParser = typeParser typesPaths
  intro = intro options.name
  body = body options.name, options.resolve, typeParser, requiredBy
  outro = outro options.name
  container = create(intro, body, outro)()

  container.code

parseDeps = (diContainerName, depsSrc, baseJsDir) ->
  typesPaths = {}
  requiredBy = {}
  goog = addDependency: (filePath, namespaces, requires) ->
    namespaces = namespaces.filter (namespace) ->
      namespace != diContainerName
    for namespace in namespaces
      typesPaths[namespace] = path.join baseJsDir, filePath
    for require_ in requires
      requiredBy[require_] = (requiredBy[require_] || []).concat namespaces
    return
  eval depsSrc
  [typesPaths, requiredBy]
