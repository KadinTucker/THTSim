# THTSim
THTSim is a deterministic agent based simulation intended to model societies based on geographic determinism.
THT stands for Topography, Humidity, Temperature, the three geographic determiners in the simulation aside from the effects of neigboring cells.
The simulation works by having distinct cultures at the start that grow in population and spread to adjacent tiles. Cultures then clash with one another as well as develop technology based on their geography. 

# The Rules

## Population Growth
Each tile grows in population by a logistic model, meaning that it grows exponentially but at a decreasing rate as the population reaches its carrying capacity.

Carrying capacity is determined by the climate of the tile as well as the technology. The preferences for the population limit are:
- medium temperature
- lower elevation
- medium humidity

The rate of growth is slightly different, as it is scaled by different climatic preferences:
- higher temperature
- lower elevation
- higher humidity

The effect of this is that faster growing locations may have the potential to cause more spreading of population

## Migration
Populations migrate based on a number of factors. A tile's entire population may migrate all at once given perfect conditions.

Like growth, populations have preferences for their migration to other tiles:
- medium temperature
- lower elevation
- medium humidity

Which are the same as the preferences for population capacity. 

The number of migrants is split across all of a tile's neighbors, then modified based on the above preferences and the population capacity of the destination. 

The perfect conditions for migrating all of a population's people out is if all of its neighboring tiles have values of 0.5 temperature, 0 elevation, and 0.5 humidity, and have no population. This is very unlikely to happen anywhere.

Conflict between cultures is yet to be developed or planned with exact rules.

## Technology
Tiles also have technology values, which develop over time. Technology is divided into four categories:
- metalwork
- woodwork
- husbandry
- warfare

These each represent broad categories of technological development. Technology develops over time in tiles based on their climate.
- metalwork develops from higher elevation
- woodwork develops from higher humidity
- husbandry develops from lower elevation and lower humidity
- warfare develops from conflict with other cultures
- lower temperature gives a small boost to all development

Technology also benefits itself; having excess metalwork technology gives a slight boost to other types of technology, as goes for all other types.
Technology spreads along with migrants. Migrants coming from a place with higher technology spread their technology proportionately to their destination based on the volume of migrants to how many people are already at the destination. 