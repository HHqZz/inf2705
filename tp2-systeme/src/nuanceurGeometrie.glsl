
#version 410

layout(triangles) in;
layout(triangle_strip, max_vertices = 8) out;

// in gl_PerVertex // <-- déclaration implicite
// {
//   vec4 gl_Position;
//   float gl_PointSize;
//   float gl_ClipDistance[];
// } gl_in[];

// out gl_PerVertex // <-- déclaration implicite
// {
//   vec4 gl_Position;
//   float gl_PointSize;
//   float gl_ClipDistance[];
// };
// out int gl_Layer;
// out int gl_ViewportIndex; // si GL 4.1 ou ARB_viewport_array.

in Attribs {
   vec4 couleurAvant;
   vec4 couleurArriere;
} AttribsIn[];

out Attribs {
   vec4 couleurAvant;
   vec4 couleurArriere;
} AttribsOut;

void main()
{
   // calculer le centre
   vec4 centre = vec4(0.0);
   for ( int i = 0 ; i < gl_in.length() ; ++i )
      centre += gl_in[i].gl_Position;
   centre /= gl_in.length();

   // émettre les sommets
   for ( int i = 0 ; i < gl_in.length() ; ++i )
   {
      gl_ViewportIndex = 0;
      gl_Position = gl_in[i].gl_Position;
      // Modifier un peu la valeur qu'on vient de calculer
      //gl_Position.xy = 0.3 * gl_Position.xy;
      //gl_Position.xyz = 0.3 * gl_Position.xyz;
      //gl_Position.xyzw = 0.3 * gl_Position.xyzw;
      //gl_Position.w = 3.0 * gl_Position.w;
      //gl_Position -= 0.1 * ( gl_in[i].gl_Position - centre );
      //gl_Position = mix( gl_in[i].gl_Position, centre, 0.1 );
      AttribsOut.couleurAvant = AttribsIn[i].couleurAvant;
      AttribsOut.couleurArriere = AttribsIn[i].couleurArriere;
      EmitVertex();
   }
   EndPrimitive();

   for ( int i = 0 ; i < gl_in.length() ; ++i )
   {
      gl_ViewportIndex = 1;
      gl_Position = gl_in[i].gl_Position;
      AttribsOut.couleurAvant = AttribsIn[i].couleurArriere;
      AttribsOut.couleurArriere = AttribsIn[i].couleurAvant;
      EmitVertex();
   }
   EndPrimitive();
}

