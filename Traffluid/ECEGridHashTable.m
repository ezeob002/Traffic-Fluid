//
//  ECEHashTable.m
//  ECE595
//

#import "ECEGridHashTable.h"
#import <GLKit/GLKit.h>
#import "ECEParticle.h"
#import "ECESimplifiedCube.h"
#import "ECECube.h"

NSMutableArray* lastNeighbours;

#define HASH_FUNCTION_PRIME_1  73856093
#define HASH_FUNCTION_PRIME_2  19349663
#define HASH_FUNCTION_PRIME_3  83492791

@interface ECEGridHashTable ()
{
    /// Hash table where the objects will be saved.
    NSMutableDictionary *hashTable;
    
    /// The number of elements in the hash table.
    NSInteger hashTableSize;
    
    /// Contains the string of the last generated key. The idea behind it is to avoid creating a new NSString instance every time a new key is created (this minimizes the computation time). So instead, we use this string over and over for every key we generate.
    NSMutableString *lastGeneratedKey;
    
    /// The size of each cell in the grid.
    float cellSize;
    
    /// Value of 1/cellSize. It's used to avoid division computations.
    float oneDivByCellSize;
    
    /// Cubes that will be drawn in case the user wants to draw the grid cells.
    NSMutableArray* cubes;
    
    GLKVector3 auxiliarVector;
}

- (NSInteger) hashKeyFunction:(GLKVector3)position;

- (NSInteger) hashKeyFunctionWithoutNormalizingPosition:(GLKVector3)position;
- (GLKVector3) getCellSizeNormalizedVector:(GLKVector3)position;

- (NSInteger) getNextPrimeNumberFrom:(NSInteger)number;

- (BOOL) isPrime:(NSInteger)number;

- (void) resetHashTable;

- (void) addParticle:(ECEParticle*)particle;

- (void) addThisParticle:(ECEParticle*)particle toThisArray:(NSMutableArray*)array;

- (NSMutableArray*) getParticlesInGridCellDefinedByPosition:(GLKVector3)position;

- (NSMutableArray*) getParticlesInGridCellDefinedByPositionWithoutNormalizingPosition:(GLKVector3)position;


@end

@implementation ECEGridHashTable

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
 * It initializes with input value "numOfParticles" and "_cellSize".
 *
 * @param numOfParticles    Number of particles in the SPH system.
 * @param _cellSize         The h support of the kernels in the SPH system.
 * @return
 */
- (id) initWithNumberOfParticles:(NSInteger)_numOfParticles
                andFluidMaterial:(ECEFluidMaterial*)fluidMaterial
{
    id r;
    
    // init
    r = [self init];
    
    // Setting parameters
    hashTableSize    = [self getNextPrimeNumberFrom:(2 * _numOfParticles)];
    hashTable        = [[NSMutableDictionary alloc] init];
    cellSize         = fluidMaterial.supportRadius;
    oneDivByCellSize = 1 / cellSize;
    self.numberOfParticles = _numOfParticles;
    self.arrayfHashes = [[NSMutableArray alloc] init];
    lastNeighbours    = [[NSMutableArray alloc] initWithCapacity:_numOfParticles];
    
    return r;
}

/**
 * It gives the default value to all the members in this class.
 *
 * @param
 * @return
 */
- (void) resetInfo
{
    hashTableSize    = 10;
    hashTable        = [[NSMutableDictionary alloc] init];
    cellSize         = 0;
    oneDivByCellSize = 1 / cellSize;
    lastGeneratedKey = [NSMutableString stringWithString:@""];
}

#pragma Utils

/**
 * It returns a hash key for the input vector "position".
 *
 * @param position      The position from which the key to return will be generated.
 * @return a hash key for the input position "position"
 */
- (NSInteger) hashKeyFunction:(GLKVector3)position
{
    NSInteger intKey;
    int x, y, z;
    
    // Dividing the position vector by the cell size.
    position = [self getCellSizeNormalizedVector:position];
    
    // Getting position components times the primes
    x = position.x * HASH_FUNCTION_PRIME_1;
    y = position.y * HASH_FUNCTION_PRIME_2;
    z = position.z * HASH_FUNCTION_PRIME_3;
    
    // Getting float key
    intKey = (x ^ y ^ z) % hashTableSize;
    
    return intKey;
}


