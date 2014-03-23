# closure-dicontainer
[![Build Status](https://secure.travis-ci.org/steida/closure-dicontainer.png?branch=master)](http://travis-ci.org/steida/closure-dicontainer) [![Dependency Status](https://david-dm.org/steida/closure-dicontainer.png)](https://david-dm.org/steida/closure-dicontainer) [![devDependency Status](https://david-dm.org/steida/closure-dicontainer/dev-status.png)](https://david-dm.org/steida/closure-dicontainer#info=devDependencies)

> Dependency Injection Container for Google Closure Library

- concise api (resolve A as B with C by D)
- automatic types registration
- resolving based on strong types parsed from annotations
- run-time configuration
- advanced mode compilation friendly

## Getting Started
This is standalone Node.js module. For Grunt, use [grunt-closure-dicontainer](http://github.com/steida/grunt-closure-dicontainer). For Gulp, use [gulp-closure-dicontainer](http://github.com/steida/gulp-closure-dicontainer)

```js
var src = diContainer(fs.readFileSync(depsPath, {
  encoding: 'utf8'
}), {
  baseJsDir: 'bower_components/closure-library/closure/goog',
  name: 'app.DiContainer',
  resolve: ['App']
});

fs.writeFileSync('build/dicontainer.js', src);
```

### Options

#### options.name
Type: `String`
Default value: `'app.DiContainer'`

Generated DI container name.

#### options.resolve
Type: `Array.<string>`
Default value: `['App']`

Array of types to be resolved.

#### options.baseJsDir
Type: `String`
Default value: `'bower_components/closure-library/closure/goog'`
Optional

### Usage Example

How to use DI container in your app.

```coffee
###*
  @fileoverview App main method.
###
 
goog.provide 'app.main'
 
goog.require 'app.DiContainer'
 
app.main = ->
  container = new app.DiContainer
  
  container.configure
    resolve: App
    with: element: document.body
  ,
    resolve: este.storage.Storage
    as: este.storage.Local
  ,
    resolve: foo.ui.Lightbox
    by: (lightbox) ->
      lightbox.setSomething()
  ,
    resolve: foo.IFoo
    by: ->
      new foo.Foo
 
  app = container.resolveApp()
  app.start()
 
goog.exportSymbol 'app.main', app.main
```

#### Container Configuration

There is a pattern: **Resolve A as B with C by D**.

A is type to be resolved. B is optional type to be returned. C is optional object for run-time
configuration, where key is argument name and value is runtime value. D is optional factory method.

Available in [Este](http://github.com/steida/este) soon. Stay tuned.

## More About DI
  - [kozmic.net/2012/10/23/ioc-container-solves-a-problem-you-might-not-have-but-its-a-nice-problem-to-have](http://kozmic.net/2012/10/23/ioc-container-solves-a-problem-you-might-not-have-but-its-a-nice-problem-to-have)
  - [ayende.com/blog/2887/dependency-injection-doesnt-cut-it-anymore](http://ayende.com/blog/2887/dependency-injection-doesnt-cut-it-anymore)
  - [ayende.com/blog/4372/rejecting-dependency-injection-inversion](http://ayende.com/blog/4372/rejecting-dependency-injection-inversion)
  - [Dependency Injection in .NET](http://www.manning.com/seemann)
