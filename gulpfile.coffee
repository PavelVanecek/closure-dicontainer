gulp = require 'gulp'

coffee = require 'gulp-coffee'
gulpif = require 'gulp-if'
gutil = require 'gulp-util'
mocha = require 'gulp-mocha'
plumber = require 'gulp-plumber'

paths =
  coffee: [
    './src/**/*.coffee'
    './test/**/*.coffee'
  ]
  bddTest: [
    'test/*.js'
  ]

gulp.task 'coffee', ->
  gulp.src paths.coffee
    .pipe plumber()
    .pipe coffee bare: true
    .on 'error', (err) -> gutil.log err.message
    .pipe gulpif /\/src/, gulp.dest 'lib'
    .pipe gulpif /\/test/, gulp.dest 'test'

gulp.task 'test', ['coffee'], ->
  gulp.src paths.bddTest
    .pipe mocha ui: 'bdd'
    .on 'error', (e) ->
      gutil.log e.message
      # Ensure watch is running despite error.
      @emit 'end'

gulp.task 'watch', ->
  gulp.watch paths.coffee, ['test']

gulp.task 'default', ['test', 'watch']
