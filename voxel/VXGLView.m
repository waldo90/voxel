//
//  VXGLView.m
//  voxel
//
//  Created by Pat Smith on 05/02/2013.
//  Copyright (c) 2013 Pat Smith. All rights reserved.
//

#import "VXGLView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
//#import "CC3GLMatrix.h"
#import <GLKit/GLKit.h>

#pragma mark -
#pragma mark vertex data to draw

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

/* Square
const Vertex Vertices[] =
{
    {{ 1,-1, 0}, {1,0,0,1}},
    {{ 1, 1, 0}, {0,1,0,1}},
    {{-1, 1, 0}, {0,0,1,1}},
    {{-1,-1, 0}, {0,0,0,1}}
};
const GLubyte Indices[] =
{
    0,1,2,
    2,3,0
};

*/

/* Cube */
const Vertex Vertices[] =
{
    {{ 1,-1, 1}, {1,0,0,1}},
    {{ 1, 1, 1}, {1,0,0,1}},
    {{-1, 1, 1}, {0.5,0,0.5,1}},
    {{-1,-1, 1}, {0.5,0,0.5,1}},
    {{ 1,-1,-1}, {1,0,0,1}},
    {{ 1, 1,-1}, {1,0,0,1}},
    {{-1, 1,-1}, {1,0,0,1}},
    {{-1,-1,-1}, {1,0,1,1}}

    
};
const GLubyte Indices[] =
{
    0,1,2,
    2,3,0,
    
    4,6,5,
    4,7,6,
    
    2,7,3,
    7,6,2,
    
    0,4,1,
    4,1,5,
    
    6,2,1,
    1,6,5,
    
    0,3,7,
    0,7,4
};


#pragma mark -


@interface VXGLView ()
{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    
    GLuint       _colorRenderBuffer;
    GLuint       _depthRenderBuffer;
    
    GLuint       _positionSlot;
    GLuint       _colorSlot;
    
    GLuint       _projectionUniform;
    GLuint       _modelViewUniform;
    
    float        _currentRotation;
}

@end

@implementation VXGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

#pragma mark -
#pragma mark GL Setup methods

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to init OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupDepthBuffer
{
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}

- (void)setupFrameBuffer
{
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (void)setupVBOs
{
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}

- (void)setupDisplayLink
{
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
#pragma mark -
#pragma mark Render
- (void)render:(CADisplayLink*)displayLink
{
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    // Project matrix

    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    GLKMatrix4 projection = GLKMatrix4MakeFrustum(-2, 2, -h/2, h/2, 4, 10);
    
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.m);
    
    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(sin(CACurrentMediaTime()), 0, -7);
    _currentRotation += displayLink.duration;
    modelView = GLKMatrix4Rotate(modelView, _currentRotation, 1, 1, 0);
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.m);
    
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    
    // Entity rendering
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*)(sizeof(float)*3));
    
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    
    // Present
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark -
#pragma mark Shader compiling

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType
{
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    GLuint shaderHandle = glCreateShader(shaderType);
    const char* shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString* messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    return shaderHandle;
}

- (void)compileShaders
{
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString* messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@",messageString);
        exit(1);
    }
    glUseProgram(programHandle);
    
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
        
}

#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self setupVBOs];
        [self setupDisplayLink];
    }
    return self;
}

@end
