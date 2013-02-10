/*
** SimpleVertex
** Created by Pat Smith on 05/02/2013.
*/

attribute vec4 Position;
attribute vec3 Normal;

/* attribute vec4 SourceColor; */
uniform vec4 SourceColor;

varying vec4 DestinationColor;

uniform mat4 Projection;
uniform mat4 Modelview;
uniform mat3 NormalMatrix;

void main(void) 
{
    vec3 eyeNormal = normalize(NormalMatrix * Normal);
    vec3 lightPosition = vec3(0.0, 0.0, 1.0);
    /* vec4 diffuseColor = vec4(0.4, 0.4, 1.0, 1.0); */
    
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
                 
    /* colorVarying = diffuseColor * nDotVP; */

    DestinationColor = SourceColor * nDotVP;
    gl_Position = Projection * Modelview * Position;
}

