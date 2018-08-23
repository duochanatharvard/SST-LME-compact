# __SST_Homo_compact__
Inter-comparison of collocated ICOADS pairs using linear mixed effect model.
This package contains the core scripts and functions used in paper:

__Chan and Huybers__ (2019), Systematic differences in bucket sea surface temperature measurements amongst nations identified using a linear mixed effects method.


----
__SST_Homo_compact__ has several parts:
1. __Step__: Main scripts used to call other functions
2. __Pair__: A toolbox that pairs ICOADS measurements.
3. __LME__: LME toolbox used to estimate relative biases given pairs of measurements
4. __Function__: A toolbox that contains functions of significant tests, gridding, average, masks, etc.
5. __Visualization__: scripts used to generate figures and tables.
6. __Data__: Binned files that can be directly used to do LME estimates and other metadata.
7. __Figures__: Figures used in the papers.
----

__SST_Homo_compact__ provides an option for users to quickly reproduce the LME results without preprocessing ICOADS data and pairing adjacent records. To use this function, you can skip step 1 to 2 in the next section and directly run the 3rd step with parameter __do_fast__ equals to 1 and copy the following binned files from ```Data``` folder to ```/Hvd_SST/HM_SST_Bucket/Step_04_run/```.

````
BINNED_HM_SST_Bucket_yr_start_1850_deck_level_0_cor_err.mat
BINNED_HM_SST_Bucket_yr_start_1850_deck_level_0_eq_wt.mat
BINNED_HM_SST_Bucket_yr_start_1850_deck_level_1_cor_err.mat
BINNED_HM_SST_Bucket_yr_start_1850_deck_level_1_eq_wt.mat
````

See below for file structures:

![new-repository-button](/Figures/File_structure.png)


__IMPORTANT__: Please set up directories in ```HM_OI.m``` and make sure that all the directories exist before running any analyses. Also, please refer to the above figure for the data structure that I use.

__IMPORTANT__: You may also need ```colormap_CD``` toolbox to reproduce figures. ```colormap_CD``` is a series of scripts that generate harmonic and distinguishable colormaps for Matlab, developed by Duo Chan. You can get the toolbox
[__here__](https://github.com/duochanatharvard/colormap_CD).


----
## __Steps for LME based inter-comparison__

1. __Preprocessing__: Full analyses start from pre-processing ICOADS data from IMMA format to mat files and perform quality controls. Details of these steps can be found in [__ ICOADS_preprocess__](https://github.com/duochanatharvard/ICOADS_preprocess) project.

  To skip this step, please download the preprocessed data from  [__here__](https://github.com/duochanatharvard/ICOADS_preprocess).

---

2. __Pairing__: ```HM_Step_01_Run_Pairs.m``` and ```HM_Step_02_SUM_Pairs.m``` pick out pairs that are 300km in distance and 2 days in time.

  ```HM_Step_01_Run_Pairs.m``` first calls ```HM_pair_01_Raw_Pairs.m``` in ```Pair``` folder that pairs records whenever the displacement criteria is met.

   ```HM_Step_01_Run_Pairs.m``` then calls ```HM_pair_02_Screen_Pairs.m``` that sorts the pairs by spatial displacements (unit: rad in great circle distance) + temporal displacements (unit: half day) and pick out pairs starting from the smallest distance and only using individual records once.  

  ```HM_pair_02_Screen_Pairs.m``` also match diurnal signal for SST data. You can choose to comment out related lines in the scripts and the results are not sensitive. Or copy the following two files from the ```Data``` folder in ```Code``` directory to the ```Miscellaneous``` folder in ```Hvd_SST``` directory.

  ```
  DA_SST_Gridded_BUOY_sum_from_grid.mat
  Diurnal_Shape_SST.mat
  ```

  ```HM_Step_02_SUM_Pairs.m``` sums screened pairs and save all pairs into one single mat file.

    To skip this step, please download the pooled pairs from  [__here__](https://github.com/duochanatharvard/ICOADS_preprocess) and place it in
```/Hvd_SST/HM_SST_Bucket/```

----

3. __LME__: ```HM_Step_03_LME.m``` calls the LME toolbox and uses a linear-mixed-effect method to estimate relative offsets in the SST pairs.
  Work flow of the```LME``` toolbox is as follow:

  ```
Pooled pairs -- HM_lme_bin.m --> Aggregate pairs -- HM_lme_fit.m --> Offsets estimates
  ```

  ```HM_Step_03_LME.m``` calls single-layer LME model for nation-level analysis and hierarchical LME model for deck-level analysis, which is tuned by parameter __do_Npd__.    

  Users can choose from two different error models in the fitting, one assuming independent and identically distributed pairs, and the other taking into account spatially heterogeneous SST variance and correlations between pairs. This can be tuned by parameter __do_correct__. To compute with the latter model, it requires statistics of SST based on OI-SST, which will be used by ```HM_lme_var_clim.m``` to compute for SST variances. Please download the file from [__here__](https://github.com/duochanatharvard/ICOADS_preprocess) and move it to the ```Miscellaneous``` folder.

  __SST_Homo_compact__ provides an option for users to quickly reproduce the LME results without preprocessing ICOADS data and pairing adjacent records. To use this function, you can skip step 1 to 2 in the next section and directly run the 3rd step with parameter __do_fast__ equals to 1 and copy the following binned files from ```Data``` folder to ```/Hvd_SST/HM_SST_Bucket/Step_04_run/```.

  ````
  BINNED_HM_SST_Bucket_yr_start_1850_deck_level_0_cor_err.mat
  BINNED_HM_SST_Bucket_yr_start_1850_deck_level_0_eq_wt.mat
  BINNED_HM_SST_Bucket_yr_start_1850_deck_level_1_cor_err.mat
  BINNED_HM_SST_Bucket_yr_start_1850_deck_level_1_eq_wt.mat
  ````

---

## __Memos for generating LME related figures__

Fig. __4__, Offsets for national analysis assuming independent and identically distributed (i.i.d.) pairs.

![new-repository-button](Figures/Method/20180725_Fixed_Yearly_Effects_case_1.png)

run ```HM_figure_Bias_fixed_and_yearly(1)```. Here, ```case_id``` is 1, which means to use case of i.i.d. pairs. Change this to 2 to plot for the case accounting for heterogenous SST variance and correlated pairs.

---

Fig. __6__, Pair-wise significance test assuming i.i.d. pairs.

![new-repository-button](Figures/Method/20180708_Significant_test_Global_start_1850_case_1.png)

run ```HM_figure_pair_wise_sig_and_time_series(0,1)```. Two arguments are do_NpD, and case_id. When do_NpD equals to 0, means nation-level analysis, else are deck-level analysis.

----

Fig. __8__ and __9__, Deck-level pair-wise significant tests, and offsets of individual decks assuming i.i.d. pairs.

![new-repository-button](Figures/Method/20180708_SUM_sig_case_1.png)
![new-repository-button](Figures/Method/20180708_SUM_time_series1.png)

run ```HM_figure_pair_wise_sig_and_time_series(1,1)```.  

----

Fig. __13__, Comparison of results for sensitivity test.

![new-repository-button](Figures/Method/FigAA_Compare_ship_level_0.png)

Change case_id in ```HM_figure_compare_effects.m``` and run that script.

---
