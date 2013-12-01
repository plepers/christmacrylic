#    tasks
#    --------------
#    Author: Pierre Lepers
#    Date: 10/11/2013
#    Time: 23:09

#    Author: Pierre Lepers
#    Date: 18/05/13
#    Time: 17:23
#
#    Tasks
#    List of promise based, transversal tasks

define [
  'when'
  'jquery'
  'underscore'
  'three'
  'errors'
], (
  When
  $
  _
  THREE
  errors
)->

  {
    forcedFallback
    unsupp_renderer
    capabilities
    unknown_renderer
    no_hxr
  } = errors.tasks



  # placeholder for an available ajax method
  _ajaxlib = null

  tasks =


  # **Bootstrap**
  # ========
  # Sync and Async tasks boostrapping application
  # A `ctx` (context) Object is used as traverser in whole bootstrap pipeline
  # thus all deferred must resolve to the passed-in `ctx
  #  ----



    # domReady
    # -----
    # Simply wait for document ready
    #
    domReady : (ctx)->
      deferred = When.defer()
      $document = $ document
      $document.ready ()->
        $document.unbind 'ready'
        deferred.resolve ctx

      deferred.promise

    # mousepos
    # -----
    # utility to get mouse position
    # without move event
    #
    mousePosition : (ctx)->
      m = ctx.mouse =
        x:0
        y:0
      $(window).mousemove (e)->
        m.x = e.pageX
        m.y = e.pageY

      When.resolve ctx


    # forceFallback
    # -------
    # Check if options request to force fallback
    # if `true`, reject with the dedicated status code
    # else -> NoOp
    #
    forceFallback : (ctx)->
      if ctx.options._fallback is true
        When.reject forcedFallback()
      else
        When.resolve ctx



    # capabilities
    # ----
    # Test a set of browser capabilities using modernizr
    # put results in ctx.capabilities
    # required for further tasks
    #
    capabilities : (ctx)->

      tests = {
        'webgl'
        'canvas'
      }

      ctx.capabilities ?= {}
      for prop of tests
        p = ctx.capabilities[prop] = Modernizr[tests[prop]]
        # sanity check on Modernizr tests support.
        # Reject if a test is not available in Modernizer
        return When.reject capabilities( p ) if typeof p isnt 'boolean'

      When ctx



    # inputFeatures
    # ----
    # Define the type of input type available
    # on the platform (touch and mouse) and set a
    # constant in ctx.inputType
    # TODO inputFeatures to complete (std touch, ios etc)
    #
    inputFeatures : (ctx)->
      ctx.inputType = do ->
        if window.navigator.msPointerEnabled
          "msPointer"
        else
          "none"

      When ctx

    # setupXhr
    # ----
    # Provide an available XHR method according environment
    # task never reject since hxr shoudn't be
    # needed depending config.
    # Create a normalized Ajax method (jquery like)
    # and put result in ctx.ajax
    #
    setupXhr : (ctx)->
      # for now support only jquery ajax
      _ajaxlib =
      ctx.ajax =
      if $.support.ajax
        -> $.ajax.apply $, arguments

      When ctx


    # setupRenderer
    # ----
    # Find the best Threejs renderer according to ctx capabilities.
    # For now, just take the first rendering abilities found in renderer
    # list, sorted by preference.
    # Put result in ctx.renderer
    #
    setupRenderer : (ctx)->

      #svg?
      renderers = [
        'webgl'
        'canvas'
      ]

      ctx.renderer =
      renderer = ctx.options.renderer || _.find renderers, ( r ) ->
          ctx.capabilities[r]

      unless renderer?
        When.reject unsupp_renderer()
      else unless ctx.capabilities[renderer]?
        When.reject unsupp_renderer renderer
      else if renderers.indexOf(renderer) is -1
        When.reject unknown_renderer renderer
      else
        When ctx


    # setupAnimator
    # ----
    # Define a shim layer for requestAnimationFrame
    # with a setTimeout fallback.
    # Put result in ctx.requestAnimationFrame
    #
    setupAnimator : (ctx)->

      do ->
        _timeouts=[]

        raf = (
          window.requestAnimationFrame       ||
          window.webkitRequestAnimationFrame ||
          window.mozRequestAnimationFrame    ||
          ( cb ) ->
            window.setTimeout cb, 1000/60
        )
        ctx.requestAnimationFrame = ( callback )->
          tid = raf.call window, callback
          _timeouts.push {tid, callback}

        caf = (
          window.cancelAnimationFrame ||
          window.mozCancelAnimationFrame ||
          window.clearTimeout
        )
        ctx.cancelAnimationFrame = ( cb )->
          for {tid,callback}, i in _timeouts by -1 when callback is cb
            caf.call window, tid
            _timeouts.splice i, 1

      When ctx


    # setupFraming
    # --------
    # run TweenJs lib update cycle
    #
    #setupFraming : (ctx)->
    #  prev = Date.now()
    #  do frame = ->
    #    now = Date.now()
    #   ctx.dt = (now - prev)/1000
    #   prev = now
    #   TWEEN.update()
    #   ctx.requestAnimationFrame frame
    # When ctx


    # normalizeAudio
    # --------
    # remove webkit prefix for Web Audio
    #
    normalizeAudio : (ctx )->
      window.AudioContext = window.AudioContext || window.webkitAudioContext
      When ctx

    # configure
    # ----
    # misc stuff
    # Todo -> load and build assets
    #
    configure : (ctx)->

      ctx.resolveAsset = (path)->
        "#{ctx.options.assetsDir}/#{path}"

      _seed = (Math.random() * 0xFFFFFFFF) | 0
      ctx.getSeed = -> _seed
      When ctx





    # finalize bootstrapping
    # ----
    # Setup mediator with pipelined context
    #
    finalize : (ctx)->
      #mediator.setup ctx
      When ctx


    # **IO**
    # ======================================================================================
    # IO utilities tasks
    #  ------------




    # ajax
    # ----
    # basic XHR loading using context's ajax method
    # resolve to xhr response object
    #
    ajax : ( params )->
      deferred = When.defer()
      unless _ajaxlib?
        deferred.reject no_hxr()

      success = params.success
      params.success = (resp)->
        success? resp
        deferred.resolve resp

      error = params.error
      params.error = ( jqXHR, textStatus, errorThrown)->
        error? textStatus, errorThrown
        deferred.reject errorThrown

      _ajaxlib params

      deferred.promise


    # loadJson
    # ----
    # convenient task to load json via ajax.
    # Resolve to json object
    #
    loadJson : (url)->
      tasks.ajax {
        url
        dataType: 'json'
      }

    # loadBytes
    # ----
    # convenient task to load binary data via ajax.
    # Resolve to ArrayBuffer object
    #
    loadBytes : (url, method = 'GET')->
      deferred = When.defer()

      xhr = new XMLHttpRequest()
      xhr.open method, url, true
      xhr.responseType = "arraybuffer"

      xhr.onload = ->
        deferred.resolve xhr.response
      xhr.error = (e)->
        deferred.reject e

      xhr.send()

      deferred.promise

    # loadModule
    # -----
    # Promise based AMD loading task.
    #
    loadModule : ( moduleName )->
      deferred = When.defer()
      require(
        [ moduleName ]
        ( module )-> deferred.resolve module
        ( error )-> deferred.reject error
      )
      deferred.promise


    # loadImage
    # ----------
    # simply load img element
    loadImage : (url)->
      deferred = When.defer()
      img = document.createElement 'img'
      img.onload = ->
        deferred.resolve img
      img.onerror = (e)->
        deferred.reject e
      img.src = url
      deferred.promise

    # loadModel
    # ---------
    # load a three js json model

    loadModel : (url)->
      deferred = When.defer()

      new THREE.JSONLoader().load "assets/cadeaux.js", 
        (geom)->deferred.resolve geom

      deferred.promise







  # export
  # ------
  tasks