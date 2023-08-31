#!/bin/sh
# x.PreProc_fmapPrep.sh

# Prepares a field map created using a Siemens magnitude and phase field map acquisition
# Must run fsl_anat before running this script (for white matter mask creation)
# For more info see: https://web.mit.edu/fsl_v5.0.10/fsl/doc/wiki/FUGUE(2f)Guide.html#Making_Fieldmap_Images_for_FEAT

if [ $# -ne 5 ]
then
    echo "********************************************************************************************************"
    echo "Insufficient arguments supplied"
    echo "Input 1 should be the full path to the field map magnitude image"
    echo "Input 2 should be the full path to the field map phase image"
    echo "Input 3 should be the full path to the anat folder"
    echo "Input 4 should be the full path to the output directory"
    echo "Input 5 should be the subject ID"
    echo "*Note: do not include file extension - assumes nii.gz"
    echo "********************************************************************************************************"
    exit
fi

#define inputs
input_file_mag=${1}
input_file_phase=${2}
anat_folder=${3}
output_dir=${4}
subject=${5}

#Check the input files exist
echo "*******************************************************"
echo "Input files are ${input_file_mag} and ${input_file_phase}"
echo "*******************************************************"
if [ ! -f "${input_file_mag}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_mag}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_file_phase}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_phase}"
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

#Get the input filename without the path
input_prefix="$(basename -- $input_file_mag)"

if [ ! -f ${output_dir}/${subject}_fieldmap.nii.gz ]
then

  echo "*******************************************"
  echo "Brain extracting ${input_file_mag}"
  echo "*******************************************"

  #Brain extraction of magnitude image (better to remove brain than leave any voxels outside the brain)
  bet ${input_file_mag}.nii.gz ${output_dir}/${input_prefix}_brain.nii.gz -m -B -f 0.6
  fslmaths ${output_dir}/${input_prefix}_brain.nii.gz -ero ${output_dir}/${input_prefix}_brain_ero.nii.gz

  echo "*******************************"
  echo "Preparing field map"
  echo "*******************************"
  fsl_prepare_fieldmap SIEMENS ${input_file_phase}.nii.gz ${output_dir}/${input_prefix}_brain_ero.nii.gz ${output_dir}/${subject}_fieldmap.nii.gz 2.46

  echo "***********************************************"
  echo "Create white matter mask of anatomical image"
  echo "***********************************************"
  fslmaths ${anat_folder}/T1_fast_pve_2.nii.gz -thr 0.5 -bin ${anat_folder}/T1_wmseg_p5.nii.gz

else
 echo "****************************************************************************"
 echo "Field map already prepared"
 echo "****************************************************************************"
fi
