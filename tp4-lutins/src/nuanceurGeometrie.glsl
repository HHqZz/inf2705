#version 410

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

const int nbCoins = 4;
uniform mat4 matrProj;
uniform int texnumero;

in Attribs {
    vec4 couleur;
    float tempsRestant;
    float sens; // du vol
} AttribsIn[];

out Attribs {
    vec4 couleur;
    vec2 texCoord;
} AttribsOut;

void main()
{
    vec2 coins[4];
    coins[0] = vec2( -0.5,  0.5 );
    coins[1] = vec2( -0.5, -0.5 );
    coins[2] = vec2(  0.5,  0.5 );
    coins[3] = vec2(  0.5, -0.5 );
    for ( int i = 0 ; i < nbCoins ; ++i )
    {
        gl_PointSize = 5; // en pixels
        float fact = 0.025 * gl_PointSize;
        vec2 decalage = coins[i]; // on positionne successivement aux quatre coins
        vec4 pos = vec4( gl_in[0].gl_Position.xy + fact * decalage, gl_in[0].gl_Position.zw );

        if (texnumero == 1) {
         float theta = 6*AttribsIn[0].tempsRestant;
         coins[i] = mat2(cos(theta),-sin(theta),sin(theta), cos(theta)) * coins[i];
        }
        coins[i] = coins[i] + vec2(0.5, 0.5);
        if(texnumero == 2) {
            coins[i] =  coins[i]*vec2(AttribsIn[0].sens,1);
        }
        if (texnumero == 2 || texnumero == 3) {
         coins[i] = coins[i] + vec2(floor(mod(18*AttribsIn[0].tempsRestant, 16)), 0);
         coins[i] = coins[i] * vec2(0.0625,1);
        }
        gl_Position = matrProj * pos; // A verifier
        AttribsOut.couleur = AttribsIn[0].couleur;
        AttribsOut.texCoord = coins[i];
        EmitVertex();
    }
}