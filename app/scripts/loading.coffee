define [
  'three'
],(
  THREE
) ->

  class Loading extends THREE.Object3D

    constructor : (@scene)->
      super

    run :->

      @scene.loadModel( 'lgift' )
        .then @play

    play : (gift)=>
      gift.rotation.y = .4
      @add gift

    release : ->


  Loading

