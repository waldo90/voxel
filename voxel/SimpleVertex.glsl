/*
** SimpleVertex
** Created by Pat Smith on 05/02/2013.
*/

attribute vec4 Position;
attribute vec4 SourceColor;

varying vec4 DestinationColor;

uniform mat4 Projection;

void main(void) 
{
    DestinationColor = SourceColor;
    gl_Position = Projection * Position;
}

