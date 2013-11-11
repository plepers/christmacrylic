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
      THREE.ShaderMaterial.call( this ) # threejs :/

      shader = SHADER

      @defines.DSHARPNESS = yes

      @uniforms        = THREE.UniformsUtils.clone( shader.uniforms )
      @vertexShader    = shader.vertexShader
      @fragmentShader  = shader.fragmentShader

      @uniforms.ambient.value = new THREE.Color( 0xffffff )
      @uniforms.emissive.value = new THREE.Color( 0x000000 )
      @uniforms.wrapRGB.value = new THREE.Vector3( 1, 0,0 )

      @color = new THREE.Color( 0xffffff )
      @ambient = new THREE.Color( 0xffffff )
      @emissive = new THREE.Color( 0xff0000 )
    
      @wrapAround = false
      @wrapRGB = new THREE.Vector3( 1, 0, 0 )
    
      @map = null
    
      @lightMap = null
    
      @specularMap = null
    
      @envMap = null
      @combine = THREE.MultiplyOperation
      @reflectivity = 1
      @refractionRatio = 0.98
    
      @fog = true
    
      @shading = THREE.SmoothShading
    
      @wireframe = false
      @wireframeLinewidth = 1
      @wireframeLinecap = 'round'
      @wireframeLinejoin = 'round'
    
      @vertexColors = THREE.NoColors
    
      @skinning = false
      @morphTargets = false
      @morphNormals = false
      


      @lights = yes
      @commons = yes


  chunks = {

    lights_npr_pars_vertex:
      """
      uniform vec3 ambient;
      uniform vec3 diffuse;
      uniform vec3 emissive;

      uniform vec3 ambientLightColor;

      #if MAX_DIR_LIGHTS > 0

        uniform vec3 directionalLightColor[ MAX_DIR_LIGHTS ];
        uniform vec3 directionalLightDirection[ MAX_DIR_LIGHTS ];

      #endif

      #if MAX_HEMI_LIGHTS > 0

        uniform vec3 hemisphereLightSkyColor[ MAX_HEMI_LIGHTS ];
        uniform vec3 hemisphereLightGroundColor[ MAX_HEMI_LIGHTS ];
        uniform vec3 hemisphereLightDirection[ MAX_HEMI_LIGHTS ];

      #endif

      #if MAX_POINT_LIGHTS > 0

        uniform vec3 pointLightColor[ MAX_POINT_LIGHTS ];
        uniform vec3 pointLightPosition[ MAX_POINT_LIGHTS ];
        uniform float pointLightDistance[ MAX_POINT_LIGHTS ];

      #endif

      #if MAX_SPOT_LIGHTS > 0

        uniform vec3 spotLightColor[ MAX_SPOT_LIGHTS ];
        uniform vec3 spotLightPosition[ MAX_SPOT_LIGHTS ];
        uniform vec3 spotLightDirection[ MAX_SPOT_LIGHTS ];
        uniform float spotLightDistance[ MAX_SPOT_LIGHTS ];
        uniform float spotLightAngleCos[ MAX_SPOT_LIGHTS ];
        uniform float spotLightExponent[ MAX_SPOT_LIGHTS ];

      #endif

      #ifdef WRAP_AROUND

        uniform vec3 wrapRGB;

      #endif

      #ifdef DSHARPNESS
        uniform float diffuseSharpness;
        uniform float diffuseSharpnessBias;
      #endif

      """


    lights_npr_vertex :
      """
      vLightFront = vec3( 0.0 );

      #ifdef DOUBLE_SIDED

        vLightBack = vec3( 0.0 );

      #endif

      transformedNormal = normalize( transformedNormal );

      #if MAX_DIR_LIGHTS > 0

      for( int i = 0; i < MAX_DIR_LIGHTS; i ++ ) {

        vec4 lDirection = viewMatrix * vec4( directionalLightDirection[ i ], 0.0 );
        vec3 dirVector = normalize( lDirection.xyz );

        float dotProduct = dot( transformedNormal, dirVector );

        #ifdef DSHARPNESS
          dotProduct = (dotProduct / diffuseSharpness) - diffuseSharpnessBias;
          dotProduct = min( dotProduct, 1.0 );
        #endif

        vec3 directionalLightWeighting = vec3( max( dotProduct, 0.0 ) );

        #ifdef DOUBLE_SIDED

          vec3 directionalLightWeightingBack = vec3( max( -dotProduct, 0.0 ) );

          #ifdef WRAP_AROUND

            vec3 directionalLightWeightingHalfBack = vec3( max( -0.5 * dotProduct + 0.5, 0.0 ) );

          #endif

        #endif

        #ifdef WRAP_AROUND

          vec3 directionalLightWeightingHalf = vec3( max( 0.5 * dotProduct + 0.5, 0.0 ) );
          directionalLightWeighting = mix( directionalLightWeighting, directionalLightWeightingHalf, wrapRGB );

          #ifdef DOUBLE_SIDED

            directionalLightWeightingBack = mix( directionalLightWeightingBack, directionalLightWeightingHalfBack, wrapRGB );

          #endif

        #endif

        vLightFront += directionalLightColor[ i ] * directionalLightWeighting;

        #ifdef DOUBLE_SIDED

          vLightBack += directionalLightColor[ i ] * directionalLightWeightingBack;

        #endif

      }

      #endif

      #if MAX_POINT_LIGHTS > 0

        for( int i = 0; i < MAX_POINT_LIGHTS; i ++ ) {

          vec4 lPosition = viewMatrix * vec4( pointLightPosition[ i ], 1.0 );
          vec3 lVector = lPosition.xyz - mvPosition.xyz;

          float lDistance = 1.0;
          if ( pointLightDistance[ i ] > 0.0 )
            lDistance = 1.0 - min( ( length( lVector ) / pointLightDistance[ i ] ), 1.0 );

          lVector = normalize( lVector );
          float dotProduct = dot( transformedNormal, lVector );

          vec3 pointLightWeighting = vec3( max( dotProduct, 0.0 ) );

          #ifdef DOUBLE_SIDED

            vec3 pointLightWeightingBack = vec3( max( -dotProduct, 0.0 ) );

            #ifdef WRAP_AROUND

              vec3 pointLightWeightingHalfBack = vec3( max( -0.5 * dotProduct + 0.5, 0.0 ) );

            #endif

          #endif

          #ifdef WRAP_AROUND

            vec3 pointLightWeightingHalf = vec3( max( 0.5 * dotProduct + 0.5, 0.0 ) );
            pointLightWeighting = mix( pointLightWeighting, pointLightWeightingHalf, wrapRGB );

            #ifdef DOUBLE_SIDED

              pointLightWeightingBack = mix( pointLightWeightingBack, pointLightWeightingHalfBack, wrapRGB );

            #endif

          #endif

          vLightFront += pointLightColor[ i ] * pointLightWeighting * lDistance;

          #ifdef DOUBLE_SIDED

            vLightBack += pointLightColor[ i ] * pointLightWeightingBack * lDistance;

          #endif

        }

      #endif

      #if MAX_SPOT_LIGHTS > 0

        for( int i = 0; i < MAX_SPOT_LIGHTS; i ++ ) {

          vec4 lPosition = viewMatrix * vec4( spotLightPosition[ i ], 1.0 );
          vec3 lVector = lPosition.xyz - mvPosition.xyz;

          float spotEffect = dot( spotLightDirection[ i ], normalize( spotLightPosition[ i ] - worldPosition.xyz ) );

          if ( spotEffect > spotLightAngleCos[ i ] ) {

            spotEffect = max( pow( spotEffect, spotLightExponent[ i ] ), 0.0 );

            float lDistance = 1.0;
            if ( spotLightDistance[ i ] > 0.0 )
              lDistance = 1.0 - min( ( length( lVector ) / spotLightDistance[ i ] ), 1.0 );

            lVector = normalize( lVector );

            float dotProduct = dot( transformedNormal, lVector );
            vec3 spotLightWeighting = vec3( max( dotProduct, 0.0 ) );

            #ifdef DOUBLE_SIDED

              vec3 spotLightWeightingBack = vec3( max( -dotProduct, 0.0 ) );

              #ifdef WRAP_AROUND

                vec3 spotLightWeightingHalfBack = vec3( max( -0.5 * dotProduct + 0.5, 0.0 ) );

              #endif

            #endif

            #ifdef WRAP_AROUND

              vec3 spotLightWeightingHalf = vec3( max( 0.5 * dotProduct + 0.5, 0.0 ) );
              spotLightWeighting = mix( spotLightWeighting, spotLightWeightingHalf, wrapRGB );

              #ifdef DOUBLE_SIDED

                spotLightWeightingBack = mix( spotLightWeightingBack, spotLightWeightingHalfBack, wrapRGB );

              #endif

            #endif

            vLightFront += spotLightColor[ i ] * spotLightWeighting * lDistance * spotEffect;

            #ifdef DOUBLE_SIDED

              vLightBack += spotLightColor[ i ] * spotLightWeightingBack * lDistance * spotEffect;

            #endif

          }

        }

      #endif

      #if MAX_HEMI_LIGHTS > 0

        for( int i = 0; i < MAX_HEMI_LIGHTS; i ++ ) {

          vec4 lDirection = viewMatrix * vec4( hemisphereLightDirection[ i ], 0.0 );
          vec3 lVector = normalize( lDirection.xyz );

          float dotProduct = dot( transformedNormal, lVector );

          float hemiDiffuseWeight = 0.5 * dotProduct + 0.5;
          float hemiDiffuseWeightBack = -0.5 * dotProduct + 0.5;

          vLightFront += mix( hemisphereLightGroundColor[ i ], hemisphereLightSkyColor[ i ], hemiDiffuseWeight );

          #ifdef DOUBLE_SIDED

            vLightBack += mix( hemisphereLightGroundColor[ i ], hemisphereLightSkyColor[ i ], hemiDiffuseWeightBack );

          #endif

        }

      #endif

      vLightFront = vLightFront * diffuse + ambient * ambientLightColor + emissive;

      #ifdef DOUBLE_SIDED

        vLightBack = vLightBack * diffuse + ambient * ambientLightColor + emissive;

      #endif
      """
    }


  SHADER =

    uniforms: THREE.UniformsUtils.merge( [

      THREE.UniformsLib[ "common" ],
      THREE.UniformsLib[ "fog" ],
      THREE.UniformsLib[ "lights" ],
      THREE.UniformsLib[ "shadowmap" ],

      {
        "ambient"  : { type: "c", value: new THREE.Color( 0xffffff ) },
        "emissive" : { type: "c", value: new THREE.Color( 0xff0000 ) },
        "wrapRGB"  : { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) },
        "diffuseSharpness"  : { type: "f", value: .4 },
        "diffuseSharpnessBias"  : { type: "f", value: .3 },
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
      chunks.lights_npr_pars_vertex,
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
        chunks.lights_npr_vertex,
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
