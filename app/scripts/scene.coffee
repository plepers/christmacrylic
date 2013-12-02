#    scene
#    --------------
#    Author: Pierre Lepers
#    Date: 10/11/2013
#

define [
  'three'
  'when'
  'materials/NPRMaterial'
  'materials/NPRPhongMaterial'
  './tasks'
], (
  THREE
  When
  NPRMaterial
  NPRPhongMaterial
  tasks
)->


  NprBumpPhase = new THREE.Vector3(0,0,0)
  NprFreqLow = new THREE.Vector3(5,5,5)
  NprFreqHi = new THREE.Vector3(5,5,5)



  class Scene

    constructor : (@ctx)->

      @textures = {}

      @scene3d = new THREE.Scene()
      @camera = new THREE.PerspectiveCamera( 70, window.innerWidth / window.innerHeight, 1, 20000 )
      @camera.position.x = -247.32693778059766
      @camera.position.y = 147.07942855805342
      @camera.position.z = 300

      @nprBumpPhase = NprBumpPhase


      @light1 = new THREE.DirectionalLight( 0xE6CF9C , .8 )
      @light1.position.set( .5, .3 , .5 )
      @scene3d.add @light1

      @light2 = new THREE.DirectionalLight( 0x768EA6 , 1.0 )
      @light2.position.set( -.5, .3 , -.2 )

      @scene3d.add @light2


      @orbit = new THREE.OrbitControls @camera, window.document
      @orbit.target.set -100, 100, -200



    preRender : (dt)->
      @orbit.update()

      console.log @camera.position

      x = (@ctx.mouse.x-500) * .00001
      y = @ctx.mouse.y / 1000
      s = (@ctx.mouse.x - 200) / 3000
      b = (@ctx.mouse.y - 200) / 10000
      #@light1.intensity = @ctx.mouse.x/100
      #console.log s, b
      #@material.uniforms.diffuseSharpness.value = s
      #@material.uniforms.diffuseSharpnessBias.value = b
      #@material.uniforms.nbumbPhase.value =  new THREE.Vector3( s, s, s )
      x = (5+x)
      NprFreqLow.set x, x, x
      #@material?.uniforms.nbumpFreq.value =  new THREE.Vector3( x, x, x )
      #@material.uniforms.nbump.value =  b
      #@material.bumpScale= b
      #@material.normalScale.set( b, b )
      #@material.uniforms.shininess.value = 363 #@ctx.mouse.x - 200
      #@material.setSharpeness s,.5
      #console.log s

      #@mesh.rotation.y += .01

    load : ->
      When.all( [
        @loadTexture 'acrilic_NRM_deep.png'
        @loadTexture 'sky.jpg'
      ] )
      .then @texLoaded

    texLoaded : ()=>
      console.log 'textures loaded'
      @acrilicTex = @textures['acrilic_NRM_deep.png']
      @loadScene()


    loadScene : =>
      console.log 'loadScene'

      @loadModel 'sapin'
      @loadModel 'ground'
      @loadModel 'chalets'
      @loadModel 'foret'
      @loadModel 'sleigh'

      tasks.loadModel( 'assets/sky.js' )
        .then @skyLoaded
        
      
    skyLoaded : (geom) =>
      mat = new THREE.MeshBasicMaterial
        map : @textures['sky.jpg']

      sky = new THREE.Mesh geom, mat
      @scene3d.add( sky )


    loaded : (mesh)=>
      console.log 'loaded mesh', mesh
      @scene3d.add( mesh )

      @material = mesh.material

    loadTexture : (file)->
      tasks.loadTexture("assets/#{file}")
        .then (tex)=>
          console.log file
          tex.wrapS = tex.wrapT = THREE.RepeatWrapping
          @textures[file] = tex

    loadModel : (name)->
      tasks.loadModel("assets/#{name}.js")
        .then( @createMesh(name) )
        .then @loaded
        
    createMesh : (name)=>
      (geom)=>
        matdef = materials[name] || materials['default']
        mat = @createMaterial matdef
        mesh = new THREE.Mesh geom, mat
        mesh.name = name
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
      if opts.nprFreq?    then mat.uniforms.nbumpFreq.value = opts.nprFreq
      if opts.acrilic?    then mat.normalScale.set( opts.acrilic, opts.acrilic )


      if opts.vc 
        mat.vertexColors = THREE.VertexColors
      else
        mat.vertexColors = THREE.NoColors

      mat


  materials = 
    default : 
      shininess : 363
      sharpeness : .02
      sharpoff : .5
      nprBump : .004
      nprFreq : NprFreqHi
      acrilic : .5
      vc : yes
    sapin : 
      shininess : 363
      sharpeness : .02
      sharpoff : .5
      nprBump : .004
      nprFreq : NprFreqHi
      acrilic : .5
      vc : yes

    foret:
      shininess : 363
      sharpeness : .02
      sharpoff : .5
      nprBump : .004
      nprFreq : NprFreqLow
      acrilic : .5
      vc : yes
    ground : 
      shininess : 0
      sharpeness : .02
      sharpoff : .5
      nprBump : .004
      nprFreq : NprFreqLow
      acrilic : .1
      vc : no

  Scene



