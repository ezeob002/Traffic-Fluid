//
//  ECEParticle.m
//  ECE 595
//


#import "ECEParticle.h"
#import "ECEGlobal.h"
#import "ECELeapFrogIntegrator.h"
#import <GLUT/GLUT.h>

// Particle's Lighting Materials
GLfloat mat_ambient[]    = {1, 1, 1, 1.0f};
GLfloat mat_diffuse[]    = {1, 1, 1, 1.0f};
GLfloat mat_specular[]   = { 1.0, 1.0, 1.0, 1.0 };
GLfloat mat_shininess[]  = { 50.0 };

@interface ECEParticle ()
{
    /// Previous particle's velocity
    GLKVector3 previousVelocity;
    
    /// The radius of the sphere that represents the particle.
    float particleRadius;
}

@end

@implementation ECEParticle

@synthesize particleID, position, velocity, acceleration, density, pressure, particleColor, cube, sphereRadius, supportRadius, secondaryParticleColor, numOfNeighbours, surfaceTensionForce, normal;

/**
 * It initializes with default values all the members of this class.
 *
 * @param
 * @return
 */
-(id) init
{
    self = [super init];
    if (self)
    {
        [self resetInfo];
    }
    return self;
}

/**
 * It gives the default value to all the members in this class.
 *
 * @param
 * @return
 */
- (void) resetInfo
{
    particleID      = 0;
    position        = GLKVector3Make(0.0, 0.0, 0.0);
    velocity        = GLKVector3Make(0.0, 0.0, 0.0);
    acceleration    = GLKVector3Make(0.0, 0.0, 0.0);
    density         = 0.1;
    pressure        = 0;
    sphereRadius    = 0.0001;
    cube            = [[ECESphere alloc] initWithCenter:GLKVector3Make(0, 0, 0) andRadius:sphereRadius];
    particleColor   = GREEN_COLOR;
    previousVelocity = GLKVector3Make(0.0, 0.0, 0.0);
    surfaceTensionForce = GLKVector3Make(0.0, 0.0, 0.0);
    normal          = GLKVector3Make(0.0, 0.0, 0.0);
    supportRadius   = 0.0;
    secondaryParticleColor = GLKVector4Make(- 1.0, -1.0, -1.0, -1.0);
    numOfNeighbours = 0;
}

#pragma mark - Utils

/**
 * It sets the position of the particle with the input "position". It also modifies the shape of the 3D element of the particle based on that position.
 *
 * @param
 * @return
 */
- (void) setParticlePosition:(GLKVector3)_position
{
    position = _position;
    
    // Setting particle cube's minimum and maximum.
    [cube updateWithCenter:_position andRadius:particleRadius];
}

/**
 * It sets the position of the particle with the input "position". It also modifies the shape of the 3D element of the particle based on that position.
 *
 * @param
 * @return
 */
- (void) setParticlePosition:(GLKVector3)_position andRadius:(float)radius
{
    position = _position;
    particleRadius = radius;
    
    // Setting particle cube's minimum and maximum.
    [cube updateWithCenter:_position andRadius:radius];
}

/**
 * It sets the color of the particle with the input "color".
 *
 * @param
 * @return
 */
- (void) setTheParticleColor:(GLKVector4)_color
{
    particleColor = _color;
    cube.color    = particleColor;
}

- (void) resetSecondaryColor
{
    secondaryParticleColor = GLKVector4Make(-1.0, -1.0, -1.0, 1.0);
}

- (void) update:(double)deltaTime
{
    GLKVector3 newPosition;
    
    // Updating particle velocity
    velocity = [ECELeapFrogIntegrator integrateVector:acceleration withDeltaTime:deltaTime previousVectorValue:velocity];//GLKVector3Add(velocity, acceleration);
    
    // Updating particle position
    newPosition = [ECELeapFrogIntegrator integrateVector:velocity withDeltaTime:deltaTime previousVectorValue:position];
    
    // Floor collision handling
    if (newPosition.y <= 0)
    {
        newPosition.v[1] = 0;
        
        velocity.v[0] = velocity.v[0] * 0.7;
        velocity.v[1] = velocity.v[1] * 0.6 * (-1);
        velocity.v[2] = velocity.v[2] * 0.7;
    }
    
    // Updating particle position
    [self setParticlePosition:newPosition];
}

