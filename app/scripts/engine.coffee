#    engine
#    --------------
#    Author: Pierre Lepers
#    Date: 10/11/2013
#    Time: 17:43

define [
  'three'
], (
  THREE
)->

  class Engine

    constructor : ->

      @renderer = null
      @scene = null

    init : ->

      renderer = new THREE.WebGLRenderer(
        antialias: true # to get smoother output
        preserveDrawingBuffer: true # to allow screenshot
      )
      renderer.setClearColorHex 0xBBBBBB, 1


      renderer.setSize window.innerWidth, window.innerHeight
      document.getElementById("canvas-wrapper").appendChild renderer.domElement

  Engine