#version 410

/* usefull const */
const float PI = 3.1415926535897932384626433832795;
const int GOURAUD = 1 ;
const int LAMBERT = 0 ;
const int PHONG = 2 ;
// Définition des paramètres des sources de lumière
layout (std140) uniform LightSourceParameters
{
   vec4 ambient;
   vec4 diffuse;
   vec4 specular;
   vec4 position;      // dans le repère du monde
   vec3 spotDirection; // dans le repère du monde
   float spotExponent;
   float spotAngleOuverture; // ([0.0,90.0] ou 180.0)
   float constantAttenuation;
   float linearAttenuation;
   float quadraticAttenuation;
} LightSource[1];

// Définition des paramètres des matériaux
layout (std140) uniform MaterialParameters
{
   vec4 emission;
   vec4 ambient;
   vec4 diffuse;
   vec4 specular;
   float shininess;
} FrontMaterial;

// Définition des paramètres globaux du modèle de lumière
layout (std140) uniform LightModelParameters
{
   vec4 ambient;       // couleur ambiante
   bool localViewer;   // observateur local ou à l'infini?
   bool twoSide;       // éclairage sur les deux côtés ou un seul?
} LightModel;

layout (std140) uniform varsUnif
{
   // partie 1: illumination
   int typeIllumination;     // 0:Lambert, 1:Gouraud, 2:Phong
   bool utiliseBlinn;        // indique si on veut utiliser modèle spéculaire de Blinn ou Phong
   bool utiliseDirect;       // indique si on utilise un spot style Direct3D ou OpenGL
   bool afficheNormales;     // indique si on utilise les normales comme couleurs (utile pour le débogage)
   // partie 3: texture
   int texnumero;            // numéro de la texture appliquée
   bool utiliseCouleur;      // doit-on utiliser la couleur de base de l'objet en plus de celle de la texture?
   int afficheTexelFonce;    // un texel noir doit-il être affiché 0:noir, 1:mi-coloré, 2:transparent?
};

uniform sampler2D laTexture;

/////////////////////////////////////////////////////////////////

in Attribs {
   vec4 couleur;
   vec4 IntensiteGouraud;


   vec3 directionLumiere;
   vec3 directionObserv;

   vec3 normales;
   vec3 faceNormale;

   vec2 posTexture;

} AttribsIn;

out vec4 FragColor;

float calculerSpot( in vec3 spotDir, in vec3 L )
{
    spotDir = normalize(spotDir);
    L = normalize(L);

    float gamma = dot(spotDir, -L);
    float inner=cos(LightSource[0].spotAngleOuverture * PI/180 );
    float outter = pow(inner, 1.01 + LightSource[0].spotExponent / 2);

    // Direct 3D
    if(utiliseDirect){
        return smoothstep(outter, inner,gamma);
    }
    
    if(inner<=gamma){
        return pow(gamma, LightSource[0].spotExponent/2);

    }
    return 0;
}

vec4 calculerReflexion( in vec3 L, in vec3 N, in vec3 O )
{
    /* Calcul reflexion Ambiante */
    vec4 reflAmbiante = FrontMaterial.emission + 
                        FrontMaterial.ambient*LightModel.ambient  +
                        FrontMaterial.ambient*LightSource[0].ambient ;

    /* Calcul reflexion Diffuse */
    vec4 reflDiffuse =  FrontMaterial.diffuse *
                        LightSource[0].diffuse *
                        max(dot(L,N),0);

    /* Calcul reflexion Speculaire */
    vec4 reflSpeculaire;
    if(utiliseBlinn){
        float k = max(0, dot(normalize(L+O), N));
    }
    else {
        float k = max(0, dot(reflect(-L, N), O));
    }
    
    reflSpeculaire = FrontMaterial.specular *
                     LightSource[0].specular *
                     pow(k,FrontMaterial.shininess);

    return clamp(reflAmbiante + reflDiffuse + reflSpeculaire, 0, 1);
}

void main( void )
{
    vec4 texture = texture(laTexture, AttribsIn.posTexture);
    
    if(typeIllumination == PHONG || typeIllumination == LAMBERT ||){
        FragColor = calculerReflexion(normalize(AttribsIn.directionLumiere), 
                    normalize(AttribsIn.normales), normalize(AttribsIn.directionObserv));
    }

    else {
        FragColor = AttribsIn.couleur;
    }

    if(texnumero){
        if(afficheTexelFonce ==1 ){
            FragColor = FragColor *(texture+1)/2;
        }
        else if (afficheTexelFonce ==2 && ((texture.r + texture.g + texture.b) / 3.0) < 0.1){
            discard //shouldn't write any pixel
        }
        else {
            FragColor = FragColor * texture ;
        }
    } 
  if ( afficheNormales ) {
      FragColor = vec4(normalize(AttribsIn.normale),1.0);
   } else {
      uniform mat3 matrVisu;
      FragColor *= calculerSpot(transpose(inverse(matrVisu)) * LightSource[0].spotDirection, normalize(AttribsIn.directionLumiere));
   }

}
