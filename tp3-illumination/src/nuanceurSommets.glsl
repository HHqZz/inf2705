#version 410

/*usefull const */
const int LAMBERT = 0;
const int GOURAUD = 1;
const int PHONG = 2;

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

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;
uniform mat3 matrNormale;

/////////////////////////////////////////////////////////////////

layout(location=0) in vec4 Vertex;
layout(location=2) in vec3 Normal;
layout(location=3) in vec4 Color;
layout(location=8) in vec4 TexCoord;

out Attribs {
    vec4 couleur;
    vec3 normale;

    vec3 directionObserv;
    vec3 directionLight;
    
    vec2 posText;
} AttribsOut;

vec4 calculerReflexion( in vec3 L, in vec3 N, in vec3 O )
{


   /* Calcul des reflexions */
    vec4 reflexAmbi =  FrontMaterial.emission + 
                      FrontMaterial.ambient * LightModel.ambient + 
                      FrontMaterial.ambient * LightSource[0].ambient ; 

    vec4 reflexDiffuse = FrontMaterial.diffuse * LightSource[0].diffuse * max(dot(L,N), 0);
    float k = 0;
    if(utiliseBlinn){
        k = max(0, dot(normalize(L+O),N));
    }
    else{
        k = max(0,dot(reflect(-L,N), O));
   }

   vec4 reflexSpecular = FrontMaterial.specular * LightSource[0].specular * pow(k, FrontMaterial.shininess);

   return clamp(reflexAmbi + reflexDiffuse + reflexSpecular, 0 , 1);
                      
}

void main( void )
{
   // transformation standard du sommet
   gl_Position = matrProj * matrVisu * matrModel * Vertex;

    vec3 N = normalize(matrNormale * Normal),
         L = normalize((matrVisu*LightSource[0].position).xyz - vec3(matrVisu * matrModel * Vertex)),
         O = normalize(-vec3(matrVisu * matrModel * Vertex));

   // couleur du sommet
   if(typeIllumination == GOURAUD){
       AttribsOut.couleur = calculerReflexion(L,N,O);
   }
   else{
       AttribsOut.couleur = Color;
   }
   
   AttribsOut.normale = N;

   AttribsOut.directionLight = L;
   AttribsOut.directionObserv = O;

   AttribsOut.posText = TexCoord.st;

}
