define [
  'engine'
], (
  Engine
)->

  class App

    constructor : ->
      @engine = new Engine()
      @engine.init()