#!/bin/sh
# x.PreProc_ME_Conservative_Model.sh

# Orthogonalizes ME-ICA rejected components with respect to the PETCO2hrf trace, the ME-ICA accepted components, motion parameters and their derivatives, and Legendre polynomials (as described in "ICA-based denoising strategies in breath-hold induced cerebrovascular reactivity mapping with multi echo BOLD fMRI")

# Prior to using this script, you should have...
# 1 - Ran the tedana command and used the outputs of this command in Rica (https://rica-fmri.netlify.app/) to manually accept and reject ICA components
#     Rules for classifying ICA components on SharePoint: https://nuwildcat.sharepoint.com/:w:/r/sites/FSM-ANVIL/Shared%20Documents/ResourcesGuides/Multi-echo%20ICA%20classification%20rules.docx?d=w2b995b3b0a02463e8198c511bfb3dc7f&csf=1&web=1&e=FjLGmD

# 2 - Trimmed the same number of volumes from the start of PETCO2hrf regressor as you did from the fMRI data.

# After running this script, you can use your orthogonalized rejected components as regressors in your GLM for denoising.
# The output "rejected_ort.1D" contains the components in columns.


if [ $# -ne 9 ]
then
  echo "*****************************************************************************************************"
  echo "Insufficient arguments supplied"
  echo "Input 1 should be the full path to desc-ICA_mixing.tsv file (include file extension)"
  echo "Input 2 should be the full path to the manual_classification.tsv file (include file extension)"
  echo "Input 3 should be the full path to the demeaned PETCO2 trace convolved with the HRF (do not include file extension - assumes .txt)"
  echo "Input 4 should be the number of extra TRs added before and after the scan (assumes equal # added before and after)."
  echo ""         
  echo "        For example, if 20 TRs were added to both the beginning AND end of the scan (40 extra TRs total), you would enter 20 here."
  echo ""
  echo "Input 5 should be the number of TRs in the scan (before extra TR padding, and accounting for volumes removed from the start.)"
  echo ""
  echo "        NOTE: If you trimmed volumes from the start of your fMRI data, then you should have 1) removed the same
                number of volumes from the start of the PETCO2hrf regressor and 2) the number of TRs should reflect this.
                For example, if you removed 10 TRs from your fMRI data AND added 20 extra TRs to your PETCO2hrf, you
                would remove 10 TRs from the start of your PETCO2hrf with extra padding trace. (It works out.)"
  echo ""  
  echo "Input 6 should be the full path to the demeaned motion parameters (do not include file extension - assumes .1D)"
  echo "Input 7 should be the full path to the demeaned motion parameter derivatives (do not include file extension - assumes .1D)"
  echo "Input 8 should be the Legendre polynomial degree"
  echo "Input 9 should be the full path to the output directory"
  echo "*****************************************************************************************************"
  exit
fi

#Define outputs
ica_mix=${1}
man_class=${2}
CO2=${3}
extraTR=${4}
nTR=${5}
motion=${6}
Dmotion=${7}
Legendre_degree=${8}
output_dir=${9}

cd ${output_dir}


# Find REJECTED component numbers from tedana file 
columnNumber=$(awk -F'\t' 'NR==1 {for (i=1; i<=NF; i++) if ($i == "classification") print i; exit}' "${man_class}")
manRej=`cut -f${columnNumber} ${man_class} | tail -n +2 | grep -n rejected | cut -d : -f1 | tr "\n" " "`

manRejArr=( $manRej ) #change string to array
for (( i = 0 ; i < ${#manRejArr[@]} ; i++ )) do  (( manRejArr[$i]=${manRejArr[$i]} - 1 )) ; done #subtract 1 from each number to start indexing at 0

printf -v manRejCom '%s,' "${manRejArr[@]}" #separate array by commas instead of spaces

# Create file with REJECTED components
1dcat ${ica_mix}[${manRejCom[@]}] > ${output_dir}/rejectedTrans.1D
1dtranspose ${output_dir}/rejectedTrans.1D > ${output_dir}/rejected.1D



# Find ACCEPTED component numbers from tedana file
# Rica code outputs classifications to column 17
manAcc=`cut -f17 ${man_class} | tail -n +2 | grep -n accepted | cut -d : -f1 | tr "\n" " "`

manAccArr=( $manAcc ) #change string to array
for (( i = 0 ; i < ${#manAccArr[@]} ; i++ )) do  (( manAccArr[$i]=${manAccArr[$i]} - 1 )) ; done #subtract 1 from each number to start indexing at 0

printf -v manAccCom '%s,' "${manAccArr[@]}" #separate array by commas instead of spaces

# Create file with ACCEPTED components
1dcat ${ica_mix}[${manAccCom[@]}] > ${output_dir}/acceptedTrans.1D
1dtranspose ${output_dir}/acceptedTrans.1D > ${output_dir}/accepted.1D



# Convert CO2 file to 1D so you can select appropriate volumes (ignore any extra TRs added before/after)
1d_tool.py -infile ${CO2}.txt -write ${CO2}.1D

# Calculate last volume number
last=$((${nTR}+${extraTR}-1)) #python indexing starts at 0
# Note: extraTR = the first TR since python indexing starts at 0

# Orthogonalize rejected components to accepted components, CO2 trace, motion, motion derivatives, and polynomials
3dTproject -ort acceptedTrans.1D \
-ort ${CO2}.1D"{$extraTR..$last}" \
-ort ${motion}.1D \
-ort ${DMotion}.1D \
-polort ${Legendre_degree}  \
-prefix rejectedTrans_ort.1D \
-input rejected.1D
1dtranspose rejectedTrans_ort.1D > rejected_ort.1D

