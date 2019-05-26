module tht.Tile;

/**
 * A structure defining various technology levels for a tile
 */
struct Technology {

    double metalwork; ///Develops from hills and mountains, allows for better everything basically
    double husbandry; ///Develops from non-arid, flat terrain, allows for better movement and population growth
    double woodwork; ///Develops from more vegetated areas, allows for faster population growth and movement over oceans
    double warfare; ///Develops from clashing cultures, allows for more effective fighting and boosts other technology

}

/**
 * A tile node on the map
 * Contains information about what culture controls it, 
 * population, technology, etc.
 */
class Tile {

    Tile[] neighbors; ///The tiles neighboring this one

    double topography; ///The topography of the tile; higher value means more elevated/rough
    double humidity; ///The humidity of the tile; higher value means more vegetation
    double temperature; ///The temperature of the tile; higher value means warmer

    int population; ///The population on the tile
    int culture; ///The culture of the tile
    Technology technology; ///The technology of the tile

    /**
     * Constructs a new tile with the given tht values
     */
    this(double topography, double humidity, double temperature) {
        this.topography = topography;
        this.humidity = humidity;
        this.temperature = temperature;
        this.technology = Technology(0, 0, 0, 0);
    }

    /**
     * Gets the population limit of the tile, based on climate 
     * and technology
     */
    int getPopulationLimit() {
        return (10 + this.technology.metalwork / 2 + this.technology.husbandry + this.technology.woodwork / 2) 
                * (centerWeight(this.temperature) + 1 - this.elevation + centerWeight(this.humidity)));
    }

    /**
     * Causes the tile's population to grow based on its climate
     * and other factors; grows in a logistic fashion
     */
    void growPopulation() {
        this.population += (this.temperature + 1 - this.elevation + this.humidity) 
                * (cast(double) this.population / this.getPopulationLimit()) * (this.getPopulationLimit() - this.population);
    }

    /**
     * Develops the technology on this tile
     * Technology develops as a baseline,
     * then also slowly equalizes other technology types
     * TODO: implement technology spreading based on migration/conflict
     */
    void developTech() {
        //Independent tech development
        this.technology.metalwork += (this.topography + (1 - this.temperature) / 4) / 2.5;
        this.technology.husbandry += (1 - this.topography + 1 - this.humidity + (1 - this.temperature) / 5) / 4.4;
        this.technology.woodwork += (this.humidity + (1 - this.temperature) / 2) / 3;
        //Equalization
        this.technology.metalwork += 
                (3 * this.technology.metalwork - this.technology.husbandry - this.technology.warfare - this.technology.woodwork) / 20;
        this.technology.husbandry += 
                (3 * this.technology.husbandry - this.technology.metalwork - this.technology.warfare - this.technology.woodwork) / 20;
        this.technology.woodwork += 
                (3 * this.technology.woodwork - this.technology.metalwork - this.technology.husbandry - this.technology.warfare) / 20;
        this.technology.warfare += 
                (3 * this.technology.warfare - this.technology.metalwork - this.technology.husbandry - this.technology.woodwork) / 20;
    }

    /**
     * Returns a value such that an input closer to 0.5 returns the maximal value
     */
    double centerWeight(double input) {
        return 4 * (input * input + input);
    }

}