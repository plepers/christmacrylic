# Generated on 2013-11-21 using generator-webapp 0.4.3
"use strict"

# # Globbing
# for performance reasons we're only matching one level down:
# 'test/spec/{,*/}*.js'
# use this if you want to recursively match all subfolders:
# 'test/spec/**/*.js'
module.exports = (grunt) ->

  # show elapsed time at the end
  require("time-grunt") grunt

  # load all grunt tasks
  require("load-grunt-tasks") grunt


  grunt.initConfig

  # configurable paths
    yeoman:
      app: "app"
      tmp: ".tmp"
      dist: "dist"
      libs: "libs"
      subs: "subs"

    watch:

      coffee:
        files: ["<%= yeoman.app %>/scripts/{,**/}*.coffee"]
        tasks: ["coffee:dist"]
        options:
          spawn: false

      coffeeTest:
        files: ["test/spec/{,*/}*.coffee"]
        tasks: ["coffee:test"]

      compass:
        files: ["<%= yeoman.app %>/styles/{,*/}*.{scss,sass}"]
        tasks: ["compass:server", "autoprefixer"]

      styles:
        files: ["<%= yeoman.app %>/styles/{,*/}*.css"]
        tasks: ["copy:styles", "autoprefixer"]

      livereload:
        options:
          livereload: "<%= connect.options.livereload %>"

        files: [
          "<%= yeoman.app %>/*.html"
          ".tmp/styles/{,*/}*.css"
          "{.tmp,<%= yeoman.app %>}/scripts/{,*/}*.js"
          "<%= yeoman.app %>/images/{,*/}*.{png,jpg,jpeg,gif,webp,svg}"
        ]

    connect:
      options:
        port: 9000
        livereload: 35729

        hostname: "0.0.0.0"

      livereload:
        options:
          open: true
          base: [
            ".tmp"
            "<%= yeoman.app %>"
            "."
          ]

      test:
        options:
          base: [
            ".tmp"
            "test"
            "<%= yeoman.app %>"
          ]

      dist:
        options:
          open: true
          base: "<%= yeoman.dist %>"

    clean:
      dist:
        files: [
          dot: true
          src: [
            ".tmp"
            "<%= yeoman.dist %>/*"
            "!<%= yeoman.dist %>/.git*"
          ]
        ]

      server: ".tmp"

    jshint:
      options:
        jshintrc: ".jshintrc"

      all: [
        "Gruntfile.js"
        "<%= yeoman.app %>/scripts/{,*/}*.js"
        "!<%= yeoman.app %>/scripts/vendor/*"
        "test/spec/{,*/}*.js"
      ]

    mocha:
      all:
        options:
          run: true
          urls: ["http://<%= connect.test.options.hostname %>:<%= connect.test.options.port %>/index.html"]

    coffee:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/scripts"
          src: "{,**/}*.coffee"
          dest: ".tmp/scripts"
          ext: ".js"
        ]
        options :
          sourceMap: yes

      test:
        files: [
          expand: true
          cwd: "test/spec"
          src: "{,*/}*.coffee"
          dest: ".tmp/spec"
          ext: ".js"
        ]

    compass:
      options:
        sassDir: "<%= yeoman.app %>/styles"
        cssDir: ".tmp/styles"
        generatedImagesDir: ".tmp/images/generated"
        imagesDir: "<%= yeoman.app %>/images"
        javascriptsDir: "<%= yeoman.app %>/scripts"
        fontsDir: "<%= yeoman.app %>/styles/fonts"
        importPath: "<%= yeoman.libs %>"
        httpImagesPath: "/images"
        httpGeneratedImagesPath: "/images/generated"
        httpFontsPath: "/styles/fonts"
        relativeAssets: false
        assetCacheBuster: false

      dist:
        options:
          generatedImagesDir: "<%= yeoman.dist %>/images/generated"

      server:
        options:
          debugInfo: true

    autoprefixer:
      options:
        browsers: ["last 1 version"]

      dist:
        files: [
          expand: true
          cwd: ".tmp/styles/"
          src: "{,*/}*.css"
          dest: ".tmp/styles/"
        ]


  # not used since Uglify task does concat,
  # but still available if needed
  #concat: {
  #            dist: {}
  #        },
    requirejs:
      dist:

      # Options: https://github.com/jrburke/r.js/blob/master/build/example.build.js
        options:

        # `name` and `out` is set by grunt-usemin
          baseUrl: "<%= yeoman.tmp %>/scripts"
          optimize: "none"

          name: 'main'
          out: '<%= yeoman.dist %>/scripts/main.js'
          mainConfigFile: '<%= yeoman.tmp %>/scripts/main.js'

        # TODO: Figure out how to make sourcemaps work with grunt-usemin
        # https://github.com/yeoman/grunt-usemin/issues/30
        #generateSourceMaps: true,
        # required to support SourceMaps
        # http://requirejs.org/docs/errors.html#sourcemapcomments
          preserveLicenseComments: false
          useStrict: true
        # non AMD thirdparties need to run in global scope
          wrap: false


  #uglify2: {} // https://github.com/mishoo/UglifyJS2
    rev:
      dist:
        files:
          src: [
            "<%= yeoman.dist %>/scripts/{,*/}*.js"
            "<%= yeoman.dist %>/styles/{,*/}*.css"
            "<%= yeoman.dist %>/images/{,*/}*.{png,jpg,jpeg,gif,webp}"
            "<%= yeoman.dist %>/styles/fonts/{,*/}*.*"
            ]

    uglify:
      'dist/scripts/main.js': 'dist/scripts/main.js'

    useminPrepare:
      options:
        dest: "<%= yeoman.dist %>"

      html: "<%= yeoman.app %>/index.html"

    usemin:
      options:
        dirs: ["<%= yeoman.dist %>"]

      html: ["<%= yeoman.dist %>/{,*/}*.html"]
      css: ["<%= yeoman.dist %>/styles/{,*/}*.css"]

    imagemin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/images"
          src: "{,*/}*.{png,jpg,jpeg}"
          dest: "<%= yeoman.dist %>/images"
        ]

    svgmin:
      dist:
        files: [
          expand: true
          cwd: "<%= yeoman.app %>/images"
          src: "{,*/}*.svg"
          dest: "<%= yeoman.dist %>/images"
        ]

    cssmin: {}

  # This task is pre-configured if you do not wish to use Usemin
  # blocks for your CSS. By default, the Usemin block from your
  # `index.html` will take care of minification, e.g.
  #
  #     <!-- build:css({.tmp,app}) styles/main.css -->
  #
  # dist: {
  #     files: {
  #         '<%= yeoman.dist %>/styles/main.css': [
  #             '.tmp/styles/{,*/}*.css',
  #             '<%= yeoman.app %>/styles/{,*/}*.css'
  #         ]
  #     }
  # }
    htmlmin:
      dist:
        options: {}

      #removeCommentsFromCDATA: true,
      #                    // https://github.com/yeoman/grunt-usemin/issues/44
      #                    //collapseWhitespace: true,
      #                    collapseBooleanAttributes: true,
      #                    removeAttributeQuotes: true,
      #                    removeRedundantAttributes: true,
      #                    useShortDoctype: true,
      #                    removeEmptyAttributes: true,
      #                    removeOptionalTags: true
        files: [
          expand: true
          cwd: "<%= yeoman.app %>"
          src: "*.html"
          dest: "<%= yeoman.dist %>"
        ]


  # Put files not handled in other tasks here
    copy:

      temp:
        files: [
          expand: true
          dot: true
          cwd: "<%= yeoman.app %>"
          dest: "<%= yeoman.tmp %>"
          src: [
            "scripts/{,**/}*.{js,vert,frag}"
          ]
        ]

      subs:
        files: [
          expand: true
          dot: true
          flatten:true
          cwd: "<%= yeoman.subs %>"
          dest: "<%= yeoman.tmp %>/scripts"
          src: [
            "three/build/three.js"
          ]
        ]

      dist:
        files: [
          expand: true
          dot: true
          cwd: "<%= yeoman.app %>"
          dest: "<%= yeoman.dist %>"
          src: ["*.{ico,png,txt}"
                ".htaccess"
                "assets/{,**/}*.*"
                "styles/fonts/{,*/}*.*"
                ]
        ]

      styles:
        expand: true
        dot: true
        cwd: "<%= yeoman.app %>/styles"
        dest: ".tmp/styles/"
        src: "{,*/}*.css"

    modernizr:
      devFile: "<%= yeoman.libs %>/modernizr/modernizr.js"
      outputFile: "<%= yeoman.libs %>/modernizr/modernizr-custom.js"
      files: [
        "<%= yeoman.app %>/scripts/{,*/}*.js"
        "<%= yeoman.tmp %>/scripts/{,*/}*.js"
        "<%= yeoman.tmp %>/styles/{,*/}*.css"
      ]
      uglify: true

    concurrent:

      server: ["compass"
               "coffee:dist"
               "copy:styles"
              ]

      test: ["coffee"
             "copy:styles"
            ]

      dist: ["coffee"
             "compass"
             "copy:styles"
             "imagemin"
             "svgmin"
             "htmlmin"
            ]

    bower:
      options:
        exclude: ["modernizr"]

      all:
        rjsConfig: "<%= yeoman.app %>/scripts/main.js"

  grunt.registerTask "server", (target) ->
    return grunt.task.run(["build", "connect:dist:keepalive"])  if target is "dist"

    grunt.task.run [
      "clean:server"
      "copy:subs"
      "concurrent:server"
      "modernizr"
      "autoprefixer"
      "connect:livereload"
      "watch"
      ]

  grunt.registerTask "test", [
    "clean:server",
    "concurrent:test",
    "autoprefixer",
    "connect:test",
    "mocha"
    ]

  grunt.registerTask "build", [
    "clean:dist"
    "copy:temp"
    "copy:subs"
    "modernizr"
    "useminPrepare"
    "concurrent:dist"
    "autoprefixer"
    "requirejs"
    "concat"
    "cssmin"
    "uglify"
    "copy:dist"
    "rev"
    "usemin"
    ]

  grunt.registerTask "default", [
    "jshint",
    "test",
    "build"
    ]