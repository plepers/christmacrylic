#    scene
#    --------------
#    Author: Pierre Lepers
#    Date: 10/11/2013
#

define [
  'three'
  'materials/NPRMaterial'
  'materials/NPRPhongMaterial'
  './tasks'
], (
  THREE
  NPRMaterial
  NPRPhongMaterial
  tasks
)->


  NprBumpPhase = new THREE.Vector3(0,0,0)


  class Scene

    constructor : (@ctx)->

      @scene3d = new THREE.Scene()
      @camera = new THREE.PerspectiveCamera( 60, window.innerWidth / window.innerHeight, 1, 20000 )
      @camera.position.x = 133.1
      @camera.position.y = 83.7
      @camera.position.z = -97.5

      @nprBumpPhase = NprBumpPhase


      @light1 = new THREE.DirectionalLight( 0xE6CF9C , 1.0 )
      @light1.position.set( .5, .3 , .5 )
      @scene3d.add @light1

      @light2 = new THREE.DirectionalLight( 0x768EA6 , 1.0 )
      @light2.position.set( -.5, .3 , -.2 )

      @scene3d.add @light2


      @orbit = new THREE.OrbitControls @camera, window.document


    preRender : (dt)->
      @orbit.update()

      x = (@ctx.mouse.x-500) * .001
      y = @ctx.mouse.y / 1000
      s = (@ctx.mouse.x - 200) / 3000
      b = (@ctx.mouse.y - 200) / 10000
      #@light1.intensity = @ctx.mouse.x/100
      #console.log s, b
      #@material.uniforms.diffuseSharpness.value = s
      #@material.uniforms.diffuseSharpnessBias.value = b
      #@material.uniforms.nbumbPhase.value =  new THREE.Vector3( s, s, s )
      
      #@material?.uniforms.nbumpFreq.value =  new THREE.Vector3( x, x, x )
      #@material.uniforms.nbump.value =  b
      #@material.bumpScale= b
      #@material.normalScale.set( b, b )
      #@material.uniforms.shininess.value = 363 #@ctx.mouse.x - 200
      #@material.setSharpeness s,.5
      #console.log s

      #@mesh.rotation.y += .01

    load : ->

      tloader = new THREE.TextureLoader( )
      tloader.load 'assets/acrilic_NRM_deep.png', @texLoaded


    texLoaded : (tex)=>
      @acrilicTex = tex
      console.log 'acrilicTexLoaded'
      @loadScene()


    loadScene : =>
      console.log 'loadScene'

      @loadModel("cadeaux")
        .then @loaded
      



    loaded : (mesh)=>
      @scene3d.add( mesh )

      @material = mesh.material



    loadModel : (name)->
      tasks.loadModel("assets/#{name}.js")
        .then( @createMesh(name) )
        
    createMesh : (name)=>
      (geom)=>
        mat = @createMaterial materials[name]
        mesh = new THREE.Mesh geom, mat
        mesh.name = name
        mesh.scale.set .7,.7,.7
        mesh.position.y = -4
        mesh

    createMaterial : (opts)=>
      mat = new NPRPhongMaterial()
      mat.uniforms.nbumpPhase.value = @nprBumpPhase

      mat.normalMap = @acrilicTex

      if opts.shininess?  then mat.shininess = opts.shininess

      sharpness = opts.sharpeness or .02
      sharpoff =  opts.sharpoff or .5
      mat.setSharpeness sharpness, sharpoff

      if opts.nprBump?    then mat.uniforms.nbump.value  =      opts.nprBump
      if opts.nprFreq?    then mat.uniforms.nbumpFreq.value.set( opts.nprFreq, opts.nprFreq, opts.nprFreq )
      if opts.acrilic?    then mat.normalScale.set( opts.acrilic, opts.acrilic )


      mat


  materials = 
    cadeaux : 
      shininess : 363
      sharpeness : .02
      sharpoff : .5
      nprBump : .004
      nprFreq : 20
      acrilic : .5

  Scene



