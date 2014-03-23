module.exports = (grunt) ->

  grunt.initConfig

    clean:
      options:
        force: true
      all:
        src: [
          'bower_components/este-library/este/**/*.{js,css}'
          '{lib,tasks}/**/*.js'
          'test/*.js'
          'tmp'
        ]

    coffee:
      options:
        bare: true
      all:
        files: [
          expand: true
          src: [
            '{lib,tasks,test}/**/*.coffee'
             'bower_components/este-library/este/**/*.coffee'
          ]
          ext: '.js'
        ]

    coffee2closure:
      all:
        files: '<%= coffee.all.files %>'

    esteDeps:
      all:
        options:
          outputFile: 'client/deps.js'
          prefix: '../../../../'
          root: [
            'bower_components/closure-library'
            'bower_components/este-library/este'
          ]

    esteUnitTests:
      all:
        src: '{lib,tasks}/**/*_test.js'

    # Configuration to be run (and then tested).
    closure_dicontainer:
      default_options:
        files:
          'tmp/default_options_dicontainer.js': 'test/fixtures/deps.js'

    nodeunit:
      tests: [
        'test/*_test.js'
      ]

    esteWatch:
      options:
        livereload: enabled: false
        dirs: [
          '{lib,tasks,test}/**/'
        ]

      coffee: (filepath) ->
        files = [src: filepath, ext: '.js', expand: true]
        grunt.config ['coffee', 'all', 'files'], files
        grunt.config ['coffee2closure', 'all', 'files'], files
        ['coffee:all']

      js: (filepath) ->
        grunt.config ['esteDeps', 'all', 'src'], filepath
        grunt.config ['esteUnitTests', 'all', 'src'], filepath
        # NOTE: Nodeunit can't be retested without restart.
        ['esteUnitTests']

    bump:
      options:
        commitFiles: ['-a']
        files: ['bower.json', 'package.json']
        pushTo: 'origin'
        tagName: '%VERSION%'

  grunt.loadNpmTasks 'grunt-bump'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-nodeunit'
  grunt.loadNpmTasks 'grunt-este'
  grunt.loadNpmTasks 'grunt-este-watch'
  grunt.loadTasks 'tasks'

  grunt.registerTask 'default', ['build', 'run']
  grunt.registerTask 'build', [
    'clean'
    'coffee'
    'coffee2closure'
    'esteDeps'
    'esteUnitTests'
    'closure_dicontainer'
    'nodeunit'
  ]
  grunt.registerTask 'run', ['esteWatch']