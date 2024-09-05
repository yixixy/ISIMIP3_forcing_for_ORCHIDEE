This repository provides the Matlab code and auxillary files to make climate forcing (including two spatial resolutions: 1deg and 2deg) for ORCHIDEE-MICT using ISIMIP3 datasets.

* Date and name of the person who retrieved and prepared the data
  Date: 2021-11-07 for 1deg, 2024-04-08 for 2deg
  Name: Yi XI

* Explanation of the origin of the data
  The original data were downloaded from https://data.isimip.org/search/tree/ISIMIP3a/InputData/climate/ for the obsclim senario and from https://data.isimip.org/search/tree/ISIMIP3b/InputData/climate/ for historical and 3 ssps scenarios.
  The initial spatial resolution is 0.5 by 0.5 degree.
  There are five climate models for each scenario, including 'GFDL-ESM4', 'UKESM1-0-LL', 'MPI-ESM1-2-HR', 'IPSL-CM6A-LR', and 'MRI-ESM2-0'.

* Explanation of any transformations of the data
  The arithmetic mean value was used when transferring the original spatial resolution to the new resolution.
  The day 366 from the original data was omitted for all years.

* Policy for use or acknowledgments
  Please acknowlegde the efforts by Yi XI (yixi@pku.edu.cn) when using the code in your researches, thanks.