/**
 * It returns a hash key for the input vector "position" without normalizing it first.
 *
 * @param position      The position from which the key to return will be generated.
 * @return a hash key for the input position "position"
 */
- (NSInteger) hashKeyFunctionWithoutNormalizingPosition:(GLKVector3)position
{
    NSInteger intKey;
    int x, y, z;
    
    // Getting position components times the primes
    x = position.x * HASH_FUNCTION_PRIME_1;
    y = position.y * HASH_FUNCTION_PRIME_2;
    z = position.z * HASH_FUNCTION_PRIME_3;
    
    // Getting float key
    intKey = (x ^ y ^ z) % hashTableSize;
    
    return intKey;
}

/**
 * It returns the same input vector "position" but divided by the grid's cell size.
 *
 * @param position      The vector to be normalized.
 * @return the same input vector "position" but divided by the grid's cell size.
 */
- (GLKVector3) getCellSizeNormalizedVector:(GLKVector3)position
{
    return GLKVector3Make(floor(position.x * oneDivByCellSize),
                          floor(position.y * oneDivByCellSize),
                          floor(position.z * oneDivByCellSize));
}

/**
 * It returns the next prime number after the input "number".
 *
 * @param number      Number from which the next prime number will be calculated.
 * @return the next prime number after the input "number".
 */
- (NSInteger) getNextPrimeNumberFrom:(NSInteger)number
{
    NSInteger limit, nextPrime;
    
    // If the input number is prime, we return the input number.
    if ([self isPrime:number])
        return number;
    
    // Making the input number be uneven.
    if (number % 2 == 0)
        number++;
    else
        number = number + 2;
    
    // init
    limit     = number + 1000000;
    nextPrime = 1;
    
    // Finding the next prime number.
    for (int i=(int)number; i<limit; i++)
    {
        if ([self isPrime:i])
        {
            nextPrime = i;
            break;
        }
    }
    
    return nextPrime;
}

/**
 * It returns YES if the input "number" is a prime number. NO, otherwise.
 *
 * @param number      Number to be determined if it's prime or not.
 * @return YES if the input "number" is a prime number. NO, otherwise.
 */
- (BOOL) isPrime:(NSInteger)number
{
    BOOL isPrime;
    NSInteger limit;
    
    // init
    isPrime = YES;
    limit = floor(number * 0.5);
    
    // Cheking if the number is prime or not
    for(int i=2; i<=limit; ++i)
    {
        if(number % i == 0)
        {
            isPrime = NO;
            break;
        }
    }
    
    return isPrime;
}

/**
 * It removes all the objects in the hash table.
 *
 * @param
 * @return
 */
- (void) resetHashTable
{
    if (hashTable)
        [hashTable removeAllObjects];
}

/**
 * It saves the input particle "particle" into the hash table..
 *
 * @param particle     The particle to be saved in the hash table.
 * @return
 */
- (void) addParticle:(ECEParticle*)particle
{
    NSMutableArray* particlesArray;
    NSInteger particleKey;
    GLKVector3 position;
    
    // Getting position from particle
    position = [particle position];
    
    // Getting particle's hash key
    particleKey = [self hashKeyFunction:position];
    
    // Getting particles array from the hash table
    particlesArray = [hashTable objectForKey:@(particleKey)];
    
    // If array is nil, we initialize it.
    if (particlesArray == nil)
        particlesArray = [[NSMutableArray alloc] init];
    
    // Adding input particle to the array (it doesn't matter if the particle is already in the array). We don't check for duplicates.
    [particlesArray addObject:particle];
    
    // Saving array back to the hash table
    [hashTable setObject:particlesArray forKey:@(particleKey)];
}

