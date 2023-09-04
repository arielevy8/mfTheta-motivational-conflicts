# mfTheta-motivational-conflicts
Code that was used for the paper ["Midfrontal Theta as an Index of Conflict Strength in Approach-Approach vs. Avoidance-Avoidance Conflicts", SCAN, 2023](https://doi.org/10.1093/scan/nsad038) Including an interactive preprocessing pipeline and helpful scripts for extracting and analyzing EEG data. 

The scripts were originally built for experimental data obtained in Kleiman lab at the Hebrew University of Jerusalem, using the Biosemi Active-two system with 64 electrodes. 

Raw and processed datasets that were used in the study can be found here:  https://osf.io/tezrj/

Please contact me (ariel.levy2@mail.huji.ac.il) regarding any need for clarification. 

## Contents

#### Preprocessing_Pipeline.mlx

This live script contains the essential steps in a standard preprocessing of EEG data using the [EEGLAB](https://sccn.ucsd.edu/eeglab/index.php) and [ERPLAB](https://erpinfo.org/erplab) MATLAB packages. preprocessing steps includes:
- High-pass and low-pass filters
- Removal and interpolation of noisy channels
- Re-refrencing
- ICA Decomposition to remove blinks and eye-movements
- Assigning bins and epoch the data
- Stimulus-locked and response-locked averaging

To make sure this script will work properly, data should be organized in a format where the data of each
subject is in a different folder with the name 'Data_**subject number**', and all of these folders should be under
one main folder. The main folder should also contain a BDF - a text file with bin epoching data.

#### extract_eeg_measures.m

This script computes all EEG-based measurements that were used in the study, including:
- Time-frequancy decomposition for both conditions
- Summarised theta power over a given time window
- ERP indices (peak amplitude and peak latency) for three known conflict-related ERPs (N2, CRN and LPC)
In addition, this script performs a cluster-permutations test on midfrontal theta.
Finally, this script contains visualization of spectral and ERP data: Time-frequancy plots, scalp maps and cluster-permutations test results.

#### EEG_analysis.R

This script was used for most of the statistical analysis, including t-tests for the EEG-based measures and linear mixed-effects models on the relationship between midfrontal theta and response-times. 
