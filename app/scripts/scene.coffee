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
      @camera.position.x = 13.31
      @camera.position.y = 8.37
      @camera.position.z = -9.75


      @light = new THREE.DirectionalLight( 0xE6CF9C , .5 )
      @light.position.set( .5, .3 , .5 )
      @scene3d.add @light

      @light = new THREE.DirectionalLight( 0x768EA6 , .5 )
      @light.position.set( -.5, .3 , -.2 )

      @scene3d.add @light


      @orbit = new THREE.OrbitControls @camera, window.document


    preRender : (dt)->
      @orbit.update()

      x = (@ctx.mouse.x-500) / 10
      y = @ctx.mouse.y / 1000
      s = (@ctx.mouse.x - 200) / 300
      b = (@ctx.mouse.y - 200) / 100

      #console.log s, b
      #@material.uniforms.diffuseSharpness.value = s
      #@material.uniforms.diffuseSharpnessBias.value = b
      #@material.uniforms.nbumbPhase.value =  new THREE.Vector3( s, s, s )
      #@material.uniforms.nbumpFreq.value =  new THREE.Vector3( x, x, x )
      @material.uniforms.nbump.value =  .006

      #@teapot.rotation.y += .01

    load : ->

      tloader = new THREE.TextureLoader( )
      tloader.load 'assets/bumpbrush.png', @loaded

    loaded : (tex)=>

      @material = new NPRPhongMaterial()
      @material.uniforms.diffuseSharpness.value = s = .12
      @material.uniforms.diffuseSharpnessBias.value = 3.89

      @material.uniforms.nbump.value  =      .2
      @material.uniforms.nbumpFreq.value  =   new THREE.Vector3( 110, 101, 110 )
      @material.uniforms.nbumpPhase.value =   new THREE.Vector3( 1, 1, 1 )

      @material.bumpMap = tex
      @material.bumpScale = .02

      @teapot = new THREE.Mesh(
        new THREE.TeapotGeometry(
          5,
          5,
          true
        ),
        @material
      )

      @scene3d.add( @teapot )