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


*------------------------------------------------------------ *
* --- PART II: Production data   ---- *
* ------------------------------------------------------------ *

    *--- 1 - Open DataSet - All Data Sets Together

      * Post-Planting (Season 1)
      use "$path_data/NGA/2010-11/Post_Harvest_Wave_1/Agriculture/secta3_harvestw1.dta", clear

    *--- 2 - Only the data we need
      rename sa3q2 cropcode 
      rename sa3q18 value_sold
      rename sa3q6a q_harvest
      rename sa3q20a q_stored
      rename sa3q21a q_paymentlabor
      rename sa3q22a q_Gift

      replace sa3q16a=0 if sa3q16a==.
      replace sa3q11a=0 if sa3q11a==.
      gen q_sold=sa3q16a+sa3q11a


      keep hhid plotid cropcode value_sold q_*
      drop if cropcode==.

      replace value_sold=0 if value_sold==.

    *---  3 - Include our crop classification
      include "$path_work/do-files/NGA-CropClassification.do"
     

    *-- 4. Fixing value
        foreach i in  q_stored q_paymentlabor q_Gift q_sold {
            replace `i'=0 if `i'==.
        }


        gen total=q_stored+q_paymentlabor+q_Gift+q_sold


        gen x=(total>q_harvest)

        drop if x==1
        gen q_other=q_harvest-total


    * Collapsing the data

      foreach i in _stored _paymentlabor _Gift _other _sold {
            gen share_q`i'=q`i'/q_harvest
        }

      collapse (sum) value_sold (mean) share_q_*, by(hhid tree_type)
    

     *-- 3. Share

      
        *-- Merge with HH data
  merge n:1 hhid using "$path_data/NGA/2010-11/Post_Harvest_Wave_1/Household/secta_harvestw1.dta", nogenerate keepusing(zone state lga sector ea ric wt_wave1) keep(using matched) 

  save "$path_work/NGA/0_CropsSells.dta", replace