/**
 * It returns the array of particles found in the grid cell that corresponds with the input position "position".
 *
 * @param position     The position that corresponds with the grid cell from where the array of particles will be gotten.
 * @return the array of particles found in the grid cell that corresponds with the input position "position".
 */
- (NSMutableArray*) getParticlesInGridCellDefinedByPosition:(GLKVector3)position
{
    NSMutableArray* r;
    NSInteger particleKey;
    
    // Getting particle's hash key.
    particleKey = [self hashKeyFunction:position];
    
    // Getting particles array from the hash table.
    r = [hashTable objectForKey:@(particleKey)];
    
    return r;
}



/**
 * It returns the array of particles found in the grid cell that corresponds with the input position "position".
 *
 * @param position     The position that corresponds with the grid cell from where the array of particles will be gotten.
 * @return the array of particles found in the grid cell that corresponds with the input position "position".
 */
- (NSMutableArray*) getParticlesInGridCellDefinedByPositionWithoutNormalizingPosition:(GLKVector3)position
{
    NSMutableArray* r;
    NSInteger particleKey;
    
    // Getting particle's hash key.
    particleKey = [self hashKeyFunctionWithoutNormalizingPosition:position];
    
    // Getting particles array from the hash table.
    r = [hashTable objectForKey:@(particleKey)];
    
    return r;
}

/**
 * It updates the grid with the particles positions found in input array "particles".
 *
 * @param particles     The particles which positions will update (refresh) the grid.
 * @return
 */
- (void) resetWithParticles:(NSMutableArray*)particles
{
    // Reseting hash table
    [self resetHashTable];
    
    // Adding all the particles in the hash table.
    for (int i=0; i<[particles count]; i++)
        [self addParticle:particles[i]];
}

/**
 * It returns an array with the nearest neighbours of input particle "particle" within the range defined by input "radius".
 *
 * @param particle     The particle which position the nearest neighbouts will be looked for.
 * @param radius       The range within the nearest neighbours will be looked for.
 * @return an array with the nearest neighbours of input particle "particle" within the range defined by input "radius".
 */