#pragma mark - openGL

- (void) drawVelocity
{
    GLKVector3 tempVelocity;
    
    // init
    tempVelocity = GLKVector3MultiplyScalar(velocity, 1.4);
    
    // Drawing line
    if (GLKVector3Length(tempVelocity) > 0.01)
        [self drawArrowFrom:position to:GLKVector3Add(position, tempVelocity)];
}

#define RADPERDEG 0.0174533

- (void) drawArrowFrom:(GLKVector3)origin to:(GLKVector3)destination
{
    GLdouble x1 = origin.x;
    GLdouble y1 = origin.y;
    GLdouble z1 = origin.z;
    GLdouble x2 = destination.x;
    GLdouble y2 = destination.y;
    GLdouble z2 = destination.z;
    GLdouble D  = 0.005;
    
    double x=x2-x1;
    double y=y2-y1;
    double z=z2-z1;
    double L=sqrt(x*x+y*y+z*z);
    
    GLUquadricObj *quadObj;
    
    glPushMatrix();
    
    glTranslated(x1,y1,z1);
    //glTranslatef(-z1 * 0.5,0,0);
    
    if((x!=0.)||(y!=0.)) {
        glRotated(atan2(y,x)/RADPERDEG,0.,0.,1.);
        glRotated(atan2(sqrt(x*x+y*y),z)/RADPERDEG,0.,1.,0.);
    } else if (z<0){
        glRotated(180,1.,0.,0.);
    }
    
    glTranslatef(0,0,L-4*D);
    
    quadObj = gluNewQuadric ();
    gluQuadricDrawStyle (quadObj, GLU_FILL);
    gluQuadricNormals (quadObj, GLU_SMOOTH);
    gluCylinder(quadObj, 2*D, 0.0, 4*D, 32, 1);
    gluDeleteQuadric(quadObj);
    
    quadObj = gluNewQuadric ();
    gluQuadricDrawStyle (quadObj, GLU_FILL);
    gluQuadricNormals (quadObj, GLU_SMOOTH);
    gluDisk(quadObj, 0.0, 2*D, 32, 1);
    gluDeleteQuadric(quadObj);
    
    glTranslatef(0,0,-L+4*D);
    
    quadObj = gluNewQuadric ();
    gluQuadricDrawStyle (quadObj, GLU_FILL);
    gluQuadricNormals (quadObj, GLU_SMOOTH);
    gluCylinder(quadObj, D * 0.4, D * 0.5, L-4*D, 32, 1);
    gluDeleteQuadric(quadObj);
    
    quadObj = gluNewQuadric ();
    gluQuadricDrawStyle (quadObj, GLU_FILL);
    gluQuadricNormals (quadObj, GLU_SMOOTH);
    gluDisk(quadObj, 0.0, D, 32, 1);
    gluDeleteQuadric(quadObj);
    
    glPopMatrix();
}

- (void) draw
{
    glPushMatrix();
    
    GLKVector4 color;
    
    // Color
    if (secondaryParticleColor.v[0] == - 1.0)
        color = particleColor;
    else
        color = secondaryParticleColor;
    glColor4f(color.x, color.y, color.z, 1);
    
    // Position
    glTranslatef(position.x, position.y, position.z);
    
    // Setting particle color to the particle's materials
    mat_ambient[0] = color.r;
    mat_ambient[1] = color.g;
    mat_ambient[2] = color.b;
    mat_diffuse[0] = color.r;
    mat_diffuse[1] = color.g;
    mat_diffuse[2] = color.b;

    // Setting Lighting materials
    glMaterialfv(GL_FRONT, GL_AMBIENT, mat_ambient);
    glMaterialfv(GL_FRONT, GL_DIFFUSE, mat_diffuse);
    glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular);
    glMaterialfv(GL_FRONT, GL_SHININESS, mat_shininess);
    
    // Drawing particle
    glutSolidSphere(sphereRadius, 12, 12);
    
    // ONLY for debugging: drawing the support radius of the particle as a sphere.
    if (particleID == PARTICLE_TO_TEST_ID)
    {
        glLineWidth(0.5);
        glColor4f(1, 1, 1, 0.6);
        glutWireSphere(supportRadius, 8, 8);
    }
    
    glPopMatrix();
}

@end
