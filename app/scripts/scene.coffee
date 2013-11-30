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


      @light1 = new THREE.DirectionalLight( 0xE6CF9C , 1.0 )
      @light1.position.set( .5, .3 , .5 )
      @scene3d.add @light1

      @light2 = new THREE.DirectionalLight( 0x768EA6 , 1.0 )
      @light2.position.set( -.5, .3 , -.2 )

      @scene3d.add @light2


      @orbit = new THREE.OrbitControls @camera, window.document


    preRender : (dt)->
      @orbit.update()

      x = (@ctx.mouse.x-500) / 10
      y = @ctx.mouse.y / 1000
      s = (@ctx.mouse.x - 200) / 3000
      b = (@ctx.mouse.y - 200) / 10000
      #@light1.intensity = @ctx.mouse.x/100
      #console.log s, b
      #@material.uniforms.diffuseSharpness.value = s
      #@material.uniforms.diffuseSharpnessBias.value = b
      #@material.uniforms.nbumbPhase.value =  new THREE.Vector3( s, s, s )
      #@material.uniforms.nbumpFreq.value =  new THREE.Vector3( x, x, x )
      @material.uniforms.nbump.value =  b
      #@material.bumpScale= b
      #@material.normalScale.set( b, b )
      @material.uniforms.shininess.value = 363 #@ctx.mouse.x - 200
      #@material.setSharpeness s,.5
      #console.log s

      #@mesh.rotation.y += .01

    load : ->

      tloader = new THREE.TextureLoader( )
      tloader.load 'assets/acrilic_NRM_deep.png', @texLoaded


    texLoaded : (@tex)=>
      console.log 'teLoaded'
      @loadScene()


    loadScene : =>
      console.log 'loadScene'

      jsonLoader = new THREE.JSONLoader()
      jsonLoader.load "assets/renne.js", @loaded



    loaded : (geometry, materials)=>

      @material = new NPRPhongMaterial()

      @material.shininess = 363
      @material.setSharpeness .02,.5

      @material.uniforms.nbump.value  =      .006
      @material.uniforms.nbumpFreq.value  =   new THREE.Vector3( 110, 101, 110 )
      @material.uniforms.nbumpPhase.value =   new THREE.Vector3( 1, 1, 1 )

      @material.normalMap = @tex
      @material.normalScale.set( .2, .2 )

      @mesh = new THREE.Mesh( geometry, @material )
      @mesh.scale.set .07,.07,.07
      @mesh.position.y = -4

      #@mesh.rotation.z = Math.PI


      @teapot = new THREE.Mesh(
        new THREE.TeapotGeometry(
          5,
          7,
          true
        ),
        @material
      )

      #@scene3d.add( @teapot )
      @scene3d.add( @mesh )