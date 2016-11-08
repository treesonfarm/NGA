*-------------------------------------------------------------*
*-------------------------------------------------------------*
*                     Trees on Farm:                          *
*    Prevalence, Economic Contribution, and                   *
*   Determinants of Trees on Farms across Sub-Saharan Africa  *
*                                                             *
*             https://treesonfarm.github.io                   *
*-------------------------------------------------------------*
*   Miller, D.; Muñoz-Mora, J.C. and Christiaense, L.         *
*                                                             *
*                     Nov 2016                                *
*                                                             *
*             World Bank and PROFOR                           *
*-------------------------------------------------------------*
*                   Replication Codes                         *
*-------------------------------------------------------------*
*-------------------------------------------------------------*


* ------------------------------------------------------------ *
* --- PLOT SIZE AND HH WITH PLOTS   ---- *
* ------------------------------------------------------------ *

  *-- Open data on area

    use "$path_data/NGA/2010-11/Post_Planting_Wave_1/Agriculture/sect11a1_plantingw1.dta", clear

  *-- Fix area (mt2)
    gen are_orig=s11aq4d
    gen plot_size=s11aq4d*0.0001

    local heaps="0.00012 0.00016  0.00011 0.00019 0.00021 0.00012"
      local ridges="0.0027 0.004 0.00494 0.0023 0.0023 0.00001"
      local stands="0.00006 0.00016 0.00004 0.00004 0.00013 0.00041"
      forvalue i=1/6 {
        local conv_1: word `i' of `heaps'
        local conv_2: word `i' of `ridges'
        local conv_3: word `i' of `stands'
        replace s11aq4d=s11aq4d*`conv_1' if zone==`i' & s11aq4b==1
        replace s11aq4d=s11aq4d*`conv_2' if zone==`i' & s11aq4b==2
         replace s11aq4d=s11aq4d*`conv_3' if zone==`i' & s11aq4b==3
      } 
      replace s11aq4d=s11aq4d*0.0667 if s11aq4b==4
      replace s11aq4d=s11aq4d*0.4 if s11aq4b==5
      replace s11aq4d=s11aq4d*0.0001 if s11aq4b==7
      replace s11aq4d=0 if s11aq4b==8

      replace plot_size= s11aq4d if plot_size==.

  *-- Keep data
  keep hhid plotid plot_size

  *-- Merge Data
  merge 1:1 hhid plotid  using "$path_work/NGA/0_CropsClassification.dta",keep(master matched)
  drop if plot_size==. & _merge==1
  drop _merge

* Ficing data 
 foreach i in n_parcels_Tree_Fruit n_parcels_Plant n_parcels_Tree_Agri {
        replace `i'=(`i'>0 & `i'!=.)
      }

  *-- 5. Fixing information For Inter-cropping and 

      foreach i in  _Tree_Fruit _Plant _Tree_Agri {
        gen inter_n`i'=inter_crop*n_parcels`i'
      }

      * Estimating the share by crop 
        preserve
        keep hhid plotid plot_size t_area_* inter_*
          foreach i in t_area_Tree_Fruit t_area_Plant t_area_Tree_Agri {
            replace `i'=0 if `i'==.
          }
        gen total= t_area_Tree_Fruit+t_area_Plant+t_area_Tree_Agri
        gen share_Tree_Fruit=t_area_Tree_Fruit/total
        gen share_Tree_Agri=t_area_Tree_Agri/total
        recode share_Tree_Agri  share_Tree_Fruit (.=0)
        save "$path_work/NGA/0_shares_crops.dta", replace
        keep hhid plotid share_Tree_Fruit share_Tree_Agri
        restore

  *-- 6. Adding HH information

       foreach i in t_area_Tree_Fruit t_area_Plant t_area_Tree_Agri {
            replace `i'=0 if `i'==.
          }

    gen t_area_pre_trees=plot_size if t_area_Tree_Fruit>0|t_area_Tree_Agri>0
    replace t_area_pre_trees=0 if t_area_pre_trees==.

     foreach i in _Tree_Fruit _Tree_Agri  {
      gen t_area_pre`i'=plot_size if t_area`i'>0
      replace t_area_pre`i'=0 if t_area_pre`i'==.
    }


    gen x=1
    collapse (sum)  t_area_* t_n_trees_* n_parcels_* inter_n* inter_crop farm_size=plot_size n_plots=x, by(hhid)


  *-- Merge with HH data
  merge 1:1 hhid using "$path_data/NGA/2010-11/Post_Harvest_Wave_1/Household/secta_harvestw1.dta", nogenerate keepusing(zone state lga sector ea ric wt_wave1) keep(using matched) 

  save "$path_work/NGA/1_Plot-Crop_Information.dta", replace

