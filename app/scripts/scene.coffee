#    scene
#    --------------
#    Author: Pierre Lepers
#    Date: 10/11/2013
#

define [
  'three'
  'materials/NPRMaterial'
  'materials/NPRPhongMaterial'
], (
  THREE
  NPRMaterial
  NPRPhongMaterial
)->

  class Scene

    constructor : (@ctx)->

      @scene3d = new THREE.Scene()
      @camera = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
      @camera.position.z = 10


      @light = new THREE.DirectionalLight( 0xE6CF9C , .5 )
      @light.position.set( .5, .3 , .5 )
      @scene3d.add @light

      @light = new THREE.DirectionalLight( 0x768EA6 , .5 )
      @light.position.set( -.5, .3 , -.2 )
      @scene3d.add @light


      @orbit = new THREE.OrbitControls @camera, window.document


    preRender : (dt)->
      @orbit.update()

      #@material.uniforms.diffuseSharpness.value =
      x = (@ctx.mouse.x-500) / 10
      y = @ctx.mouse.y / 1000
      s = @ctx.mouse.x / 300 - 2
      #@material.uniforms.diffuseSharpnessBias.value = 50
      #@material.uniforms.nbumbPhase.value =  new THREE.Vector3( s, s, s )
      #@material.uniforms.nbumpFreq.value =  new THREE.Vector3( x, x, x )
      @material.uniforms.nbump.value =  .15

      @teapot.rotation.y += .01

    load : ->
      #loader = new THREE.JSONLoader()
      #loader.load 'assets/teapot.js', @onTeapot

      #@material = new NPRMaterial()
      #@material.uniforms.diffuseSharpness.value = s = .1
      #@material.uniforms.diffuseSharpnessBias.value = 2

      #material = new THREE.MeshPhongMaterial()

      @material = new NPRPhongMaterial()
      @material.uniforms.diffuseSharpness.value = s = .05
      @material.uniforms.diffuseSharpnessBias.value = 8

      @material.uniforms.nbump.value  =      .2
      @material.uniforms.nbumpFreq.value  =   new THREE.Vector3( 110, 101, 110 )
      @material.uniforms.nbumpPhase.value =   new THREE.Vector3( 1, 1, 1 )

      @teapot = new THREE.Mesh(
        new THREE.TeapotGeometry(
          5,
          5,
          true
        ),
        @material
      )

      @scene3d.add( @teapot )