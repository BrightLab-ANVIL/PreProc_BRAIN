#!/bin/sh
# x.PreProc_TissueReg_func2standConcat.sh

# Concatenates previously created func2anat and anat2stand files
# Outputs are transformation matrices for funcstand and stand2func

if [ $# -ne 8 ]
then
    echo "********************************************************************************************************"
    echo "Insufficient arguments supplied"
    echo "Input 1 should be the full path to the func2anat transformation matrix"
    echo "Input 2 should be the full path to the anat2func transformation matrix"
    echo "Input 3 should be the full path to the anat2stand transformation warp"
    echo "Input 4 should be the full path to the stand2anat transformation warp"
    echo "Input 5 should be the full path to the functional reference image (brain extracted)"
    echo "Input 6 should be the full path to the standard reference image (brain extracted)"
    echo "Input 7 should be the full path to the output directory"
    echo "Input 8 should be the subject ID"
    echo "*Note: do not include file extension - assumes nii.gz and .mat"
    echo "********************************************************************************************************"
    exit
fi

#define inputs
input_file_func2anat=${1}
input_file_anat2func=${2}
input_file_anat2stand=${3}
input_file_stand2anat=${4}
input_file_funcref=${5}
input_file_standref=${6}
output_dir=${7}
subject=${8}

#Check the input files exist
echo "*******************************************************"
echo "Input files are ${input_file_func2anat} and ${input_file_anat2func} and ${input_file_anat2stand} and ${input_file_stand2anat} and ${input_file_funcref} and ${input_file_standref}"
echo "*******************************************************"

if [ ! -f "${input_file_func2anat}.mat" ]
then
  echo "***************************************************"
  echo "Cannot locate the transformation matrix ${input_file_func2anat}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_file_anat2func}.mat" ]
then
  echo "***************************************************"
  echo "Cannot locate the transformation matrix ${input_file_anat2func}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_file_anat2stand}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_anat2stand}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_file_stand2anat}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_stand2anat}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_file_funcref}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_funcref}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_file_standref}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_standref}"
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


#Registration from anat to stand

if [ ! -f ${output_dir}/${subject}_stand2func_warp.nii.gz ]
then

    echo "***********************************************************************************"
    echo "Concatenating ${input_file_func2anat} with ${input_file_anat2stand}"
    echo "***********************************************************************************"

    convertwarp --ref=${input_file_standref}.nii.gz --premat=${input_file_func2anat}.mat --warp1=${input_file_anat2stand}.nii.gz --out=${output_dir}/${subject}_func2stand_warp.nii.gz

    echo "***********************************************************************************"
    echo "Concatenating ${input_file_stand2anat} with ${input_file_anat2func}"
    echo "***********************************************************************************"

    convertwarp --ref=${input_file_funcref}.nii.gz --warp1=${input_file_stand2anat}.nii.gz --postmat=${input_file_anat2func}.mat --out=${output_dir}/${subject}_stand2func_warp.nii.gz

else
 echo "***********************************************************************"
 echo "Concatenation of transformation files already completed"
 echo "***********************************************************************"
fi
