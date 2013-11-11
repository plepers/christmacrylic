#    NPRMaterial
#    --------------
#    Author: Pierre Lepers
#    Date: 11/11/2013
#    Time: 01:12

define [
  'three'
], (
  THREE
)->

  class NPRMaterial extends THREE.ShaderMaterial

    constructor : ->

      super

      @uniforms        = THREE.UniformsUtils.clone( SHADER.uniforms )
      @vertexShader    = SHADER.vertexShader
      @fragmentShader  = SHADER.fragmentShader

      @uniforms.ambient.value = 0x0000FF
      @uniforms.emissive.value = 0xFF0000
      @uniforms.wrapRGB.value = new THREE.Vector3( 1, 1, 1 )

      @lights = yes

  SHADER =

    uniforms: THREE.UniformsUtils.merge( [

      THREE.UniformsLib[ "common" ],
      THREE.UniformsLib[ "fog" ],
      THREE.UniformsLib[ "lights" ],
      THREE.UniformsLib[ "shadowmap" ],

      {
        "ambient"  : { type: "c", value: new THREE.Color( 0xffffff ) },
        "emissive" : { type: "c", value: new THREE.Color( 0xff0000 ) },
        "wrapRGB"  : { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) }
      }

    ] ),

    vertexShader: [

      "#define LAMBERT",

      "varying vec3 vLightFront;",

      "#ifdef DOUBLE_SIDED",

        "varying vec3 vLightBack;",

      "#endif",

      THREE.ShaderChunk[ "map_pars_vertex" ],
      THREE.ShaderChunk[ "lightmap_pars_vertex" ],
      THREE.ShaderChunk[ "envmap_pars_vertex" ],
      THREE.ShaderChunk[ "lights_lambert_pars_vertex" ],
      THREE.ShaderChunk[ "color_pars_vertex" ],
      THREE.ShaderChunk[ "morphtarget_pars_vertex" ],
      THREE.ShaderChunk[ "skinning_pars_vertex" ],
      THREE.ShaderChunk[ "shadowmap_pars_vertex" ],

      "void main() {",

        THREE.ShaderChunk[ "map_vertex" ],
        THREE.ShaderChunk[ "lightmap_vertex" ],
        THREE.ShaderChunk[ "color_vertex" ],

        THREE.ShaderChunk[ "morphnormal_vertex" ],
        THREE.ShaderChunk[ "skinbase_vertex" ],
        THREE.ShaderChunk[ "skinnormal_vertex" ],
        THREE.ShaderChunk[ "defaultnormal_vertex" ],

        THREE.ShaderChunk[ "morphtarget_vertex" ],
        THREE.ShaderChunk[ "skinning_vertex" ],
        THREE.ShaderChunk[ "default_vertex" ],

        THREE.ShaderChunk[ "worldpos_vertex" ],
        THREE.ShaderChunk[ "envmap_vertex" ],
        THREE.ShaderChunk[ "lights_lambert_vertex" ],
        THREE.ShaderChunk[ "shadowmap_vertex" ],

      "}"

    ].join("\n"),

    fragmentShader: [

      "uniform float opacity;",

      "varying vec3 vLightFront;",

      "#ifdef DOUBLE_SIDED",

        "varying vec3 vLightBack;",

      "#endif",

      THREE.ShaderChunk[ "color_pars_fragment" ],
      THREE.ShaderChunk[ "map_pars_fragment" ],
      THREE.ShaderChunk[ "lightmap_pars_fragment" ],
      THREE.ShaderChunk[ "envmap_pars_fragment" ],
      THREE.ShaderChunk[ "fog_pars_fragment" ],
      THREE.ShaderChunk[ "shadowmap_pars_fragment" ],
      THREE.ShaderChunk[ "specularmap_pars_fragment" ],

      "void main() {",

        "gl_FragColor = vec4( vec3 ( 1.0 ), opacity );",

        THREE.ShaderChunk[ "map_fragment" ],
        THREE.ShaderChunk[ "alphatest_fragment" ],
        THREE.ShaderChunk[ "specularmap_fragment" ],

        "#ifdef DOUBLE_SIDED",

          "if ( gl_FrontFacing )",
            "gl_FragColor.xyz *= vLightFront;",
          "else",
            "gl_FragColor.xyz *= vLightBack;",

        "#else",

          "gl_FragColor.xyz *= vLightFront;",

        "#endif",

        THREE.ShaderChunk[ "lightmap_fragment" ],
        THREE.ShaderChunk[ "color_fragment" ],
        THREE.ShaderChunk[ "envmap_fragment" ],
        THREE.ShaderChunk[ "shadowmap_fragment" ],

        THREE.ShaderChunk[ "linear_to_gamma_fragment" ],

        THREE.ShaderChunk[ "fog_fragment" ],

      "}"

    ].join("\n")

  NPRMaterial
