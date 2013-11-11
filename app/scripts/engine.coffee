#    engine
#    --------------
#    Author: Pierre Lepers
#    Date: 10/11/2013
#    Time: 17:43

define [
  'three'
  'scene'
], (
  THREE
  Scene
)->

  class Engine

    constructor : ->
      @ctx = null
      @renderer = null
      @scene = null
      @_running = no

    init : (@ctx) ->

      @renderer = new THREE.WebGLRenderer(
        antialias: true # to get smoother output
        preserveDrawingBuffer: true # to allow screenshot
      )
      @renderer.setClearColorHex 0xBBBBBB, 1


      @renderer.setSize window.innerWidth, window.innerHeight
      document.getElementById("canvas-wrapper").appendChild @renderer.domElement

      @scene = new Scene ctx
      @scene.load()

    play : ->
      return if @_running
      @_running = true
      @ctx.requestAnimationFrame @_render



    stop : ->
      return unless @_running
      @_running = false
      @ctx.cancelAnimationFrame @_render



    _render : =>
      return unless @_running
      @ctx.requestAnimationFrame @_render

      @scene.preRender @ctx.dt
      @renderer.render( @scene.scene3d, @scene.camera )



  Engine