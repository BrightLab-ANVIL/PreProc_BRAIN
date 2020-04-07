# PreProc_BRAIN

This code is written to be general, and written so you can write some parent code that can loop over subjects or scans and call upon each individual function. 

Suggested order to run:

1. x.PreProc_VolReg_4D (motion correction on functional dataset)
2. x.PreProc_BET-4D (brain extraction on functional dataset)
3. (Optional) x.PreProc_Mask-4D (apply the brain mask made from step 2 to more functional datasets)
4. x.PreProc_BET-anat (brain extraction on anatomical dataset)
5. x.PreProc_SEG-anat (tissue segmentation on anatomical dataset)
6. x.PreProc_TissueReg (register functional and anatomical datasets)
7. x.PreProc_Transform (transform anatomical to functional space, or vice versa)

IMPORTANT: If you transform a mask (zeroes and ones) with x.PreProc_Transform, the mask in the new space will no longer be binary. It needs to be thresholded and binarized again. This is explained in [this issue](https://github.com/BrightLab-ANVIL/PreProc_BRAIN/issues/9)

8. x.PreProc_MEANTS (output a mean time-series from the functional dataset, masked by some anatomy)
