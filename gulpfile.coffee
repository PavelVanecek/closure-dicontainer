gulp = require 'gulp'

chai = require 'chai'
clean = require 'gulp-clean'
coffee = require 'gulp-coffee'
eventStream = require 'event-stream'
gutil = require 'gulp-util'
mocha = require 'gulp-mocha'
plumber = require 'gulp-plumber'

global.assert = chai.assert

paths =
  clean: [
    './lib'
    './test/*.js'
  ]
  scripts:
    lib: 'src/*.coffee'
    test: 'test/*.coffee'
  test:
    tdd: 'lib/*_test.js'
    bdd: 'test/*.js'

gulp.task 'clean', ->
  gulp.src paths.clean, read: false
    .pipe clean()

gulp.task 'scripts', ->
  streams = for dest, src of paths.scripts
    gulp.src src
      .pipe plumber()
      .pipe coffee bare: true
      .on 'error', (err) -> gutil.log err.message
      .pipe gulp.dest dest
  eventStream.merge streams...

gulp.task 'test', ['scripts'], ->
  streams = for type, src of paths.test
    gulp.src src
      .pipe mocha ui: type
      .on 'error', (e) ->
        gutil.log e.message
        # Ensure watch isn't stopped on error.
        @emit 'end'
  eventStream.merge streams...

gulp.task 'build', ['test']

gulp.task 'run', ->
  src = (src for dest, src of paths.scripts)
  gulp.watch src, ['build']

gulp.task 'default', ['clean'], ->
  gulp.start 'build', 'run'