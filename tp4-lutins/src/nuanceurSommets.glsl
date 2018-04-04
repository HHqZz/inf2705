#version 410

uniform mat4 matrModel;
uniform mat4 matrVisu;

layout(location=0) in vec4 Vertex;
layout(location=3) in vec4 Color;
in float tempsRestant;
in vec3 vitesse;

out Attribs {
   vec4 couleur;
   float tempsRestant;
   float sens; // du vol
} AttribsOut;

void main( void )
{
    // transformation standard du sommet
    // termine dans le nuanceur de geometrie
    gl_Position = matrVisu * matrModel * Vertex;
    AttribsOut.tempsRestant = tempsRestant;
    AttribsOut.sens = sign(vitesse.x);
    // couleur du sommet
    AttribsOut.couleur = Color;
}
