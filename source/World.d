module tht.World;

import tht.Tile;

import std.math;
import std.random;

/***
 * This file does not define a class, instead it contains functions for creating node based worlds
 * At present it creates rectangular and spherical worlds
 */


/**
 * Generates a rectangular world
 * Is nrows x ncols
 * Randomly assigns tht values to tiles
 * Works by generating a matrix for past reference,
 * then flattens the matrix
 */
Tile[] generateRectangleNetwork(int nrows, int ncols) {
    Tile[][] tileMatrix;
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
 * Flattens a matrix of tiles into a one-dimensional array
 */
Tile[] flattenMatrix(Tile[][] matrix) {
    Tile[] allTiles;
    for(int x = 0; x < matrix.length; x++) {
        for(int y = 0; y < matrix[x].length; y++) {
            allTiles ~= matrix[x][y];
        }
    }
    return allTiles;
}

/** 
 * Generates a pseudo-spherical world
 * Works by generating rings based on the given number of divisions,
 * each having a circumference that would roughly match a sphere at that angle's
 * Each ring's tiles are connected
 * Connection between rings are formed so that there are the minimum possible number of links between layers
 * numDivisions should be at least 1
 */
Tile[] generateSphereNetwork(int numDivisions, int circumference) {
    Tile[][] rings;
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
void setRingNeighbors(Tile[] first, Tile[] second) {
    for(int i = 0; i < first.length; i++) {
        for(int j = 0; j < cast(int) (cast(double) second.length / cast(double) first.length * (i + 1) - i); j++) {
            first[i].neighbors ~= second[i+j];
            second[i+j].neighbors ~= first[i];
        }
    }
}

/*
Binding Algo:
for i in range(len(first)):
	for j in range(int(len(second) / len(first) * (i + 1) - i)):
		print("%s binds to %s" % (first[i], second[i + j]))
 */

/**
 * Generates a ring of randomized tiles
 */
Tile[] createRing(int circumference) {
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