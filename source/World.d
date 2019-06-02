module tht.World;

import tht.Tile;

import std.math;
import std.random;

/**
 * A world class, containing a method of generating tiles
 * and functionality for running an iteration of the model
 */
abstract class World {

    Tile[] tiles;

    /**
     * Constructs the world
     * Sets the tiles to be as generation defines for this implementation
     */
    this(double[] args) {
        if(assertArgs(args)) {
            this.tiles = this.generate(args);
        } else {
            throw new Exception("Invalid arguments for world generation");
        }
    } 

    /**
     * The method that causes this world to develop
     * Initially undefined, depends on what world type this is
     * This method should return the list of tiles to use
     * Takes in a list of arguments, in double form, for enhanced usability
     */
    abstract Tile[] generate(double[] args);

    /**
     * Given a list of arguments, ensure that they are proper for this generation
     */
    abstract bool assertArgs(double[] args);

    /**
     * Flattens a matrix of tiles into a one-dimensional array
     */
    private Tile[] flattenMatrix(Tile[][] matrix) {
        Tile[] allTiles;
        for(int x = 0; x < matrix.length; x++) {
            for(int y = 0; y < matrix[x].length; y++) {
                allTiles ~= matrix[x][y];
            }
        }
        return allTiles;
    }

    /**
     * Runs an iteration of the tiles in the world
     * Uses the tile's two iteration stages: running, and finalizing
     */
    void iterate() {
        foreach(tile; this.tiles) {
            tile.runIteration();
        }
        foreach(tile; this.tiles) {
            tile.finalizeIteration();
        }
    }

} 

/**
 * A world that is a bounded rectangle
 * Does not handle any wraparound; it is topologically two dimensional
 */
class RectangleWorld : World {

    /**
     * Constructs a rectangle world
     * Runs the super class constructor solely
     */
    this(double[] args) {
        super(args);
    }

    /**
     * Generates the rectangular world
     * Uses two arguments, which are nrows, ncols respectively describing the
     * dimensions of the rectangular world
     * Randomly assigns tht values to tiles
     * Works by generating a matrix for past reference,
     * then flattens the matrix
     */
    override Tile[] generate(double[] args) {
        Tile[][] tileMatrix;
        int nrows = cast(int) args[0];
        int ncols = cast(int) args[1];
        for(int x = 0; x < nrows; x++) {
            tileMatrix ~= null;
            for(int y = 0; y < ncols; y++) {
                tileMatrix[x] ~= new Tile(uniform(0.0, 1.0), uniform(0.0, 1.0), uniform(0.0, 1.0));
                if(x > 0) {
                    tileMatrix[x][y].neighbors ~= tileMatrix[x-1][y];
                    tileMatrix[x-1][y].neighbors ~= tileMatrix[x][y];
                }
                if(y > 0) {
                    tileMatrix[x][y].neighbors ~= tileMatrix[x][y-1];
                    tileMatrix[x][y-1].neighbors ~= tileMatrix[x][y];
                }
            }
        }
        return flattenMatrix(tileMatrix);
    }

    /**
     * Asserts that there are at least two arguments and that they are positive and at least one
     */
    override bool assertArgs(double[] args) {
        return args.length >= 2 && args[0] >= 1 && args[1] >= 1;
    }

}


/**
 * A world that is roughly spherical
 * Is three dimensional in topology and homotopic to a sphere
 */
class SphereWorld : World {

    /**
     * Constructs a sphere world
     * Runs the super class constructor solely
     */
    this(double[] args) {
        super(args);
    }

    /** 
     * Generates a pseudo-spherical world
     * Uses two arguments, number of divisions, then the sphere's circumference in tiles
     * Works by generating rings based on the given number of divisions,
     * each having a circumference that would roughly match a sphere at that angle's
     * Each ring's tiles are connected
     * Connection between rings are formed so that there are the minimum possible number of links between layers
     * numDivisions should be at least 1
     */
    override Tile[] generate(double[] args) {
        Tile[][] rings;
        int numDivisions = cast(int) args[0];
        int circumference = cast(int) args[1];
        for(int k = numDivisions; k >= -numDivisions; k--) {
            rings ~= createRing(cast(int) (cos(k * PI_2 / numDivisions) * circumference));
        }
        //Now binds rings to each other; starting with first half
        for(int h = 0; h < rings.length / 2; h++) {
            setRingNeighbors(rings[h], rings[h+1]);
        }
        //Then second half; to ensure the precondition of setting ring neighbors
        for(int h = rings.length - 1; h > rings.length / 2; h--) {
            setRingNeighbors(rings[h], rings[h - 1]);
        }
        return flattenMatrix(rings);
    }

    /**
     * Appropriately binds two rings
     * Works on the condition that first has fewer members than second
     */
    private void setRingNeighbors(Tile[] first, Tile[] second) {
        for(int i = 0; i < first.length; i++) {
            for(int j = 0; j < cast(int) (cast(double) second.length / cast(double) first.length * (i + 1) - i); j++) {
                first[i].neighbors ~= second[i+j];
                second[i+j].neighbors ~= first[i];
            }
        }
    }

    /**
     * Generates a ring of randomized tiles
     */
    private Tile[] createRing(int circumference) {
        if(circumference <= 0) circumference = 1; //if there is a ring of size zero or less, make it size one
        Tile[] ring;
        for(int i = 0; i < circumference; i++) {
            ring ~= new Tile(uniform(0.0, 1.0), uniform(0.0, 1.0), uniform(0.0, 1.0));
            if(i > 0) {
                ring[i].neighbors ~= ring[i - 1];
                ring[i-1].neighbors ~= ring[i];
            }
        }
        ring[0].neighbors ~= ring[ring.length - 1];
        ring[ring.length - 1].neighbors ~= ring[0];
        return ring;
    }

    /**
     * Asserts that there are at least two arguments and that they are positive and at least one
     */
    override bool assertArgs(double[] args) {
        return args.length >= 2 && args[0] >= 1 && args[1] >= 1;
    }

}