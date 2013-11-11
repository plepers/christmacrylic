#    scene
#    --------------
#    Author: Pierre Lepers
#    Date: 10/11/2013
#

define [
  'three'
  'NPRMaterial'
], (
  THREE
  NPRMaterial
)->

  class Scene

    constructor : (@ctx)->

      @scene3d = new THREE.Scene()
      @camera = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
      @camera.position.z = 10


      @light = new THREE.DirectionalLight( 0xFFAF40 , 1 )
      @light.position.set( .5, .5 , .5 )
      @scene3d.add @light

      @light = new THREE.DirectionalLight( 0xB1D7E3 , 1 )
      @light.position.set( -.5, .5 , -.2 )
     # @scene3d.add @light


      @orbit = new THREE.OrbitControls @camera, window.document


    preRender : (dt)->
      @orbit.update()

    load : ->
      #loader = new THREE.JSONLoader()
      #loader.load 'assets/teapot.js', @onTeapot

      material = new NPRMaterial()
      #material = new THREE.MeshPhongMaterial()

      teapot = new THREE.Mesh(
        new THREE.TeapotGeometry(
          5,
          5,
          true
        ),
        material
      )

      @scene3d.add( teapot )