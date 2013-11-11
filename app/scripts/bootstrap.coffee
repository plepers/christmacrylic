#    bootstrap
#    --------------
#    Author: Pierre Lepers
#    Date: 10/11/2013
#    Time: 23:08

define [
  './tasks'
  'when'
], (
  tasks
  When
)->
  # pipeline
  # ----
  # The bootstrapping pipeline
  # containing all tasks required to
  # configure a <context> object
  pipeline = [
    tasks.domReady
    tasks.mousePosition
    tasks.forceFallback
    tasks.capabilities
    tasks.setupXhr
    tasks.setupRenderer
    tasks.setupAnimator
    # tasks.setupFraming
    tasks.normalizeAudio
    tasks.inputFeatures
    tasks.configure
    tasks.finalize
  ]

  # `export`
  # ------
  # function which run the tasks chain with the given context object
  # retrun the tail promise of the pipeline which must resolve to
  # this initialized context
  ( context )->
    When.reduce(
      pipeline
      ( context, task ) ->
        task context
      context
    )

