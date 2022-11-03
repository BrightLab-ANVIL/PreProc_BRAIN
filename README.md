# PreProc_BRAIN

This collection of code assumes you have a fMRI file and a T1-weighted file in nii.gz format.
It does minimal pre-processing of the fMRI data and produces tissue masks in fMRI space, and outputs average time-series over these masks.
If you have collected reverse phase encode scans which allow you to make field maps it also performs distortion correction of the fMRI file.

There are 11 functions. Each function can be run separately but the recommended way to run all of these functions is to write some parent code that can loop over subjects or scans, calling upon each individual function. A template for this can be seen in the file 'x.PreProc_RUN_Template' in this repo. The suggested way to interact with these functions is to only copy the x.PreProc_RUN_Template into your own repo, rename it something related to your project, and make edits to this RUN file only, calling upon the functions in this repo but not changing these individual functions.

Suggested order to run:

1. x.PreProc_BET-anat (brain extraction on anatomical dataset)
2. x.PreProc_SEG-anat (tissue segmentation on anatomical dataset)
(An alternative to 1 and 2 would be to run fsl_anat which has further features)
3. x.PreProc_VolReg_4D (motion correction on functional dataset)
OR x.PreProc_VolReg_4D_ME (motion correction on multi-echo functional dataset)
4. x.PreProc_DistortCorrect (make field map and perform distortion correction) **Think about whether it makes sense to do this as step 4 in your dataset. It may depend on what inputs you use and what your reference is for VolReg_4D**
5. x.PreProc_BET-4D (brain extraction on functional dataset) OR x.PreProc_Mask-4D (apply the brain mask made from running x.PreProc_BET-4D on a different functional scan in the same space)
6. x.PreProc_TissueReg_func2anat (register functional and anatomical datasets)
7. x.PreProc_TissueReg_func2stand (register functional/anatomical and standard datasets)
8. x.PreProc_Transform_lin (linear transformation of functional <-> anatomical space)
9. x.PreProc_Transform_nonlin (nonlinear transformation of functional <-> standard space)
10. x.PreProc_MEANTS (output a mean time-series from the functional dataset, masked by a tissue mask)
