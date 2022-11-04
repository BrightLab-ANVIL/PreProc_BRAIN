#!/bin/sh
# x.PreProc_Transform_lin.sh

# Transform a file (e.g. a tissue mask) from T1-space to functional space or vice versa (linear, 6 dof)

if [ $# -ne 5 ]
then
    echo "********************************************************************************************************"
    echo "Insufficient arguments supplied"
    echo "Input 1 should be the full path to the file to be transformed"
    echo "Input 2 should be the full path to reference file"
    echo "Input 3 should be the full path to the transformation matrix"
    echo "Input 4 should be the full path to the output directory"
    echo "Input 5 should be output label e.g. lowres or fMRIspace or anat2func"
    echo "*Note: do not include file extension - assumes nii.gz and .mat"
    echo "********************************************************************************************************"
    exit
fi

#define inputs
input_file=${1}
input_file_ref=${2}
matrix=${3}
output_dir=${4}
output_prefix=${5}

#Check the input files exist
echo "*******************************************************"
echo "Input files are ${input_file} and ${input_file_ref} and ${matrix}"
echo "*******************************************************"
if [ ! -f "${input_file}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_file_ref}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_ref}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${matrix}.mat" ]
then
  echo "***************************************************"
  echo "Cannot locate the matrix input file ${matrix}"
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
input_file_prefix="$(basename -- $input_file)"

#Transformation
if [ ! -f "${output_dir}/${input_file_prefix}_${output_prefix}.nii.gz" ]
then
  echo "*****************************************************"
  echo "Transforming ${input_file} to ${input_file_ref} space"
  echo "******************************************************"

  flirt -in ${input_file}.nii.gz -ref ${input_file_ref}.nii.gz -applyxfm -init "${matrix}.mat"  -interp nearestneighbour -out "${output_dir}/${input_file_prefix}_${output_prefix}.nii.gz" -dof 6

else
   echo "***************************************************************"
   echo "${input_file} already transformed to to ${input_file_ref} space"
   echo "***************************************************************"
fi
