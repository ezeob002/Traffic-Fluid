//
//  main.m
//  Traffluid
//


#import <Foundation/Foundation.h>
#import <OpenGL/OpenGL.h>
#import <GLUT/GLUT.h>
#import "TFCamera.h"
#import "ECEGrid.h"
#import "ECEOpendGlassBox.h"
#import "ECETrafficParticleSystem.h"
#import "ECETrafficFluidMaterial.h"
#import "ECECollisionOOBox.h"
#import "ECESphere.h"
#import "ECEKernels.h"
#import "ECEParticleSystemSPH.h"
#import "ECEWaterFluidMaterial.h"
#import "ECEOpenCL.h"
#import "ECETrafficParticle.h"

#define WINDOW_POS_X  0.0
#define WINDOW_POS_Y  0.0
#define WINDOW_WIDTH  1600.0
#define WINDOW_HEIGHT 1000.0

GLfloat light_diffuse[]  = {1.0, 1.0, 1.0, 1.0};  /* Red diffuse light. */
GLfloat light_position[] = {1.0, 1.0, 1.0, 0.0};  /* Infinite light location. */
GLfloat n[6][3] = {
    /* Normals for the 6 faces of a cube. */
    {-1.0, 0.0, 0.0}, {0.0, 1.0, 0.0}, {1.0, 0.0, 0.0},
    {0.0, -1.0, 0.0}, {0.0, 0.0, 1.0}, {0.0, 0.0, -1.0} };
GLint faces[6][4] = {
    /* Vertex indices for the 6 faces of a cube. */
    {0, 1, 2, 3}, {3, 2, 6, 7}, {7, 6, 5, 4},
    {4, 5, 1, 0}, {5, 6, 2, 1}, {7, 4, 0, 3} };
GLfloat v[8][3];  /* Will be filled in with X,Y,Z vertexes. */

// Grid
ECEGrid *grid;

// Camera
TFCamera *camera;

// Utils
bool paddingEnabled    = false;
bool drawGrid          = false;
bool drawDensity       = false;
bool useTrafficSystem  = false;
bool showHelpInfo      = false;
GLKVector3 containerSize;
ECEParticle * selectedParticle;
int currentTime, previousTime, frameCount;
float fps;
GLKVector3 nextCameraPosition, dir;

// Mouse
int prevMouseX, prevMouseY;
int lastWindowWidth, lastWindowHeight;
float mouseMovementFactor = 0.005;
bool mouseButtonWasJustPressed = false;
bool mouseIsDragging = false;
bool firstTimeTheCameraIsRepositioned = true;
bool repositionTheCamera = true;

/// System of particles that will simulate traffic.
ECETrafficParticleSystem* trafficParticleSystem;
ECEParticleSystemSPH* sphParticleSystem;
ECEParticleSystem *currentSystem;

/// Shape that will contain tthe fluid.
ECEOpendGlassBox *fluidContainer;

#warning remove
GLKVector3 convertedScreenPoint;
GLKVector3 convertedScreenPoint2;

/*******************************
 *                             *
 *          UTILITIES          *
 *                             *
 *******************************/

/**
 * Converts screen coordinates to 3D World coordinates.
 *
 * @param x     X coordinate of screen position.
 * @param Y     Y coordinate of screen position.
 * @return Input position but converted to 3D world coordinates.
 */
GLKVector3 GetOGLPos(int x, int y, float winZ)
{
    GLint viewport[4];
    GLdouble modelview[16];
    GLdouble projection[16];
    GLfloat winX, winY;
    GLdouble posX, posY, posZ;
    
    // Getting Projection, ModelView matrices and Viewport
    glGetDoublev( GL_MODELVIEW_MATRIX, modelview );
    glGetDoublev( GL_PROJECTION_MATRIX, projection );
    glGetIntegerv( GL_VIEWPORT, viewport );
    
    // Converting top-left corner screen coordinates to bottom-left corner coordinates
    winX = (float)x;
    winY = (float)viewport[3] - y;
    //glReadPixels( x, (int)(winY), 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, &winZ );
    
    // Converting screen coordinates to 3D world coordinates.
    bool result = gluUnProject( winX, winY, winZ, modelview, projection, viewport, &posX, &posY, &posZ);
    
    if (result == GL_FALSE)
        NSLog(@"Error while trying to get 3D world coordinates from screen coordinates");
    
    return GLKVector3Make(posX, posY, posZ);
}

