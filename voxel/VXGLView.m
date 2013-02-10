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
#import <GLKit/GLKit.h>
#import "VXBox.h"

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

#define VOX_ARRAY_SIZE 10


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
    
    VXBox* box;
    GLubyte*     _voxels[VOX_ARRAY_SIZE][VOX_ARRAY_SIZE][VOX_ARRAY_SIZE];

    float        _pan_x;
    float        _pan_y;
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
    box = [[VXBox alloc] init];
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, [box.vbo.buffer length], [box vertexData], GL_STATIC_DRAW);
    
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
    glClearColor(100/255.0, 150.0/255.0, 100.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);

    // Connect program vars
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(InterleavingVertexData), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(InterleavingVertexData), (GLvoid*)(sizeof(GLKVector3)+4));
    
    // Projection matrix
    float aspect = fabsf(self.bounds.size.width / self.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);

    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -30.0);
    
    glUniformMatrix4fv(_projectionUniform, 1, 0, GLKMatrix4Multiply(projectionMatrix, baseModelViewMatrix).m);
    
    // Model view matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(-12.5, -12.5, 12.5);
    GLKMatrix4 rotationMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(_pan_x), 0, 1, 0);
    rotationMatrix = GLKMatrix4Rotate(rotationMatrix, GLKMathDegreesToRadians(_pan_y), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Multiply(rotationMatrix, modelViewMatrix);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    GLKMatrix4 voxelView;
    for (int i=0; i < VOX_ARRAY_SIZE; i++) {
        for (int j=0; j < VOX_ARRAY_SIZE; j++) {
            for (int k=0; k < VOX_ARRAY_SIZE; k++) {
                if (_voxels[i][j][k]) {
                    voxelView = GLKMatrix4Translate(modelViewMatrix, i*2.5, j*2.5, -k*2.5);
                    glUniformMatrix4fv(_modelViewUniform, 1, 0, voxelView.m);
                    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
                }
            }
        }
    }
    
    
    /*
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelViewMatrix.m);
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    */

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

- (void)setupVoxels
{
    for (int i = 0; i < VOX_ARRAY_SIZE; i++) {
        for (int j = 0; j < VOX_ARRAY_SIZE; j++) {
            for (int k = 0; k < VOX_ARRAY_SIZE; k++) {
                _voxels[i][j][k] = 1;
            }
        }
    }
}
- (void)pan:(UIPanGestureRecognizer*)pgr
{
    CGPoint translatedPoint = [pgr velocityInView:self];
    _pan_x += translatedPoint.x/100;
    _pan_y += translatedPoint.y/100;
}

- (void)setupGestures
{
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:panGesture];
    _pan_x = 0.0;
    _pan_y = 0.0;
}
#pragma mark -

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        [self setupGestures];
        [self setupLayer];
        [self setupContext];
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self setupVBOs];
        [self setupVoxels];
        [self setupDisplayLink];
    }
    return self;
}

@end
