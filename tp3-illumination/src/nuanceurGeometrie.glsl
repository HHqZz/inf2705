#version 410

/* usefull const */
const int LAMBERT = 0;
const int GOURAUD = 1;
const int PHONG = 2;


layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

uniform mat4 matrModel;
uniform mat4 matrVisu;
uniform mat4 matrProj;

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

in Attribs {
   vec4 couleur;
   vec3 normale;

   vec3 directionObserv;
   vec3 directionLight;

   vec2 posText;
} AttribsIn[];

out Attribs {
    vec4 couleur;
    vec3 normale;

    vec3 directionObserv;
    vec3 directionLight;

    vec2 posText;

} AttribsOut;

void main()
{
   // émettre les sommets
   for ( int i = 0 ; i < gl_in.length() ; ++i )
   {
      gl_Position = gl_in[i].gl_Position;
      AttribsOut.couleur = AttribsIn[i].couleur;
      
    if(typeIllumination == LAMBERT){
        vec3 vecPos1 = vec3(gl_in[1].gl_Position-gl_in[0].gl_Position);
        vec3 vecPos2 = vec3(gl_in[2].gl_Position-gl_in[0].gl_Position);
        // calculate the cross product of two vectors
        vec3 N = normalize(cross(vecPos1, vecPos2)); 

        AttribsOut.normale = N;
        AttribsOut.directionObserv = AttribsIn[i].directionObserv;
    }
    else {
        AttribsOut.normale = AttribsIn[i].normale;
        AttribsOut.directionObserv = AttribsIn[i].directionObserv;
    }

    AttribsOut.directionLight = AttribsIn[i].directionLight;
    AttribsOut.posText = AttribsIn[i].posText;

      EmitVertex();
   }
}
