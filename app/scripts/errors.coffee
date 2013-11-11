#    errors
#    --------------
#    Author: Pierre Lepers
#    Date: 10/11/2013
#    Time: 23:10

#    Author: Pierre Lepers
#    Date: 18/05/13
#    Time: 17:23

define ->

  # create an error with it's status code
  _error = ( code, e ) ->
    ( args... )->
      if typeof e is 'string'
        e = new Error( e + ' ' + (args.join ' ') )

      e.code = code
      e

  # normalize std errors to an
  # Unknown/Unhandled error (code 500)
  _normalizeError = (obj) ->
    if obj.code? and typeof obj.code is 'number'
      obj
    else
      _error( 500, obj )()

  # debug handler for errors
  _globalHandler = ( error ) ->
    e =
    if typeof error is 'string'
      error
    else if error.stack?
      error.stack
    console.log e


  # errors
  # -----
  # List of known errors and status thrown by app.
  # Each error/status have a code, if code >= 500,
  # it's an error, otherwise it's a recoverable status
  errors =

    status :
      exit             : _error( 0, "exit" )

    config :
      no_container     : _error( 501, "configuration must have 'container' property." )
      no_content       : _error( 502, "'container' have no data/'fallback' content" )
      empty_container  : _error( 503, "configuration 'container' element is empty." )
      missing_texture  : _error( 504, "texture/image missing in data" )
      loading_texture  : _error( 505, "texture loading error" )

    tasks :
      # STATUS
      forcedFallback   : _error( 101, "forced fallback (_fallback is true in options)" )
      unsupp_renderer  : _error( 110, "No renderer availables" )
      # ERRORS
      capabilities     : _error( 510, "Untracked capability, check modernizR includes." )
      unknown_renderer : _error( 511, "Unknown renderer passed in options " )
      no_hxr           : _error( 512, "No HXR available, check jquery support ajax or you have other hxr lib" )

    internal :
      abstract :         _error( 520, "Abstract methods must be overrided." )

    errorHandler : _globalHandler
    normalize : _normalizeError

  errors