/**
 * Given screen coordinate, it returns the ray that goes from the input screen coordinates (in the near plane) to its counterpart in the far plane.
 *
 * @param x     X coordinate of screen position.
 * @param Y     Y coordinate of screen position.
 * @return picking ray.
 */
GLKVector3 getPickingRay(int x, int y)
{
    return GLKVector3Normalize(GLKVector3Subtract(GetOGLPos(x, y, 1.0), GetOGLPos(x, y, 0.0)));
}

/**
 * Calculates the frames per second.
 *
 * @param
 * @return
 */
void calculateFPS()
{
    //  Increase frame count
    frameCount++;
    
    //  Get the number of milliseconds since glutInit called
    //  (or first call to glutGet(GLUT ELAPSED TIME)).
    currentTime = glutGet(GLUT_ELAPSED_TIME);
    
    //  Calculate time passed
    int timeInterval = currentTime - previousTime;
    
    if(timeInterval > 1000)
    {
        //  calculate the number of frames per second
        fps = frameCount / (timeInterval / 1000.0f);
        
        //  Set time
        previousTime = currentTime;
        
        //  Reset frame count
        frameCount = 0;
    }
}

//
void handlingCameraAutoRepositioning()
{
    if (useTrafficSystem && repositionTheCamera)
    {
        GLKVector3 particlesAveragePosition;
        
        particlesAveragePosition = [((ECETrafficParticleSystem*)currentSystem) particlesAveragePosition];
        
        // Updating camera's position based on te average position of all the particles
        if (GLKVector3Length(GLKVector3Subtract(particlesAveragePosition, camera.position)) > 2.1)
        {
            if (firstTimeTheCameraIsRepositioned)
            {
                [camera setLookAt:particlesAveragePosition];
                firstTimeTheCameraIsRepositioned = false;
            }
            else
            {
                nextCameraPosition = particlesAveragePosition;
                nextCameraPosition.v[2] = camera.lookAt.z;
                
                //
                dir = GLKVector3Normalize(GLKVector3Subtract(nextCameraPosition, camera.lookAt));
            }
        }
        
        if (GLKVector3Length(nextCameraPosition) != 0)
        {
            //
            [camera setLookAt:GLKVector3Add(camera.lookAt, GLKVector3MultiplyScalar(dir, 0.05))];
            
            //
            if (GLKVector3Length(GLKVector3Subtract(nextCameraPosition, camera.lookAt)) < 0.05)
                nextCameraPosition = GLKVector3Make(0, 0, 0);
        }
    }
}

/************************
 *                      *
 *    INITIALIZATION    *
 *                      *
 ************************/

/**
 * Particle System Initialization Function
 *
 * @param
 * @return
 */
