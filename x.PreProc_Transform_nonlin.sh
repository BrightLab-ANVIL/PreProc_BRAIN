#!/bin/sh
# x.PreProc_Transform_nonlin.sh

# Transform a file (e.g. a tissue mask) from functional to standard space or vice versa (nonlinear)

if [ $# -ne 5 ]
then
    echo "********************************************************************************************************"
    echo "Insufficient arguments supplied"
    echo "Input 1 should be the full path to the file to be transformed"
    echo "Input 2 should be the full path to reference file"
    echo "Input 3 should be the full path to the warp file"
    echo "Input 4 should be the full path to the output directory"
    echo "Input 5 should be output label e.g. fMRIspace or func2stand"
    echo "*Note: do not include file extension - assumes nii.gz and .mat"
    echo "********************************************************************************************************"
    exit
fi

#define inputs
input_file=${1}
input_file_ref=${2}
warp=${3}
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

if [ ! -f "${warp}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the matrix input file ${warp}"
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

  applywarp --ref=${input_file_ref}.nii.gz --in=${input_file}.nii.gz --out=${output_dir}/${input_file_prefix}_${output_prefix}.nii.gz --warp=${warp}.nii.gz

else
   echo "***************************************************************"
   echo "${input_file} already transformed to to ${input_file_ref} space"
   echo "***************************************************************"
fi
