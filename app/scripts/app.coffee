define [
  'engine'
  'bootstrap'
], (
  Engine
  bootstrap
)->

  class App



    initialize : (options)->
      bootstrap( {options} )
        .then( @run )
        .otherwise( @recover )


    run : ( ctx )=>
      console.log 'run'
      @engine = new Engine()
      @engine.init ctx
      @engine.play()


    recover : (err)=>
      @dispose()
      console.log err.stack

      err = errors.normalize err

      if err.code >= 500
        When.reject err
      else
        When err

    # dispose app
    dispose : ->