- (void) findNearestNeighborsToPosition:(ECEParticle*)particle withRadius:(double)radius
{
    GLKVector3 min, max, position, auxPos, normalizedMin, normalizedMax;
    double radius2, offset;
    
    // init
    [lastNeighbours removeAllObjects];
    position = [particle position];
    auxPos   = GLKVector3Make(0, 0, 0);
    radius2  = radius * radius;
    offset   = 0;
    
    // Calculating the min and max values for the bounding box of the sphere represented by the input position.
    min = GLKVector3Make(position.x, position.y, position.z);
    max = GLKVector3Make(position.x, position.y, position.z);
    
    // Normalizing min and max
    normalizedMin = GLKVector3SubtractScalar([self getCellSizeNormalizedVector:min], 1);
    normalizedMax = GLKVector3AddScalar([self getCellSizeNormalizedVector:max], 1);
    
    // Getting the neighbour particles
    for (double i =normalizedMin.x; i<=normalizedMax.x; i++)
    {
        for (double j=normalizedMin.y; j<=normalizedMax.y; j++)
        {
            for (double k=normalizedMin.z; k<=normalizedMax.z; k++)
            {
                NSMutableArray* localParticlesArray;
                
                // Getting local array of particles
                localParticlesArray = [self getParticlesInGridCellDefinedByPositionWithoutNormalizingPosition:GLKVector3Make(i, j, k)];
                
                // Filtering the gotten neighbour particles to select only particles inside the sphere.
                if (localParticlesArray)
                {
                    for (int p=0; p<[localParticlesArray count]; p++)
                    {
                        // Substracting the positions
                        auxiliarVector.v[0] = [((ECEParticle*)localParticlesArray[p]) position].v[0] - position.v[0];
                        if (fabs(auxiliarVector.v[0]) <= radius)
                        {
                            auxiliarVector.v[1] = [((ECEParticle*)localParticlesArray[p]) position].v[1] - position.v[1];
                            if (fabs(auxiliarVector.v[1]) <= radius)
                            {
                                auxiliarVector.v[2] = [((ECEParticle*)localParticlesArray[p]) position].v[2] - position.v[2];
                                
                                if (fabs(auxiliarVector.v[2]) <= radius)
                                {
                                    if (GLKVector3DotProduct(auxiliarVector, auxiliarVector) <= radius2 )
                                    {
                                        if ( ! [lastNeighbours containsObject:localParticlesArray[p]])
                                            [lastNeighbours addObject:localParticlesArray[p]];
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Setting number of neighbours for particle.
    particle.numOfNeighbours = (int) [lastNeighbours count];
}

/*
 * It adds the input particle "particle" to the input array "array" as long as that particle is not already in the array.
 *
 * @param particle      The particle that would be added to the array.
 * @param array         The array where the particle would be added to the array.
 * @param
 */
- (void) addThisParticle:(ECEParticle*)particle toThisArray:(NSMutableArray*)array
{
    BOOL isInTheArrayAlready = NO;
    
    for (int i=0; i<[array count]; i++)
    {
        if ([array[i] particleID] == [particle particleID])
        {
            isInTheArrayAlready = YES;
            break;
        }
    }
        
    if ( ! isInTheArrayAlready)
        [array addObject:particle];
}

- (void) removeParticle:(ECEParticle*)particle
{
    NSArray* keys;
    
    // Getting all keys of the dictionary
    keys = [hashTable allKeys];
    
    for (int i=0; i<[keys count]; i++)
    {
        NSMutableArray* objects;
        
        // Getting objects for key i
        objects = [hashTable objectForKey:keys[i]];
        
        if (objects)
        {
            // Removing the object from the hash table array
            [objects removeObject:particle];
            
            // Setting new array to the same key
            [hashTable setObject:objects forKey:keys[i]];
        }
    }
}

#pragma mark - OpenGL

- (void) draw
{
    NSArray* allKeys;
    NSInteger validNumOfCubes;
    
    // init
    validNumOfCubes = 0;
    
    // init array of cubes (if necessary).
    if (cubes == nil)
    {
        cubes = [[NSMutableArray alloc] init];
        
        for (int i=0; i<self.numberOfParticles; i++)
        {
            ECESimplifiedCube *cube;
            
            // Creating a cube
            cube            = [[ECESimplifiedCube alloc] init];
            cube.color      = BLUE_COLOR;
            cube.renderType = GL_LINE_STRIP;
            
            // Adding the cube to the array of cubes
            [cubes addObject:cube];
        }
    }
    
    // Getting all the keys of the hash table
    allKeys = [hashTable allKeys];
    
    // Going trough all the keys to create a cell that could be drawn for each of them.
    for (int i=0; i<[allKeys count]; i++)
    {
        NSMutableArray* array;
        
        // Getting array for current key
        array = [hashTable objectForKey:allKeys[i]];
        
        if (array && [array isKindOfClass:[NSMutableArray class]])
        {
            // Getting the first particle of the array
            if ([array count] > 0)
            {
                ECEParticle* particle;
                
                particle = array[0];
            
                if (particle)
                {
                    GLKVector3 normalizedPosition;
                    ECESimplifiedCube *cube;
                    
                    // Normalizing particle's position
                    normalizedPosition   = [self getCellSizeNormalizedVector:[particle position]];
                    normalizedPosition   = GLKVector3MultiplyScalar(normalizedPosition, cellSize);
                    
                    // Getting cube
                    cube = cubes[validNumOfCubes];
                    
                    // Creating a cube from the normalized position.
                    [cube updateWithMin:normalizedPosition andMax:GLKVector3AddScalar(normalizedPosition, cellSize)];
                    
                    // increasing the valid number of cubes
                    if (validNumOfCubes < self.numberOfParticles)
                        validNumOfCubes++;
                }
            }
        }
    }
    
    // Drawing all the cubes found in the array of cubes
    for (int i=0; i<validNumOfCubes; i++)
         [((ECESimplifiedCube*)cubes[i]) draw];
}

@end
