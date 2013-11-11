#    engine
#    --------------
#    Author: Pierre Lepers
#    Date: 10/11/2013
#    Time: 17:43

define [
  'three'
  'scene'
  'composer'
], (
  THREE
  Scene
  Composer
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
      @renderer.setClearColorHex 0x0, 1


      @renderer.setSize window.innerWidth, window.innerHeight
      document.getElementById("canvas-wrapper").appendChild @renderer.domElement

      @composer = new Composer()

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


      bumpFreq = @scene.material.uniforms.nbumpFreq
      bumpPhase = @scene.material.uniforms.nbumpPhase

      @renderer.clear();

      freq = 2

      for p, i in @composer.cfg.phases
        bumpFreq.value.set( freq, freq, freq )
        bumpPhase.value.set( p.phase[0], p.phase[1], p.phase[2] )
        @renderer.render( @scene.scene3d, @scene.camera, p.tex, yes )


      @renderer.render @composer.scene, @composer.camera


  Engine