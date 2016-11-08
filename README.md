### Replication WebSite - Nigeria

## Main Findings Overview

*Percent of landholders with presence of any trees on farms:* | 16% (85.91% intercropped) 
*Percent of landholders with presence of fruit trees:* | 6% (91.89% intercropped)
*Percent of landholders with presence of tree cash crops:* | 15% (86.67% intercropped)
*Percent of landholders with presence of trees for timber or fuelwood:* | NA

## LSMS-ISA data sets and Sampling

 [Get Raw Data](http://econ.worldbank.org/WBSITE/EXTERNAL/EXTDEC/EXTRESEARCH/EXTLSMS/0,,contentMDK:23635521~pagePK:64168445~piPK:64168309~theSitePK:3358997,00.html)

# Sampling weight

The weights reported on the LSMS-ISA surveys are household weights. The surveys followed a two stage sampling process. In the first stage the clusters were selected, given the desired level of stratification of the survey (i.e. rural/urban, district level, agroecological zones, etc), the first stage weights are calculated as the probability of any given EA to be selected out the whole population of EA's. In the second stage households are selected within a given cluster (EA), the second stage weights are calculated as the probability of any given household in the cluster to be selected. The household weights are the multiplication of the first and second stage weights.

In Stata, in order to take into account the sampling design, we use the following syntaxis:

```
svyset ea [pweight=wght], strata(state) singleunit(centered)
```

## Information Available for studying Trees On Farm

# Crop Classification
\# Total Crops Listed 			|	104
% Fruit Trees					|	18.27%
% Tree Cash Crops				|	20.19%
% Trees for timber and fuel-wood|	NA

# Information on planting

\# Trees						|	Yes
Area Planted					|	Yes
Year of plantation				|	No
Cropping System					|	Yes
Use of non-cultivated land 		|	No (only fallow)
Different module for trees 		|	Yes
Seasons with Information on planting 		|	Post-planting


# Information on harvesting

Quantity harvested  			|	Yes
Quantity Sold 					|	Yes
Total Value						|	Yes
Self Consumption				|	No
Seasons with information on harvesting 		|	Post-harvest

## Replication Repository

All the codes and datasets could be directly retrieved from the Github repository: [https://github.com/treesonfarm/NGA](https://github.com/treesonfarm/NGA). If you prefer to get the zip-file of the repository you can follow this [link](https://github.com/treesonfarm/NGA/zipball/master/)

If you are Git users, you can directly clone our repository: 

```
git clone https://github.com/treesonfarm/NGA.git
```

If you have any question or comment about our codes and datasets, don't hesitate to contact us. 

## Data Sets

We provide a Stata dataset compatible with stata 12 or higher, with the main variables to study trees on farm **(NGA_TreesOnFarm_8Nov2016.dta)**. In this database, you can get the following variables:

ID_Trees 				|ID for Trees On farm
[country HH ID]			|This a country specific HH id
n_parcels_Tree_Fruit 	|# parcels with presence of  Fruit Trees
n_parcels_Tree_Agri 	|# parcels with presence of Tree Cash Crops
n_parcels_Tree_wood 	|# parcels with with presence of Trees for Timber or Fuel-Wood
t_area_Tree_Fruit 		|Area (ha) with presence of Fruit Trees
t_area_Tree_Agri 		|Area (ha) with presence of Tree Cash Crops
t_area_Tree_wood 		|Area (ha) with presence of Trees for Timber or Fuel-Wood
t_area_pre_trees 		|Share of Farmland with presence of Trees
t_area_pre_Tree_Fruit 	|Share of Farmland with presence of Fruit Trees
t_area_pre_Tree_Agri 	|Share of Farmland with presence of Tree Cash Crops
t_area_pre_Tree_wood 	|Share of Farmland with Presence of Trees for Timber or Fuel-Wood
t_n_trees_Tree_Fruit 	|# Fruit Trees
t_n_trees_Tree_Agri 	|# Tree Cash Crops
t_n_trees_Tree_wood 	|# Trees for Timber or Fuel-Wood


## Replication Codes

All our codes use relative paths. So, if you would like to include directly our codes, we only need to set the following two global variables:

```
global path_work  "[where do you want to save your outputs]"
global path_data  "[where do you have the LSMS-ISA Raw data]"
```
We made our codes to make self-explained, however if you any question about replicating our results we will be happy to clarify your questions.

# Crop Classification

The crop classification was made using all the crops listed throughout the different waves. So, although we only used one wave, you should be able to replicate our classification for all waves. Based on the crop-level data set,  you can directly include our codes to classify the crops.

```
include "NGA-CropClassification.do"
```

As a result, you will have a crop-level dataset with a new string variable **tree_type**, which indicates the classification for each crop. In particular:

1. Fruit Tree 						
2. Tree Cash Crops 				
3. Plant/Herb/Grass/Roots			
4. Trees for timber and fuel-wood 	
5. NA 								

For more information about our classification see the different publications from our project.

## Stock of Trees On Farm

- Part 1: Building plot-level information

In order to build the total stock of trees on farm at household level, we first need to get the aggregation by plot level. In this code, we get all information from planting and then we collapsed our information to the different measures on presence, extension and area planted by the different crop classification.

```
include "NGA-0_Stock_TreesOnFarm.do"
```

As a result, you will have a data set at plot level with different the variables describes above in the dataset at plot level.

- Part 2: Building household-level information

Once we have the information aggregated at household-plot level, we proceed to build the household level data set. In this do-file we merge the crop level information with the complementary data set on plot and household characteristics to build the household-level information.

```
include "NGA-1_SamplingPlotSize.do"
```

As a result, we will have the same variables as those contain at **NGA_TreesOnFarm_8Nov2016.dta**.

# Total Sells 

Another alternative analysis is the harvesting and sells for the crops by our classification. So, once we have the crop-level classification, we build the aggregation for total production harvested and sell by type of crop. You can include our do-file in this manner:

```
include "NGA-1_Harvesting_Sells.do"
```

## Shapefile

Using the coordinates available from LSMS-ISA, we built the spatial distribution of the stock of trees on farm. Data was generated using the coordinate reference system: WGS 84 (EPSG:4326).

> LSMS-ISA surveys provide modified coordinates to protect household confidentiality, by introducing a random distortion of 0-5km from the original location of the rural household. For more details on this type of mNGAod and its implications for statistical inference see [Perez-Heydrich et al. (2013)](http://dhsprogram.com/publications/publication-SAR8-Spatial-Analysis-Reports.cfm).

The shapefile has seven variable at the attribute table: 

ID_trees:		| ID used for our project
Country :		| Country
Fruit_tree:		| Presence Fruit Trees	 (yes=1)
Tree_Cash:		| Presence Tree Cash Crops (yes=1)
Tree_Wood:		| Presence of Trees for timber and fuel-wood (yes=1)
Latitude:		| Modified HH Latitude
Longitude:		| Modified HH Latitude

In order to merge the shapefile with the entire LSMS-ISA data set, you can use the dataset from the stock trees on farm. It will guarantee a 1:1 merge.

