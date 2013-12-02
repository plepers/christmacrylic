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
      mul = 1.1
      Off = -.05
      @composer.uniforms.ctMul.value.set mul,mul,mul
      @composer.uniforms.ctOff.value.set Off,Off,Off

      @scene = new Scene ctx
      @scene.load()


      @gui = new dat.GUI()
      @gui.add @scene, 'animate'
      @gui.add @scene, 'noisiness', 0, .01


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


      bumpPhase = @scene.nprBumpPhase

      @renderer.clear();


      for p, i in @composer.cfg.phases
        bumpPhase.set( p.phase[0], p.phase[1], p.phase[2] )
        @renderer.render( @scene.scene3d, @scene.camera, p.tex, yes )


      @renderer.render @composer.scene, @composer.camera


  Engine