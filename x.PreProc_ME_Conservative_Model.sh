#!/bin/sh
# x.PreProc_ME_Conservative_Model.sh

#Orthogonalizes ME-ICA rejected components with respect to the PETCO2hrf trace, the ME-ICA accepted components, motion parameters, and Legendre polynomials (as described in "ICA-based denoising strategies in breath-hold induced cerebrovascular reactivity mapping with multi echo BOLD fMRI")

#Prior to using this script, you should have ran the tedana command and used the outputs of this command in Rica (https://rica-fmri.netlify.app/) to manually accept and reject ICA components
#Rules for classifying ICA components on SharePoint: https://nuwildcat.sharepoint.com/:w:/r/sites/FSM-ANVIL/Shared%20Documents/ResourcesGuides/Multi-echo%20ICA%20classification%20rules.docx?d=w2b995b3b0a02463e8198c511bfb3dc7f&csf=1&web=1&e=FjLGmD
#After running this script, you can use your orthogonalized rejected components as regressors in your GLM for denoising

if [ $# -ne 7 ]
then
  echo "*****************************************************************************************************"
  echo "Insufficient arguments supplied"
  echo "Input 1 should be the full path to your ICA mixing matrix (do not include file extension - assumes txt)"
  echo "Input 2 should be a list of your accepted ICA components (of form [1,2,3])"
  echo "Input 3 should be a list of your rejected ICA components (of form [1,2,3])"
  echo "Input 4 should be the full path to the demeaned PETCO2 trace convolved with the HRF (do not include file extension - assumes txt)"
  echo "Input 5 should be the full path to the demeaned motion parameters (do not include file extension - assumes 1D)"
  echo "Input 6 should be the Legendre polynomial degree"
  echo "Input 7 should be the full path to the output directory"
  echo "*****************************************************************************************************"
  exit
fi

#Define outputs
mixing=${1}
accepted=${2}
rejected=${3}
CO2=${4}
motion=${5}
Legendre_degree=${6}
output_dir=${7}

cd ${output_dir}

#Concatenate accepted and rejected components
1dcat ${mixing}.txt${accepted}   > accepted_tr.1D
1dcat ${mixing}.txt${rejected}   > rejected_tr.1D
1dtranspose rejected_tr.1D > rejected.1D

#Orthogonalize rejected components to accepted components, CO2 trace, motion, and polynomials
3dTproject -ort accepted_tr.1D \
-ort ${CO2}.txt \
-ort ${motion}.1D \
-polort ${Legendre_degree}  \
-prefix rejected_ort_tr.1D \
-input rejected.1D
1dtranspose rejected_ort_tr.1D > rejected_ort.1D
