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
#import "VXBlock.h"
#import "VXVoxelBox.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define ARC4RANDOM_MAX      0x100000000

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
    GLuint       _normalSlot;
    GLuint       _colorSlot;
    
    GLuint       _projectionUniform;
    GLuint       _modelViewUniform;
    GLuint       _normalUniform;
    
    float        _currentRotation;
    
    VXBlock*     _voxels[VOX_ARRAY_SIZE][VOX_ARRAY_SIZE][VOX_ARRAY_SIZE];
    VXVoxelBox*  _voxelBox;

    float        _pan_x;
    float        _pan_y;
    float        _zoom;
    
    BOOL         _disco;
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
    _voxelBox = [[VXVoxelBox alloc] init];
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, [_voxelBox vertexDataSize], [_voxelBox vertexData], GL_STATIC_DRAW);
/*
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
*/
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
    glClearColor(40/255.0, 40.0/255.0, 50.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);

    // Connect program vars
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(0));
    glVertexAttribPointer(_normalSlot,   3, GL_FLOAT, GL_FALSE, 24, BUFFER_OFFSET(12));
    
    
    // Projection matrix
    float aspect = fabsf(self.bounds.size.width / self.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);

    // Base model view matrix.
    // Used to translate the both the projectionMatrix and the modelViewMatrix.
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0, 0.0, -30.0 + _zoom);
    
    glUniformMatrix4fv(_projectionUniform, 1, 0, GLKMatrix4Multiply(projectionMatrix, baseModelViewMatrix).m);
    
    // Model view matrix
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(-12.5, -12.5, 12.5);
    GLKMatrix4 rotationMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(_pan_x), 0, 1, 0);
    rotationMatrix = GLKMatrix4Rotate(rotationMatrix, GLKMathDegreesToRadians(_pan_y), 1, 0, 0);
    modelViewMatrix = GLKMatrix4Multiply(rotationMatrix, modelViewMatrix);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    
    // Draw
    GLKMatrix4 voxelView;
    for (int i=0; i < VOX_ARRAY_SIZE; i++) {
        for (int j=0; j < VOX_ARRAY_SIZE; j++) {
            for (int k=0; k < VOX_ARRAY_SIZE; k++) {
                if (_voxels[i][j][k].active) {
                    if (_disco) {
                        // Triple tap surprise
                        glUniform4fv(_colorSlot, 1, [self randomColor].v);
                    } else {
                        glUniform4fv(_colorSlot, 1, [self BlockTypeColor:_voxels[i][j][k].type].v);
                    }
                    voxelView = GLKMatrix4Translate(modelViewMatrix, i*2.5, j*2.5, -k*2.5);
                    glUniformMatrix4fv(_modelViewUniform, 1, 0, voxelView.m);
                    //glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
                    
                    // Normals
                    GLKMatrix3 normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(voxelView), NULL);
                    glUniformMatrix3fv(_normalUniform, 1, 0, normalMatrix.m);

                    
                    glDrawArrays(GL_TRIANGLES, 0, 36);
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

- (GLKVector4)randomColor
{
     return GLKVector4Make(((double)arc4random() / ARC4RANDOM_MAX), ((double)arc4random() / ARC4RANDOM_MAX), ((double)arc4random() / ARC4RANDOM_MAX), 1.0);
}
- (GLKVector4)BlockTypeColor:(int)blockType
{
    switch (blockType) {
        case BlockType_Dirt:
            return GLKVector4Make(139.0/255.0, 69.0/255.0, 19.0/255.0, 1.0);
        case BlockType_Grass:
            return GLKVector4Make(0.0, 0.8, 0.2, 1.0);
        case BlockType_Sand:
            return GLKVector4Make(1.0, 1.0, 0.8, 1.0);
        case BlockType_Stone:
            return GLKVector4Make(0.6, 0.6, 0.6, 1.0);
        case BlockType_Water:
            return GLKVector4Make(0.0, 0.0, 0.8, 1.0);
        case BlockType_Wood:
            return GLKVector4Make(222.0/255.0, 184/255.0, 135.0/255.0, 1.0);
        default:
            return GLKVector4Make(0.0/255.0, 100.0/255.0, 0.0/255.0, 1.0);
    }
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
    _normalSlot = glGetAttribLocation(programHandle, "Normal");
    //_colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_normalSlot);
    //glEnableVertexAttribArray(_colorSlot);
    _colorSlot = glGetUniformLocation(programHandle, "SourceColor");
    
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
    _normalUniform = glGetUniformLocation(programHandle, "NormalMatrix");
        
}

- (void)setupVoxels
{
    
    for (int i = 0; i < VOX_ARRAY_SIZE; i++) {
        for (int j = 0; j < VOX_ARRAY_SIZE; j++) {
            for (int k = 0; k < VOX_ARRAY_SIZE; k++) {
                VXBlock* block = [[VXBlock alloc] init];
                //block.active = (rand() % 10) > 5;
                block.active = YES;
                block.type = rand() % BlockType_NumTypes;
                _voxels[i][j][k] = block;
            }
        }
    }
}
- (void)tap:(UITapGestureRecognizer*)tgr
{
    CGPoint screen_coords = [tgr locationInView:self];
    // Translate this back via projection and modelview matricies.
    
}

- (void)tap3:(UITapGestureRecognizer*)tgr
{
    _disco = !_disco;
}
- (void)pan:(UIPanGestureRecognizer*)pgr
{
    CGPoint translatedPoint = [pgr velocityInView:self];
    _pan_x += translatedPoint.x/100;
    _pan_y += translatedPoint.y/100;
}

-(void)pinch:(UIPinchGestureRecognizer*)pgr
{
    static float lastScale = 1.0;
    if ([pgr scale] < lastScale) {
        _zoom += [pgr scale] - lastScale - 1;
    } else {
        _zoom -= lastScale - [pgr scale] - 1;
    }
    
    lastScale = [pgr scale];
    if (pgr.state == UIGestureRecognizerStateEnded) {
        lastScale = 1.0;
    }
    if (_zoom > 26.0) {
        _zoom = 26.0;
    }
    if (_zoom < -10.0) {
        _zoom = -10.0;
    }
}

- (void)setupGestures
{
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:panGesture];
    _pan_x = 0.0;
    _pan_y = 0.0;
    
    UIPinchGestureRecognizer* pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
    [self addGestureRecognizer:pinchGesture];
    _zoom = 0.0;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer* tap3Gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap3:)];
    tap3Gesture.numberOfTapsRequired = 3;
    [self addGestureRecognizer:tap3Gesture];
    _disco = NO;
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