void initParticleSystem(void)
{
    if (useTrafficSystem)
    {
        // Setting containerSize
        containerSize = GLKVector3Make(0.6, 30.5, 0.1);
        
        // init traffic particles system
        trafficParticleSystem = [[ECETrafficParticleSystem alloc] init];
        [trafficParticleSystem setTheFluidMaterial:[[ECETrafficFluidMaterial alloc] init]];
        //[trafficParticleSystem setParticlesInitialVelocity:GLKVector3Make(0.4, 0.1, 0.3)];
        [trafficParticleSystem createParticlesInGridInContainerSize:containerSize];
        
        // Init kernels
        [ECEKernels initializeWithSupportRadius:trafficParticleSystem.fluidMaterial.supportRadius];
        
        // Creating the Fluid Container
        fluidContainer = [[ECEOpendGlassBox alloc] initWithMin:GLKVector3Make(- containerSize.x * 0.5, -  containerSize.y * 0.5, -  containerSize.z * 0.5) andMax:GLKVector3Make(containerSize.x * 0.5, containerSize.y * 0.5, containerSize.z * 0.5)];
        
        // Creating the collision shape for the fluid container
        [trafficParticleSystem setTheCollisionShape:[[ECECollisionOOBox alloc] initWithCenter:GLKVector3Make(0, 0, 0) axisU:GLKVector3Make(1, 0, 0) axisV:GLKVector3Make(0, 1, 0) axisW:GLKVector3Make(0, 0, 1) halfU:containerSize.x * 0.5 halfV:containerSize.y * 0.5 halfW:containerSize.z * 0.5]];
        
        // Adding gravity to the system
        [trafficParticleSystem addGravity];
        
        currentSystem = trafficParticleSystem;
    }
    else
    {
        // Setting containerSize
        containerSize = GLKVector3Make(0.6, 0.6, 0.4);
        
        // init SPH particles system
        sphParticleSystem = [[ECEParticleSystemSPH alloc] init];
        [sphParticleSystem setTheFluidMaterial:[[ECEWaterFluidMaterial alloc] init]];
        [sphParticleSystem createParticlesInGridInContainerSize:containerSize];
        
        // Init kernels
        [ECEKernels initializeWithSupportRadius:sphParticleSystem.fluidMaterial.supportRadius];
        
        // Creating the Fluid Container
        fluidContainer  = [[ECEOpendGlassBox alloc] initWithMin:GLKVector3Make(- containerSize.x * 0.5, -  containerSize.y * 0.5, -  containerSize.z * 0.5) andMax:GLKVector3Make(containerSize.x * 0.5, containerSize.y * 0.5, containerSize.z * 0.5)];
        
        // Creating the collision shape for the fluid container
        [sphParticleSystem setTheCollisionShape:[[ECECollisionOOBox alloc] initWithCenter:GLKVector3Make(0, 0, 0) axisU:GLKVector3Make(1, 0, 0) axisV:GLKVector3Make(0, 1, 0) axisW:GLKVector3Make(0, 0, 1) halfU:containerSize.x * 0.5 halfV:containerSize.y * 0.5 halfW:containerSize.z * 0.5]];
        
        // Adding gravity to the system
        [sphParticleSystem addGravity];
        
        currentSystem = sphParticleSystem;
    }
}

/**
 * Particle System Initialization Function
 *
 * @param
 * @return
 */
void resetParticleSystem(void)
{
    // init traffic particles system
    if (currentSystem)
    {
        [currentSystem removeParticles];
        [currentSystem setParticlesInitialPosition:GLKVector3Make(0, 0.8, 0)];
        [currentSystem createParticlesInGridInContainerSize:containerSize];
    }
}

/**
 * Initialization Function
 *
 * @param
 * @return
 */
