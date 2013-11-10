require.config( {
  baseUrl: 'scripts',
  shim: {

    three: {
      exports: 'THREE'
    }
  },

  paths: {


    three:        'three',

    jquery:       '../bower_components/jquery/jquery',
    underscore:   '../bower_components/underscore-amd/underscore',
    when:         '../bower_components/when/when',
    tween:        '../bower_components/tweenjs/build/tween.min'
  }

});