
require.config({
  baseUrl : "scripts",

  shim: {
    three : {
      exports: 'THREE'
    },
    tween : {
      exports: 'TWEEN'
    }
  },

  paths: {
    jquery:     '../../libs/jquery/jquery',
    when:       '../../libs/when/when',
    underscore: '../../libs/underscore-amd/underscore',
    tween:      '../../libs/tweenjs/build/tween.min'
  }

});

/*
============================
IMPORTANT keep these comments in sources

import Modernizr features
============================

Modernizr.webgl
Modernizr.canvas
Modernizr.webaudio
Modernizr.audio_webaudio_api
Modernizr.audio

*/

var opts = {

}

require(['./app'], function(App){
    var app = new App();
    app.initialize( opts );
});