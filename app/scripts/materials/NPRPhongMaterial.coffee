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

  class NPRPhongMaterial extends THREE.ShaderMaterial

    constructor : ->

      super
      THREE.ShaderMaterial.call( this ) # threejs :/

      shader = SHADER

      @defines.DSHARPNESS = yes

      @uniforms        = THREE.UniformsUtils.clone( shader.uniforms )
      @vertexShader    = shader.vertexShader
      @fragmentShader  = shader.fragmentShader


      @color = new THREE.Color( 0xffffff );
      @ambient = new THREE.Color( 0xffffff );
      @emissive = new THREE.Color( 0x202020 );
      @specular = new THREE.Color( 0xFFFFFF );
      @shininess = 30;


      @uniforms.shininess.value = @shininess
      @uniforms.ambient.value = @ambient
      @uniforms.emissive.value = @emissive
      @uniforms.specular.value = @specular

      @metal = false;
      @perPixel = true;
    
      @wrapAround = false;
      @wrapRGB = new THREE.Vector3( 1, 1, 1 );
    
      @map = null;
    
      @lightMap = null;
    
      @bumpMap = null;
      @bumpScale = 1;
    
      @normalMap = null;
      @normalScale = new THREE.Vector2( 1, 1 );
    
      @specularMap = null;
    
      @envMap = null;
      @combine = THREE.MultiplyOperation;
      @reflectivity = 1;
      @refractionRatio = 0.98;
    
      @fog = true;
    
      @shading = THREE.SmoothShading;
    
      @wireframe = false;
      @wireframeLinewidth = 1;
      @wireframeLinecap = 'round';
      @wireframeLinejoin = 'round';
    
      @vertexColors = THREE.NoColors;
    
      @skinning = false;
      @morphTargets = false;
      @morphNormals = false;
      


      @lights = yes
      @commons = yes


  chunks = {

    lights_npr_pars_vertex:
      """
      #ifndef PHONG_PER_PIXEL 

      #if MAX_POINT_LIGHTS > 0 

        uniform vec3 pointLightPosition[ MAX_POINT_LIGHTS ]; 
        uniform float pointLightDistance[ MAX_POINT_LIGHTS ]; 

        varying vec4 vPointLight[ MAX_POINT_LIGHTS ]; 

      #endif 

      #if MAX_SPOT_LIGHTS > 0 

        uniform vec3 spotLightPosition[ MAX_SPOT_LIGHTS ]; 
        uniform float spotLightDistance[ MAX_SPOT_LIGHTS ]; 

        varying vec4 vSpotLight[ MAX_SPOT_LIGHTS ]; 

      #endif 

      #endif 

      #if MAX_SPOT_LIGHTS > 0 || defined( USE_BUMPMAP ) 

        varying vec3 vWorldPosition; 

      #endif
      """


    lights_npr_vertex:
      """
      #ifndef PHONG_PER_PIXEL

      #if MAX_POINT_LIGHTS > 0

        for( int i = 0; i < MAX_POINT_LIGHTS; i ++ ) {

          vec4 lPosition = viewMatrix * vec4( pointLightPosition[ i ], 1.0 );
          vec3 lVector = lPosition.xyz - mvPosition.xyz;

          float lDistance = 1.0;
          if ( pointLightDistance[ i ] > 0.0 )
            lDistance = 1.0 - min( ( length( lVector ) / pointLightDistance[ i ] ), 1.0 );

          vPointLight[ i ] = vec4( lVector, lDistance );

        }

      #endif

      #if MAX_SPOT_LIGHTS > 0

        for( int i = 0; i < MAX_SPOT_LIGHTS; i ++ ) {

          vec4 lPosition = viewMatrix * vec4( spotLightPosition[ i ], 1.0 );
          vec3 lVector = lPosition.xyz - mvPosition.xyz;

          float lDistance = 1.0;
          if ( spotLightDistance[ i ] > 0.0 )
            lDistance = 1.0 - min( ( length( lVector ) / spotLightDistance[ i ] ), 1.0 );

          vSpotLight[ i ] = vec4( lVector, lDistance );

        }

      #endif

      #endif

      #if MAX_SPOT_LIGHTS > 0 || defined( USE_BUMPMAP )

        vWorldPosition = worldPosition.xyz;

      #endif
      """

    lights_npr_pars_fragment: [

      "uniform vec3 ambientLightColor;",

      "#if MAX_DIR_LIGHTS > 0",

        "uniform vec3 directionalLightColor[ MAX_DIR_LIGHTS ];",
        "uniform vec3 directionalLightDirection[ MAX_DIR_LIGHTS ];",

      "#endif",

      "#if MAX_HEMI_LIGHTS > 0",

        "uniform vec3 hemisphereLightSkyColor[ MAX_HEMI_LIGHTS ];",
        "uniform vec3 hemisphereLightGroundColor[ MAX_HEMI_LIGHTS ];",
        "uniform vec3 hemisphereLightDirection[ MAX_HEMI_LIGHTS ];",

      "#endif",

      "#if MAX_POINT_LIGHTS > 0",

        "uniform vec3 pointLightColor[ MAX_POINT_LIGHTS ];",

        "#ifdef PHONG_PER_PIXEL",

          "uniform vec3 pointLightPosition[ MAX_POINT_LIGHTS ];",
          "uniform float pointLightDistance[ MAX_POINT_LIGHTS ];",

        "#else",

          "varying vec4 vPointLight[ MAX_POINT_LIGHTS ];",

        "#endif",

      "#endif",

      "#if MAX_SPOT_LIGHTS > 0",

        "uniform vec3 spotLightColor[ MAX_SPOT_LIGHTS ];",
        "uniform vec3 spotLightPosition[ MAX_SPOT_LIGHTS ];",
        "uniform vec3 spotLightDirection[ MAX_SPOT_LIGHTS ];",
        "uniform float spotLightAngleCos[ MAX_SPOT_LIGHTS ];",
        "uniform float spotLightExponent[ MAX_SPOT_LIGHTS ];",

        "#ifdef PHONG_PER_PIXEL",

          "uniform float spotLightDistance[ MAX_SPOT_LIGHTS ];",

        "#else",

          "varying vec4 vSpotLight[ MAX_SPOT_LIGHTS ];",

        "#endif",

      "#endif",

      "#if MAX_SPOT_LIGHTS > 0 || defined( USE_BUMPMAP )",

        "varying vec3 vWorldPosition;",

      "#endif",

      "#ifdef WRAP_AROUND",

        "uniform vec3 wrapRGB;",

      "#endif",

      "#ifdef DSHARPNESS",
        "uniform float diffuseSharpness;",
        "uniform float diffuseSharpnessBias;",
      "#endif",

      "varying vec3 vViewPosition;",
      "varying vec3 vNormal;"

    ].join("\n"),

    lights_npr_fragment: [

      "vec3 normal = normalize( vNormal );",
      "vec3 viewPosition = normalize( vViewPosition );",

      "#ifdef DOUBLE_SIDED",

        "normal = normal * ( -1.0 + 2.0 * float( gl_FrontFacing ) );",

      "#endif",

      "#ifdef USE_NORMALMAP",

        "normal = perturbNormal2Arb( -vViewPosition, normal );",

      "#elif defined( USE_BUMPMAP )",

        "normal = perturbNormalArb( -vViewPosition, normal, dHdxy_fwd() );",

      "#endif",

      "#if MAX_POINT_LIGHTS > 0",

        "vec3 pointDiffuse  = vec3( 0.0 );",
        "vec3 pointSpecular = vec3( 0.0 );",

        "for ( int i = 0; i < MAX_POINT_LIGHTS; i ++ ) {",

          "#ifdef PHONG_PER_PIXEL",

            "vec4 lPosition = viewMatrix * vec4( pointLightPosition[ i ], 1.0 );",
            "vec3 lVector = lPosition.xyz + vViewPosition.xyz;",

            "float lDistance = 1.0;",
            "if ( pointLightDistance[ i ] > 0.0 )",
              "lDistance = 1.0 - min( ( length( lVector ) / pointLightDistance[ i ] ), 1.0 );",

            "lVector = normalize( lVector );",

          "#else",

            "vec3 lVector = normalize( vPointLight[ i ].xyz );",
            "float lDistance = vPointLight[ i ].w;",

          "#endif",


          "float dotProduct = dot( normal, lVector );",

          "#ifdef WRAP_AROUND",

            "float pointDiffuseWeightFull = max( dotProduct, 0.0 );",
            "float pointDiffuseWeightHalf = max( 0.5 * dotProduct + 0.5, 0.0 );",

            "vec3 pointDiffuseWeight = mix( vec3 ( pointDiffuseWeightFull ), vec3( pointDiffuseWeightHalf ), wrapRGB );",

          "#else",

            "float pointDiffuseWeight = max( dotProduct, 0.0 );",

          "#endif",

          "pointDiffuse  += diffuse * pointLightColor[ i ] * pointDiffuseWeight * lDistance;",


          "vec3 pointHalfVector = normalize( lVector + viewPosition );",
          "float pointDotNormalHalf = max( dot( normal, pointHalfVector ), 0.0 );",
          "float pointSpecularWeight = specularStrength * max( pow( pointDotNormalHalf, shininess ), 0.0 );",

          "#ifdef PHYSICALLY_BASED_SHADING",


            "float specularNormalization = ( shininess + 2.0001 ) / 8.0;",

            "vec3 schlick = specular + vec3( 1.0 - specular ) * pow( 1.0 - dot( lVector, pointHalfVector ), 5.0 );",
            "pointSpecular += schlick * pointLightColor[ i ] * pointSpecularWeight * pointDiffuseWeight * lDistance * specularNormalization;",

          "#else",

            "pointSpecular += specular * pointLightColor[ i ] * pointSpecularWeight * pointDiffuseWeight * lDistance;",

          "#endif",

        "}",

      "#endif",

      "#if MAX_SPOT_LIGHTS > 0",

        "vec3 spotDiffuse  = vec3( 0.0 );",
        "vec3 spotSpecular = vec3( 0.0 );",

        "for ( int i = 0; i < MAX_SPOT_LIGHTS; i ++ ) {",

          "#ifdef PHONG_PER_PIXEL",

            "vec4 lPosition = viewMatrix * vec4( spotLightPosition[ i ], 1.0 );",
            "vec3 lVector = lPosition.xyz + vViewPosition.xyz;",

            "float lDistance = 1.0;",
            "if ( spotLightDistance[ i ] > 0.0 )",
              "lDistance = 1.0 - min( ( length( lVector ) / spotLightDistance[ i ] ), 1.0 );",

            "lVector = normalize( lVector );",

          "#else",

            "vec3 lVector = normalize( vSpotLight[ i ].xyz );",
            "float lDistance = vSpotLight[ i ].w;",

          "#endif",

          "float spotEffect = dot( spotLightDirection[ i ], normalize( spotLightPosition[ i ] - vWorldPosition ) );",

          "if ( spotEffect > spotLightAngleCos[ i ] ) {",

            "spotEffect = max( pow( spotEffect, spotLightExponent[ i ] ), 0.0 );",


            "float dotProduct = dot( normal, lVector );",

            "#ifdef WRAP_AROUND",

              "float spotDiffuseWeightFull = max( dotProduct, 0.0 );",
              "float spotDiffuseWeightHalf = max( 0.5 * dotProduct + 0.5, 0.0 );",

              "vec3 spotDiffuseWeight = mix( vec3 ( spotDiffuseWeightFull ), vec3( spotDiffuseWeightHalf ), wrapRGB );",

            "#else",

              "float spotDiffuseWeight = max( dotProduct, 0.0 );",

            "#endif",

            "spotDiffuse += diffuse * spotLightColor[ i ] * spotDiffuseWeight * lDistance * spotEffect;",


            "vec3 spotHalfVector = normalize( lVector + viewPosition );",
            "float spotDotNormalHalf = max( dot( normal, spotHalfVector ), 0.0 );",
            "float spotSpecularWeight = specularStrength * max( pow( spotDotNormalHalf, shininess ), 0.0 );",

            "#ifdef PHYSICALLY_BASED_SHADING",


              "float specularNormalization = ( shininess + 2.0001 ) / 8.0;",

              "vec3 schlick = specular + vec3( 1.0 - specular ) * pow( 1.0 - dot( lVector, spotHalfVector ), 5.0 );",
              "spotSpecular += schlick * spotLightColor[ i ] * spotSpecularWeight * spotDiffuseWeight * lDistance * specularNormalization * spotEffect;",

            "#else",

              "spotSpecular += specular * spotLightColor[ i ] * spotSpecularWeight * spotDiffuseWeight * lDistance * spotEffect;",

            "#endif",

          "}",

        "}",

      "#endif",

      "#if MAX_DIR_LIGHTS > 0",

        "vec3 dirDiffuse  = vec3( 0.0 );",
        "vec3 dirSpecular = vec3( 0.0 );" ,

        "for( int i = 0; i < MAX_DIR_LIGHTS; i ++ ) {",

          "vec4 lDirection = viewMatrix * vec4( directionalLightDirection[ i ], 0.0 );",
          "vec3 dirVector = normalize( lDirection.xyz );",


          "float dotProduct = dot( normal, dirVector );",
          "#ifdef DSHARPNESS",
            "dotProduct = (dotProduct / diffuseSharpness) - diffuseSharpnessBias;",
            "dotProduct = min( dotProduct, 1.0 );",
          "#endif",

          "#ifdef WRAP_AROUND",

            "float dirDiffuseWeightFull = max( dotProduct, 0.0 );",
            "float dirDiffuseWeightHalf = max( 0.5 * dotProduct + 0.5, 0.0 );",

            "vec3 dirDiffuseWeight = mix( vec3( dirDiffuseWeightFull ), vec3( dirDiffuseWeightHalf ), wrapRGB );",

          "#else",

            "float dirDiffuseWeight = max( dotProduct, 0.0 );",

          "#endif",

          "dirDiffuse  += diffuse * directionalLightColor[ i ] * dirDiffuseWeight;",


          "vec3 dirHalfVector = normalize( dirVector + viewPosition );",

          "float dirDotNormalHalf;",

          "#ifdef DSHARPNESS",
            "dirDotNormalHalf = dot( normal, dirHalfVector );",
            "dirDotNormalHalf = (dirDotNormalHalf / .98);",
            "dirDotNormalHalf = max( 0.0, min( dirDotNormalHalf, 1.0 ) );",

          "#else",

            "dirDotNormalHalf = max( dot( normal, dirHalfVector ), 0.0 );",
          "#endif",


          "float dirSpecularWeight = specularStrength * max( pow( dirDotNormalHalf, shininess ), 0.0 );",

          "#ifdef PHYSICALLY_BASED_SHADING",



            "float specularNormalization = ( shininess + 2.0001 ) / 8.0;",


            "vec3 schlick = specular + vec3( 1.0 - specular ) * pow( 1.0 - dot( dirVector, dirHalfVector ), 5.0 );",
            "dirSpecular += schlick * directionalLightColor[ i ] * dirSpecularWeight * dirDiffuseWeight * specularNormalization;",

          "#else",

            "dirSpecular += specular * directionalLightColor[ i ] * dirSpecularWeight * dirDiffuseWeight;",

          "#endif",

        "}",

      "#endif",

      "#if MAX_HEMI_LIGHTS > 0",

        "vec3 hemiDiffuse  = vec3( 0.0 );",
        "vec3 hemiSpecular = vec3( 0.0 );" ,

        "for( int i = 0; i < MAX_HEMI_LIGHTS; i ++ ) {",

          "vec4 lDirection = viewMatrix * vec4( hemisphereLightDirection[ i ], 0.0 );",
          "vec3 lVector = normalize( lDirection.xyz );",


          "float dotProduct = dot( normal, lVector );",
          "float hemiDiffuseWeight = 0.5 * dotProduct + 0.5;",

          "vec3 hemiColor = mix( hemisphereLightGroundColor[ i ], hemisphereLightSkyColor[ i ], hemiDiffuseWeight );",

          "hemiDiffuse += diffuse * hemiColor;",


          "vec3 hemiHalfVectorSky = normalize( lVector + viewPosition );",
          "float hemiDotNormalHalfSky = 0.5 * dot( normal, hemiHalfVectorSky ) + 0.5;",
          "float hemiSpecularWeightSky = specularStrength * max( pow( hemiDotNormalHalfSky, shininess ), 0.0 );",


          "vec3 lVectorGround = -lVector;",

          "vec3 hemiHalfVectorGround = normalize( lVectorGround + viewPosition );",
          "float hemiDotNormalHalfGround = 0.5 * dot( normal, hemiHalfVectorGround ) + 0.5;",
          "float hemiSpecularWeightGround = specularStrength * max( pow( hemiDotNormalHalfGround, shininess ), 0.0 );",

          "#ifdef PHYSICALLY_BASED_SHADING",

            "float dotProductGround = dot( normal, lVectorGround );",


            "float specularNormalization = ( shininess + 2.0001 ) / 8.0;",

            "vec3 schlickSky = specular + vec3( 1.0 - specular ) * pow( 1.0 - dot( lVector, hemiHalfVectorSky ), 5.0 );",
            "vec3 schlickGround = specular + vec3( 1.0 - specular ) * pow( 1.0 - dot( lVectorGround, hemiHalfVectorGround ), 5.0 );",
            "hemiSpecular += hemiColor * specularNormalization * ( schlickSky * hemiSpecularWeightSky * max( dotProduct, 0.0 ) + schlickGround * hemiSpecularWeightGround * max( dotProductGround, 0.0 ) );",

          "#else",

            "hemiSpecular += specular * hemiColor * ( hemiSpecularWeightSky + hemiSpecularWeightGround ) * hemiDiffuseWeight;",

          "#endif",

        "}",

      "#endif",

      "vec3 totalDiffuse = vec3( 0.0 );",
      "vec3 totalSpecular = vec3( 0.0 );",

      "#if MAX_DIR_LIGHTS > 0",

        "totalDiffuse += dirDiffuse;",
        "totalSpecular += dirSpecular;",

      "#endif",

      "#if MAX_HEMI_LIGHTS > 0",

        "totalDiffuse += hemiDiffuse;",
        "totalSpecular += hemiSpecular;",

      "#endif",

      "#if MAX_POINT_LIGHTS > 0",

        "totalDiffuse += pointDiffuse;",
        "totalSpecular += pointSpecular;",

      "#endif",

      "#if MAX_SPOT_LIGHTS > 0",

        "totalDiffuse += spotDiffuse;",
        "totalSpecular += spotSpecular;",

      "#endif",

      "#ifdef METAL",

        "gl_FragColor.xyz = gl_FragColor.xyz * ( emissive + totalDiffuse + ambientLightColor * ambient + totalSpecular );",

      "#else",

        "gl_FragColor.xyz = gl_FragColor.xyz * ( emissive + totalDiffuse + ambientLightColor * ambient ) + totalSpecular;",

      "#endif"

    ].join("\n"),

    nbump_uniforms :

      nbump  : { type: "f", value: 1 },
      nbumpFreq  : { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) },
      nbumpPhase  : { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) },

    nbump_pars_vertex :
      """
      uniform float nbump;
      uniform vec3 nbumpFreq;
      uniform vec3 nbumpPhase;
      """

    nbump_coses :
      """
      vec3 coses = cos( position.xyz * nbumpFreq + nbumpPhase );
      """
    
    nbumb_normal: 
      """
      vec3 objectNormal;
  
      #ifdef USE_SKINNING
        objectNormal = skinnedNormal.xyz;
      #endif
  
      #if !defined( USE_SKINNING ) && defined( USE_MORPHNORMALS )
        objectNormal = morphedNormal;
      #endif
  
      #if !defined( USE_SKINNING ) && ! defined( USE_MORPHNORMALS )
        objectNormal = normal;
      #endif
  
      #ifdef FLIP_SIDED
        objectNormal = -objectNormal;
      #endif

      objectNormal = objectNormal + coses * .1;
  
      vec3 transformedNormal = normalMatrix * objectNormal;
      """

    nbump_vertex :
      """
      vec4 mvPosition;

      #ifdef USE_SKINNING
        mvPosition = modelViewMatrix * skinned;
      #endif

      #if !defined( USE_SKINNING ) && defined( USE_MORPHTARGETS )
        mvPosition = modelViewMatrix * vec4( morphed, 1.0 );
      #endif

      #if !defined( USE_SKINNING ) && ! defined( USE_MORPHTARGETS )
        mvPosition = modelViewMatrix * vec4( position, 1.0 );
      #endif

      mvPosition.xyz = mvPosition.xyz + (( coses.x + coses.y + coses.z ) * nbump * dot(mvPosition, projectionMatrix[3]) ) * objectNormal.xyz;

      gl_Position = projectionMatrix * mvPosition;
      """
  }

  SHADER =

    uniforms: THREE.UniformsUtils.merge( [

      THREE.UniformsLib[ "common" ],
      THREE.UniformsLib[ "bump" ],
      THREE.UniformsLib[ "normalmap" ],
      THREE.UniformsLib[ "fog" ],
      THREE.UniformsLib[ "lights" ],
      THREE.UniformsLib[ "shadowmap" ],
      chunks[ "nbump_uniforms" ],

      {
        "ambient"  : { type: "c", value: new THREE.Color( 0xffffff ) },
        "emissive" : { type: "c", value: new THREE.Color( 0x000000 ) },
        "specular" : { type: "c", value: new THREE.Color( 0x111111 ) },
        "shininess": { type: "f", value: 30 },
        "wrapRGB"  : { type: "v3", value: new THREE.Vector3( 1, 1, 1 ) },
        "diffuseSharpness"  : { type: "f", value: .4 },
        "diffuseSharpnessBias"  : { type: "f", value: .3 },
      }

    ] ),

    vertexShader: [

      "#define PHONG",

      "varying vec3 vViewPosition;",
      "varying vec3 vNormal;",

      THREE.ShaderChunk[ "map_pars_vertex" ],
      THREE.ShaderChunk[ "lightmap_pars_vertex" ],
      THREE.ShaderChunk[ "envmap_pars_vertex" ],
      chunks[ "lights_npr_pars_vertex" ],
      THREE.ShaderChunk[ "color_pars_vertex" ],
      THREE.ShaderChunk[ "morphtarget_pars_vertex" ],
      THREE.ShaderChunk[ "skinning_pars_vertex" ],
      THREE.ShaderChunk[ "shadowmap_pars_vertex" ],
      chunks.nbump_pars_vertex,

      "void main() {",

        chunks.nbump_coses,
        THREE.ShaderChunk[ "map_vertex" ],
        THREE.ShaderChunk[ "lightmap_vertex" ],
        THREE.ShaderChunk[ "color_vertex" ],

        THREE.ShaderChunk[ "morphnormal_vertex" ],
        THREE.ShaderChunk[ "skinbase_vertex" ],
        THREE.ShaderChunk[ "skinnormal_vertex" ],
        chunks.nbumb_normal,

        "vNormal = normalize( transformedNormal );",

        THREE.ShaderChunk[ "morphtarget_vertex" ],
        THREE.ShaderChunk[ "skinning_vertex" ],
        chunks.nbump_vertex,

        "vViewPosition = -mvPosition.xyz;",

        THREE.ShaderChunk[ "worldpos_vertex" ],
        THREE.ShaderChunk[ "envmap_vertex" ],
        chunks[ "lights_npr_vertex" ],
        THREE.ShaderChunk[ "shadowmap_vertex" ],

      "}"

    ].join("\n"),

    fragmentShader: [

      "uniform vec3 diffuse;",
      "uniform float opacity;",

      "uniform vec3 ambient;",
      "uniform vec3 emissive;",
      "uniform vec3 specular;",
      "uniform float shininess;",

      THREE.ShaderChunk[ "color_pars_fragment" ],
      THREE.ShaderChunk[ "map_pars_fragment" ],
      THREE.ShaderChunk[ "lightmap_pars_fragment" ],
      THREE.ShaderChunk[ "envmap_pars_fragment" ],
      THREE.ShaderChunk[ "fog_pars_fragment" ],
      chunks[ "lights_npr_pars_fragment" ],
      THREE.ShaderChunk[ "shadowmap_pars_fragment" ],
      THREE.ShaderChunk[ "bumpmap_pars_fragment" ],
      THREE.ShaderChunk[ "normalmap_pars_fragment" ],
      THREE.ShaderChunk[ "specularmap_pars_fragment" ],

      "void main() {",

        "gl_FragColor = vec4( vec3 ( 1.0 ), opacity );",

        THREE.ShaderChunk[ "map_fragment" ],
        THREE.ShaderChunk[ "alphatest_fragment" ],
        THREE.ShaderChunk[ "specularmap_fragment" ],

        chunks[ "lights_npr_fragment" ],

        THREE.ShaderChunk[ "lightmap_fragment" ],
        THREE.ShaderChunk[ "color_fragment" ],
        THREE.ShaderChunk[ "envmap_fragment" ],
        THREE.ShaderChunk[ "shadowmap_fragment" ],

        THREE.ShaderChunk[ "linear_to_gamma_fragment" ],

        THREE.ShaderChunk[ "fog_fragment" ],

      "}"

    ].join("\n")
  
  
  NPRPhongMaterial
