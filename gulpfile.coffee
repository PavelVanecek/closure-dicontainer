gulp = require 'gulp'

chai = require 'chai'
coffee = require 'gulp-coffee'
gulpif = require 'gulp-if'
gutil = require 'gulp-util'
mocha = require 'gulp-mocha'
plumber = require 'gulp-plumber'
runSequence = require 'run-sequence'

global.assert = chai.assert

paths =
  coffee: [
    'src/*.coffee'
    'test/*.coffee'
  ]
  bddTest: 'test/*.js'
  tddTest: 'lib/*.js'

gulp.task 'coffee', ->
  gulp.src paths.coffee
    .pipe plumber()
    .pipe coffee bare: true
    .on 'error', (err) -> gutil.log err.message
    .pipe gulpif /\/src/, gulp.dest 'lib'
    .pipe gulpif /\/test/, gulp.dest 'test'

gulp.task 'bddTest', ->
  gulp.src paths.bddTest
    .pipe mocha ui: 'bdd'
    .on 'error', (e) ->
      gutil.log e.message
      # Ensure watch is running despite error.
      @emit 'end'

gulp.task 'tddTest', ->
  gulp.src paths.tddTest
    .pipe mocha ui: 'tdd'
    .on 'error', (e) ->
      gutil.log e.message
      # Ensure watch is running despite error.
      @emit 'end'

gulp.task 'test', (callback) ->
  runSequence 'bddTest', 'tddTest', callback

gulp.task 'build', (callback) ->
  runSequence 'coffee', 'test', callback

gulp.task 'watch', ->
  gulp.watch paths.coffee, ['build']

gulp.task 'default', (callback) ->
  runSequence 'build', 'watch', callback
