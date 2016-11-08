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
* --- PART I: Planting data   ---- *
* ------------------------------------------------------------ *

    *--- 1 - Open DataSet - All Data Sets Together

      * Post-Planting (Season 1)
      use "$path_data/NGA/2010-11/Post_Planting_Wave_1/Agriculture/sect11g_plantingw1.dta", clear

      append using "$path_data/NGA/2010-11/Post_Planting_Wave_1/Agriculture/sect11f_plantingw1.dta"

    *--- 2 - Only the data we need
      rename s11gq1a t_area

      local heaps="0.00012 0.00016  0.00011 0.00019 0.00021 0.00012"
      local ridges="0.0027 0.004 0.00494 0.0023 0.0023 0.00001"
      local stands="0.00006 0.00016 0.00004 0.00004 0.00013 0.00041"
      forvalue i=1/6 {
        local conv_1: word `i' of `heaps'
        local conv_2: word `i' of `ridges'
        local conv_3: word `i' of `stands'
        replace t_area=t_area*`conv_1' if zone==`i' & s11gq1b==1
        replace t_area=t_area*`conv_2' if zone==`i' & s11gq1b==2
         replace t_area=t_area*`conv_3' if zone==`i' & s11gq1b==3
      } 
      replace t_area=t_area*0.0667 if s11gq1b==4
      replace t_area=t_area*0.4 if s11gq1b==5
      replace t_area=t_area*0.0001 if s11gq1b==7
      replace t_area=0 if s11gq1b==8

      rename s11gq2 t_n_trees 

      keep hhid plotid cropcode t_n_trees t_area
      drop if cropcode==.

    *---  3 - Include our crop classification
      
      include "$path_work/do-files/NGA-CropClassification.do"

      gen d_peper=(cropcode==2140)
      gen d_yam=(cropcode==1124)
  
      tab d_peper if tree_type=="Tree Cash Crops"
      tab d_yam if tree_type=="Tree Cash Crops"

    *---  4 - Collapse information
        gen x=1
        collapse (sum) n_parcels=x t_area t_n_trees ,by( hhid plotid tree_type)

    *-- 5. We identify whether the Parcel has more than one crop (i.e. Inter-cropped)

            bys hhid plotid: gen n_crops_plot=_N
            gen inter_crop=(n_crops_plot>1 & n_crops_plot!=.)
            drop n_crops_plot

    *-- 7. Reshape the data for the new crops system

            encode tree_type, gen(type_crop)
            *1 Fruit Tree
            *2 Plant/Herb/Grass/Roots
            *3 Tree Cash Crops   
            drop tree_type
            order hhid plotid type_crop
            reshape wide n_parcels t_area t_n_trees , i(hhid plotid) j(type_crop)

    *--- 8. Rename Variables 
            global names "Tree_Fruit Plant Tree_Agri"
            local number "1 2 3"
            
            local i=1
            foreach y of global names {
                local name: word `i' of `number'
                foreach h in n_parcels t_area t_n_trees {
                rename `h'`name' `h'_`y'
                replace `h'_`y'=0 if `h'_`y'==.
                }
                local i=`i'+1
            }

     save "$path_work/NGA/0_CropsClassification.dta", replace

