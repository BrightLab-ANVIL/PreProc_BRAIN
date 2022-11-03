#!/bin/sh
# x.PreProc_TissueReg_func2anat.sh

# Registers an image in functional space to an anatomically weighted image (i.e T1)
# Outputs are transformation matrices for func2anat and anat2func
# Uses Boundary-Based Registration in FSL

if [ $# -ne 5 ]
then
    echo "********************************************************************************************************"
    echo "Insufficient arguments supplied"
    echo "Input 1 should be the full path to the functional reference volume (brain extracted)"
    echo "e.g. whatever ref volume you used when running 3dvolreg e.g. SBRef or first volume of functional scan"
    echo "Input 2 should be the full path to the anat input scan (brain extracted)"
    echo "Input 3 should be the full path to the anat input scan (NOT brain extracted)"
    echo "Input 4 should be the full path to the output directory"
    echo "Input 5 should be the subject ID"
    echo "*Note: do not include file extension - assumes nii.gz"
    echo "********************************************************************************************************"
    exit
fi

#define inputs
input_file_func=${1}
input_file_anat_brain=${2}
input_file_anat=${3}
output_dir=${4}
subject=${5}

#Check the input files exist
echo "*******************************************************"
echo "Input files are ${input_file_func} and ${input_file_anat} and ${input_file_anat_brain}"
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

#If output directory is not present, make it
if [ ! -d ${output_dir} ]
then
  mkdir ${output_dir}
fi
echo "********************************"
echo "Output directory is ${output_dir}"
echo "********************************"


#Registration from func to anat

if [ ! -f ${output_dir}/${subject}_anat2func.mat ]
then

  echo "*********************************************************************"
  echo "Registering ${input_file_func} to ${input_file_anat} with FSL epi_reg"
  echo "*********************************************************************"
  epi_reg --epi=${input_file_func}.nii.gz --t1=${input_file_anat}.nii.gz --t1brain=${input_file_anat_brain}.nii.gz --out=${output_dir}/${subject}_func2anat

  echo "*******************************"
  echo "Inverting transformation matrix"
  echo "*******************************"
  convert_xfm -omat ${output_dir}/${subject}_anat2func.mat -inverse ${output_dir}/${subject}_func2anat.mat

else
 echo "****************************************************************************"
 echo "Registration from ${input_file_func} to ${input_file_anat} already completed"
 echo "****************************************************************************"
fi
