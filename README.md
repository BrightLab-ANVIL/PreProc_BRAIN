# PreProc_BRAIN

This code assumes you have a fMRI file and a T1-weighted file.
It does minimal pre-processing of the fMRI data (volume registration, brain extraction) and produces tissue masks in fMRI space, and average time-series over these masks.

Suggested order to run:

1. First run the command 'fsl_anat' to process your T1-weighted anatomical image. The simplest way to do this is to type this into your terminal:

fsl_anat -i _structural-image_ -o _output-directory-path_

Your structural image should be your T1-weighted image that has NOT been brain extracted.
Running the command as above will run with all the defaults settings and give you ALL the outputs.
Many of the outputs are useful so if you don't have space limitations you might as well generate them all.  
See here for details: https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/fsl_anat

In order to run steps (5) and (6) you will need to threshold and binarize the partial volume image of the tissue class of interest.
See the x.PreProc_RUN_Example for more options.

2. x.PreProc_VolReg_4D (motion correction on functional dataset)
3. x.PreProc_BET-4D (brain extraction on functional dataset) OR x.PreProc_Mask-4D (apply the brain mask made from running x.PreProc_BET-4D on a different functional scan in the same space)
4. x.PreProc_TissueReg (register functional and anatomical datasets)
5. x.PreProc_Transform (transform file in T1 space, e.g. tissue masks generated from fsl_anat, to functional space).
6. x.PreProc_MEANTS (output a mean time-series from the functional dataset, masked by a tissue mask)

Each command can be run separately, as explained above, but the recommended way to run all of these functions is to write some parent code that can loop over subjects or scans, calling upon each individual function. An example of this can be seen in the file 'x.PreProc_RUN_Example' in this repo.
