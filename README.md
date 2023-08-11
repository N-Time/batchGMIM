# batchGMIM
A program to calculate intensity measures (e.g., Sa, PGV, Ia, ...) of ground motions in batch

# How to use?
- The main script is 'GMsuiteSa.m'.
- PSA is calculated by 'responseSpectrum.m' over the period range of PEER records (111 periods);
- Other IMs are calculated by 'intensityCalculate.m', in which more IMs can be added if you want.

# About the output?
- Only show the figure of the PSA of all GMs in the suite;
- All available IMs can be found in the tabel variable 'imTable'.