void init(void)
{
    // Creating and setting up camera
    camera = [[TFCamera alloc] init];
    if (useTrafficSystem)
        [camera setInitialPosition:GLKVector3Make(-3, 1.5, 25)
                     initialLookAt:GLKVector3Make(0, 0, 0)
                         initialUp:GLKVector3Make(1, 0, 0)];
    else
        [camera setInitialPosition:GLKVector3Make(0, 0, 1)
                     initialLookAt:GLKVector3Make(0, 0, 0)
                         initialUp:GLKVector3Make(0, 1, 0)];
    
    if (useTrafficSystem)
        camera.distanceToLookAtPoint = 2.0;
    else
        camera.distanceToLookAtPoint = 1.5;
    
    // Init grid
    grid = [[ECEGrid alloc] init];
    
    // init Particle System
    initParticleSystem();
    
    /* Enable a single OpenGL light. */
    glLightfv(GL_LIGHT0, GL_DIFFUSE,  light_diffuse);
    glLightfv(GL_LIGHT0, GL_POSITION, light_position);
    glEnable(GL_LIGHT0);
    glLightfv(GL_LIGHT1, GL_DIFFUSE,  light_diffuse);
    glLightfv(GL_LIGHT1, GL_POSITION, light_position);
    glEnable(GL_LIGHT1);
    glEnable(GL_LIGHTING);
    glShadeModel (GL_SMOOTH);
    
    /* Use depth buffering for hidden surface elimination. */
    glEnable(GL_DEPTH_TEST);
    
    /* Alpha channel */
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable( GL_BLEND );
    
    /* Setup the view */
    glViewport (0, 0, (GLsizei) WINDOW_WIDTH, (GLsizei) WINDOW_HEIGHT);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective( /* field of view in degree */ 40.0,
                   /* aspect ratio */ (GLfloat)WINDOW_WIDTH / (GLfloat)WINDOW_HEIGHT,
                   /* Z near */ 0.001, /* Z far */ 80.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(camera.position.x, camera.position.y, camera.position.z,  /* eye is at (0,0,5) */
              camera.lookAt.x, camera.lookAt.y, camera.lookAt.z,        /* center is at (0,0,0) */
              camera.up.x, camera.up.y, camera.up.z);       /* up is in positive Y direction */
    
    // Saving last windows width and height.
    lastWindowWidth  = WINDOW_WIDTH;
    lastWindowHeight = WINDOW_HEIGHT;
    
    /* Adjust cube position to be asthetic angle. */
    glTranslatef(0.0, 0.0, -1.0);
    glRotatef(60, 1.0, 0.0, 0.0);
    glRotatef(-20, 0.0, 0.0, 1.0);
}

/************************
 *                      *
 *        OPENGL        *
 *                      *
 ************************/

/**
 * OpenGL Update Function
 *
 * @param
 * @return
 */
void update(void)
{
    // Drawing traffic particle system
    [currentSystem update];
    
    glutPostRedisplay();
}

/**
 * Draw some input text in input position
 *
 * @param
 * @return
 */
void drawSomeText (NSString* text, float posX, float posY)
{
    glPushMatrix();
    glLoadIdentity();

    // Drawing characters
    glColor3b(0, 0, 0);
    glWindowPos2i(posX, posY);
    for ( int i = 0; i < [text length]; ++i )
        glutBitmapCharacter(GLUT_BITMAP_HELVETICA_18, [text characterAtIndex:i]);

    glPopMatrix();
}

/**
 * Draw some input text with info about the system (like delta time, support radius, etc).
 *
 * @param
 * @return
 */
void drawSystemInfoText()
{
    int offset, posY;
    NSString* title, *deltaTime, *supportRadius, *particleMass, *numOfParticles, *fpsString, *vectorBeingDrawn;
    
    // Getting values
    offset     = 24;
    posY       = lastWindowHeight - 180 + offset;
    title      = @"System Info:";
    
    numOfParticles = [[NSString alloc] initWithFormat:@"  Number of Particles: %li", (long) currentSystem.numberOfParticles];
    deltaTime      = [[NSString alloc] initWithFormat:@"  Time Step: %.06f", [currentSystem.fluidMaterial deltaTime]];
    supportRadius  = [[NSString alloc] initWithFormat:@"  Support Radius: %.04f", [currentSystem.fluidMaterial supportRadius]];
    particleMass   = [[NSString alloc] initWithFormat:@"  Particle Mass: %.04f", [currentSystem.fluidMaterial particlesMass]];
    fpsString      = [[NSString alloc] initWithFormat:@"  %.00f FPS", fps];
    vectorBeingDrawn = @"";
    
    if (useTrafficSystem && PARTICLE_TO_TEST_ID >= 0)
    {
        if ([((ECETrafficParticleSystem*)currentSystem) drawInternalForceAlongN])
            vectorBeingDrawn = @"  [ ... Displaying Force Along N ... ]";
        else if ([((ECETrafficParticleSystem*)currentSystem) drawInternalForceAlongT])
            vectorBeingDrawn = @"  [ ... Displaying Force Along T ... ]";
        else if (PARTICLE_TO_TEST_ID > 0)
            vectorBeingDrawn = @"  [ ... Displaying Velocity ... ]";
    }
    
    // Daring Text
    drawSomeText(title, 10, lastWindowHeight - posY); posY += offset + 10;
    drawSomeText(numOfParticles, 10, lastWindowHeight - posY); posY += offset;
    drawSomeText(deltaTime, 10, lastWindowHeight - posY); posY += offset;
    drawSomeText(supportRadius, 10, lastWindowHeight - posY); posY += offset;
    drawSomeText(particleMass, 10, lastWindowHeight - posY); posY += offset;
    drawSomeText(fpsString, lastWindowWidth - 100, lastWindowHeight - posY + 10); posY += offset;
    drawSomeText(vectorBeingDrawn, lastWindowWidth - 300, lastWindowHeight - posY + 10); posY += offset;
}

/**
 * Draw text with info about the selected particle (if any).
 *
 * @param
 * @return
 */
void drawSelectedParticleText()
{
    if (selectedParticle)
    {
        int offset, posY;
        NSString* title, *density, *pressure, *particleID, *position, *velocity, *acceleration, *pressureForce, *surfaceTension, *numOfParticles, *forceAlongN, *forceAlongT;
        
        // Getting values
        offset     = 20;
        posY       = 10 + offset;
        title      = @"Selected Particle:";
        particleID = [[NSString alloc] initWithFormat:@"  Particle ID: %i", (long) [selectedParticle particleID]];
        numOfParticles = [[NSString alloc] initWithFormat:@"  Num of Neighbours: %i", (long) [selectedParticle numOfNeighbours]];
        density    = [[NSString alloc] initWithFormat:@"  Density: %.02f", [selectedParticle density]];
        pressure   = [[NSString alloc] initWithFormat:@"  Pressure: %.02f", [selectedParticle pressure]];
        position   = [[NSString alloc] initWithFormat:@"  Position: %.02f  %.02f  %.02f", selectedParticle.position.x, selectedParticle.position.y, selectedParticle.position.z];
        velocity   = [[NSString alloc] initWithFormat:@"  Velocity: %.02f  %.02f  %.02f", selectedParticle.velocity.x, selectedParticle.velocity.y, selectedParticle.velocity.z];
        acceleration = [[NSString alloc] initWithFormat:@"  Acceleration: %.02f  %.02f  %.02f", selectedParticle.acceleration.x, selectedParticle.acceleration.y, selectedParticle.acceleration.z];
        pressureForce = [[NSString alloc] initWithFormat:@"  Pressure Force: %.02f  %.02f  %.02f", selectedParticle.pressureForce.x, selectedParticle.pressureForce.y, selectedParticle.pressureForce.z];
        surfaceTension = [[NSString alloc] initWithFormat:@"  Surface Tension Force: %.05f  %.05f  %.05f", selectedParticle.surfaceTensionForce.x, selectedParticle.surfaceTensionForce.y, selectedParticle.surfaceTensionForce.z];
        
        if (useTrafficSystem)
        {
            forceAlongN = [[NSString alloc] initWithFormat:@"  Force Along N: %.02f  %.02f  %.02f", ((ECETrafficParticle*)selectedParticle).internalForceAlongN.x, ((ECETrafficParticle*)selectedParticle).internalForceAlongN.y, ((ECETrafficParticle*)selectedParticle).internalForceAlongN.z];
            forceAlongT = [[NSString alloc] initWithFormat:@"  Force Along T: %.02f  %.02f  %.02f", ((ECETrafficParticle*)selectedParticle).internalForceAlongT.x, ((ECETrafficParticle*)selectedParticle).internalForceAlongT.y, ((ECETrafficParticle*)selectedParticle).internalForceAlongT.z];
        }
        
        // Daring Text
        drawSomeText(title, 10, lastWindowHeight - posY); posY += offset + 10;
        drawSomeText(particleID, 10, lastWindowHeight - posY); posY += offset;
        drawSomeText(numOfParticles, 10, lastWindowHeight - posY); posY += offset;
        drawSomeText(density, 10, lastWindowHeight - posY); posY += offset;
        drawSomeText(pressure, 10, lastWindowHeight - posY); posY += offset;
        drawSomeText(position, 10, lastWindowHeight - posY); posY += offset;
        drawSomeText(velocity, 10, lastWindowHeight - posY); posY += offset;
        drawSomeText(acceleration, 10, lastWindowHeight - posY); posY += offset;
        drawSomeText(pressureForce, 10, lastWindowHeight - posY); posY += offset;
        drawSomeText(surfaceTension, 10, lastWindowHeight - posY); posY += offset;
        drawSomeText(forceAlongN, 10, lastWindowHeight - posY); posY += offset;
        drawSomeText(forceAlongT, 10, lastWindowHeight - posY); posY += offset;
    }
}

/**
 * Draw text that can help the user with all the commands of the system.
 *
 * @param
 * @return
 */
void drawHelpText()
{
    if (showHelpInfo)
    {
        int offset, posY, posX;
        NSString* title;
        
        // Getting values
        offset     = 20;
        posY       = 10 + offset;
        posX       = lastWindowWidth - 300;
        title      = @"Keyboard Commands:";
        
        // Drawing Text
        drawSomeText(title, posX, lastWindowHeight - posY); posY += offset + 10;
        drawSomeText([[NSString alloc] initWithFormat:@"  [SPACE]     Pause/Play System"], posX, lastWindowHeight - posY); posY += offset;
        drawSomeText([[NSString alloc] initWithFormat:@"  [w or W]     Zoom In"], posX, lastWindowHeight - posY); posY += offset;
        drawSomeText([[NSString alloc] initWithFormat:@"  [s or S]       Zoom Out"], posX, lastWindowHeight - posY); posY += offset;
        drawSomeText([[NSString alloc] initWithFormat:@"  [d or D]       Draw Densities"], posX, lastWindowHeight - posY); posY += offset;
        drawSomeText([[NSString alloc] initWithFormat:@"  [r or R]        Reset System"], posX, lastWindowHeight - posY); posY += offset;
        drawSomeText([[NSString alloc] initWithFormat:@"  [+]               Increase Time Step"], posX, lastWindowHeight - posY); posY += offset;
        drawSomeText([[NSString alloc] initWithFormat:@"  [-]               Decrease Time Step"], posX, lastWindowHeight - posY); posY += offset;
        drawSomeText([[NSString alloc] initWithFormat:@"  [h or H]       Show Help Info"], posX, lastWindowHeight - posY); posY += offset;
        drawSomeText([[NSString alloc] initWithFormat:@"  [g or G]       Draw Grid"], posX, lastWindowHeight - posY); posY += offset;
        drawSomeText([[NSString alloc] initWithFormat:@"  [Esc]           Exit System"], posX, lastWindowHeight - posY); posY += offset;
    }
}

/**
 * OpenGL Draw Function
 *
 * @param
 * @return
 */
void display(void)
{
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective( /* field of view in degree */ 40.0,
                   /* aspect ratio */ (GLfloat)WINDOW_WIDTH / (GLfloat)WINDOW_HEIGHT,
                   /* Z near */ 0.001, /* Z far */ 80.0);
    [camera updatePositionAndNormal];
    
    // Handling camera auto-positioning
    handlingCameraAutoRepositioning();
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(camera.position.x, camera.position.y, camera.position.z,  /* eye is at (0,0,5) */
              camera.lookAt.x, camera.lookAt.y, camera.lookAt.z,        /* center is at (0,0,0) */
              camera.up.x, camera.up.y, camera.up.z);                   /* up is in positive Y direction */
    
    glClearColor(0.8, 0.8, 0.8, 1);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
    // Drawing traffic particle system
    [currentSystem draw];
    
    // Drawing the fluid container
    [fluidContainer draw];
    
    // Drawing text with system info
    drawSystemInfoText();
    
    // Drawing text with info about the selected particle (if any).
    drawSelectedParticleText();
    
    // Drawing text that can help the user with all the commands of the system.
    drawHelpText();
    
    // Calculating frames per second
    calculateFPS();
    
    glutSwapBuffers();
}

/**
 * OpenGL Reshaping Function
 *
 * @param
 * @return
 */
void reshape (int w, int h)
{
    glViewport (0, 0, (GLsizei) w, (GLsizei) h);
    glMatrixMode (GL_PROJECTION);
    glLoadIdentity ();
    gluPerspective(40.0, (GLfloat) w/(GLfloat) h, 1.0, 10.0);
    [camera updatePositionAndNormal];
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    gluLookAt(camera.position.x, camera.position.y, camera.position.z,  /* eye is at (0,0,5) */
              camera.lookAt.x, camera.lookAt.y, camera.lookAt.z,        /* center is at (0,0,0) */
              camera.up.x, camera.up.y, camera.up.z);       /* up is in positive Y direction */
    
    
    glTranslatef(0.0, 0.0, -1.0);
    glRotatef(60, 1.0, 0.0, 0.0);
    glRotatef(-20, 0.0, 0.0, 1.0);
    glutPostRedisplay();
    
    // Saving last windows width and height.
    lastWindowWidth  = w;
    lastWindowHeight = h;
}

/************************
 *                      *
 *        INPUT         *
 *                      *
 ************************/

/**
 * Function that handles the input from the keyboard.
 *
 * @param
 * @return
 */
void keyboard (unsigned char key, int x, int y)
{
    switch (key)
    {
        case ' ':
            currentSystem.isPause = !currentSystem.isPause;
            break;
        case 'w':
        case 'W':
            [camera zoomCameraByScalar:-0.1];
            glutPostRedisplay();
            break;
        case 's':
        case 'S':
            [camera zoomCameraByScalar:0.1];
            glutPostRedisplay();
            break;
        case 'd':
        case 'D':
            // Enabling/Disabling "Drawing density"
            currentSystem.drawDensity = !currentSystem.drawDensity;
            glutPostRedisplay();
            break;
        case 'r':
        case 'R':
            resetParticleSystem();
            glutPostRedisplay();
            break;
        case 43: // + key
            currentSystem.fluidMaterial.deltaTime *= 1.5;
            break;
        case 45: // - key
            currentSystem.fluidMaterial.deltaTime /= 1.5;
            break;
        case 'h':
        case 'H':
            showHelpInfo = !showHelpInfo;
            break;
        case 'g':
        case 'G':
            currentSystem.drawGrid = !currentSystem.drawGrid;
            break;
        case 'x':
        case 'X':
            repositionTheCamera = !repositionTheCamera;
            break;
        case 't':
        case 'T':
            if (useTrafficSystem)
            {
                ((ECETrafficParticleSystem*)currentSystem).drawInternalForceAlongT = !((ECETrafficParticleSystem*)currentSystem).drawInternalForceAlongT;
                ((ECETrafficParticleSystem*)currentSystem).drawInternalForceAlongN = NO;
            }
            break;
        case 'N':
        case 'n':
            if (useTrafficSystem)
            {
                ((ECETrafficParticleSystem*)currentSystem).drawInternalForceAlongN = !((ECETrafficParticleSystem*)currentSystem).drawInternalForceAlongN;
                ((ECETrafficParticleSystem*)currentSystem).drawInternalForceAlongT = NO;
            }
            break;
        case 27: // Escape key
            glutDestroyWindow ( 0);
            exit (0);
            break;
        default:
            break;
    }
}

/**
 * Function that handles the input from the mouse. Specifically the one related to mouse clicking.
 *
 * @param
 * @return
 */
void mouse(int button, int state, int x, int y)
{
    paddingEnabled = false;
    
    switch (button) {
        case GLUT_LEFT_BUTTON:
            if (state == GLUT_DOWN)
            {
                mouseButtonWasJustPressed = true;
                glutPostRedisplay();
            }
            else if (state == GLUT_UP)
            {
                if ( ! mouseIsDragging)
                {
                    // Getting intersected particle
                    selectedParticle = [currentSystem rayIntersectsParticle:getPickingRay(x, y)
                                                        andRayCenter:GetOGLPos(x, y, 0.0)];
                    if (selectedParticle)
                    {
                        PARTICLE_TO_TEST_ID = [selectedParticle particleID];
                    }
                    else
                        PARTICLE_TO_TEST_ID = -1;
                }
            }
            break;
        case GLUT_RIGHT_BUTTON:
            if (state == GLUT_UP)
            {
                mouseButtonWasJustPressed = false;
                glutPostRedisplay();
            }
            else if (state == GLUT_DOWN)
            {
                mouseButtonWasJustPressed = true;
                paddingEnabled = true;
                glutPostRedisplay();
            }
            break;
        case GLUT_MIDDLE_BUTTON:
            break;
        default:
            break;
    }
    
    // Indicating that the mouse stopped dragging.
    if (state == GLUT_UP)
    {
        mouseIsDragging = false;
    }
    
    // Saving values for later.
    prevMouseX = x;
    prevMouseX = y;
}

/**
 * Function that handles the input from the mouse. Specifically the one related to mouse dragging.
 *
 * @param
 * @return
 */
void mouseMove(int x, int y)
{
    mouseIsDragging = YES;
    
    if (x >= 0 & y >= 0)
    {
        if (! mouseButtonWasJustPressed)
        {
            if (paddingEnabled)
            {
                // Camera Padding
                [camera moveCameraHorizontallyByScalar:(x - prevMouseX) * mouseMovementFactor * 0.2];
                [camera moveCameraVerticallyByScalar:(prevMouseY - y)   * mouseMovementFactor * 0.2];
            }
            else
            { 
                // Camera Sphere Rotation
                [camera addToTheta:(prevMouseX - x) * mouseMovementFactor];
                [camera addToPhi:  (y - prevMouseY) * mouseMovementFactor];
            }
        }
        
        // Saving current values for later
        prevMouseX = x;
        prevMouseY = y;
        
        mouseButtonWasJustPressed = false;
        glutPostRedisplay();
    }
}

/************************
 *                      *
 *         MAIN         *
 *                      *
 ************************/

/**
 * MAIN Function.
 *
 * @param
 * @return
 */
int main(int argc, char **argv)
{
    // init OpenCL
    [[ECEOpenCL sharedInstance] initOpenCL];
    
    glutInit(&argc, argv);
    glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH);
    glutInitWindowSize (WINDOW_WIDTH, WINDOW_HEIGHT);
    glutInitWindowPosition (WINDOW_POS_X, WINDOW_POS_Y);
    glutCreateWindow("Traffluid Simulation");
    
    init();
    
    glutReshapeFunc(reshape);
    glutDisplayFunc(display);
    glutIdleFunc(update);
    glutKeyboardFunc(keyboard);
    glutMouseFunc(mouse);
    glutMotionFunc(mouseMove);
    glutMainLoop();
    return 0;
}
