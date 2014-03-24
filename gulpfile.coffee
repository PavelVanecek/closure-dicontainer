gulp = require 'gulp'

chai = require 'chai'
clean = require 'gulp-clean'
coffee = require 'gulp-coffee'
gulpif = require 'gulp-if'
gutil = require 'gulp-util'
mocha = require 'gulp-mocha'
plumber = require 'gulp-plumber'

global.assert = chai.assert

paths =
  clean: [
    'src/*.js'
    'test/*.js'
  ]
  coffee: [
    'src/*.coffee'
    'test/*.coffee'
  ]
  bddTest: 'test/*.js'
  tddTest: 'lib/*.js'

gulp.task 'clean', ->
  gulp.src paths.clean
    .pipe clean()

gulp.task 'coffee', ['clean'], ->
  gulp.src paths.coffee
    .pipe plumber()
    .pipe coffee bare: true
    .on 'error', (err) -> gutil.log err.message
    .pipe gulpif /\/src/, gulp.dest 'lib'
    .pipe gulpif /\/test/, gulp.dest 'test'

gulp.task 'test', ['bddTest', 'tddTest']

gulp.task 'bddTest', ['coffee'], ->
  gulp.src paths.bddTest
    .pipe mocha ui: 'bdd'
    .on 'error', (e) ->
      gutil.log e.message
      # Ensure watch is running despite error.
      @emit 'end'

gulp.task 'tddTest', ['coffee'], ->
  gulp.src paths.tddTest
    .pipe mocha ui: 'tdd'
    .on 'error', (e) ->
      gutil.log e.message
      # Ensure watch is running despite error.
      @emit 'end'

gulp.task 'build', ['test']

gulp.task 'watch', ->
  gulp.watch paths.coffee, ['build']

gulp.task 'default', ['build', 'watch']
