#!/bin/sh
# x.PreProc_TissueReg_func2anat_fmap.sh

# Registers an image in functional space to an anatomically weighted image (i.e T1)
# Outputs are transformation matrices for func2anat and anat2func
# Uses Boundary-Based Registration in FSL
# Incorporates distortion correction using field map created using a Siemens magnitude and phase field map acquisition
# Run x.PreProc_fmapPrep.sh before this script
# Test this script on one scan with y and -y phase encoding directions; compare to see which has better registration
# and use this direction for the rest of the study. See below link for more info.

# For more info see:
# https://www.fmrib.ox.ac.uk/primers/intro_primer/ExBox19/IntroBox19.html
# https://web.mit.edu/fsl_v5.0.10/fsl/doc/wiki/FLIRT(2f)UserGuide.html#epi_reg

if [ $# -ne 11 ]
then
    echo "********************************************************************************************************"
    echo "Insufficient arguments supplied"
    echo "Input 1 should be the full path to the functional reference volume (brain extracted)"
    echo "e.g. whatever ref volume you used when running 3dvolreg e.g. SBRef or first volume of functional scan"
    echo "Input 2 should be the full path to the anat input scan (brain extracted)"
    echo "Input 3 should be the full path to the anat input scan (NOT brain extracted)"
    echo "Input 4 should be the full path to the field map"
    echo "Input 5 should be the full path to the field map magnitude image (brain extracted)"
    echo "Input 6 should be the full path to the field map magnitude image (NOT brain extracted)"
    echo "Input 7 should be the effective echo spacing (dwell time) in seconds"
    echo "Input 8 should be the phase encoding direction (y or -y)"
    echo "Input 9 should be the white matter segmentation of the anat image"
    echo "Input 10 should be the full path to the output directory"
    echo "Input 11 should be the subject ID"
    echo "*Note: do not include file extension - assumes nii.gz"
    echo "********************************************************************************************************"
    exit
fi

#define inputs
input_file_func=${1}
input_file_anat_brain=${2}
input_file_anat=${3}
input_fmap=${4}
input_fmap_mag_brain=${5}
input_fmap_mag=${6}
dwell_time=${7}
ph_enc_dir=${8}
anat_wm=${9}
output_dir=${10}
subject=${11}

#Check the input files exist
echo "*******************************************************"
echo "Input files are ${input_file_func}, ${input_file_anat}, ${input_file_anat_brain}, $input_fmap, $input_fmap_mag_brain, $input_fmap_mag, and $anat_wm"
echo "*******************************************************"
if [ ! -f "${input_file_func}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_func}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_file_anat}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_anat}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_file_anat_brain}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_anat_brain}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_fmap}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_fmap}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_fmap_mag_brain}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_fmap_mag_brain}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_fmap_mag}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_fmap_mag}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${anat_wm}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${anat_wm}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

#If output directory is not present, make it
if [ ! -d ${output_dir} ]
then
  mkdir ${output_dir}
fi
echo "********************************"
echo "Output directory is ${output_dir}"
echo "********************************"


#Registration from func to anat

if [ ! -f ${output_dir}/${subject}_anat2func-dc.mat ]
then

  echo "*********************************************************************"
  echo "Registering ${input_file_func} to ${input_file_anat} with FSL epi_reg"
  echo "*********************************************************************"
  epi_reg --echospacing=${dwell_time} --wmseg=${anat_wm}.nii.gz --fmap==${input_fmap}.nii.gz -v \
    --fmapmag=${input_fmap_mag}.nii.gz --fmapmagbrain=${input_fmap_mag_brain}.nii.gz --pedir=${ph_enc_dir} \
    --epi=${input_file_func}.nii.gz --t1=${input_file_anat}.nii.gz --t1brain=${input_file_anat_brain}.nii.gz --out=${output_dir}/${subject}_func2anat-dc

  echo "*******************************"
  echo "Inverting transformation matrix"
  echo "*******************************"
  convert_xfm -omat ${output_dir}/${subject}_anat2func-dc.mat -inverse ${output_dir}/${subject}_func2anat-dc.mat

else
 echo "****************************************************************************"
 echo "Registration from ${input_file_func} to ${input_file_anat} already completed"
 echo "****************************************************************************"
fi
