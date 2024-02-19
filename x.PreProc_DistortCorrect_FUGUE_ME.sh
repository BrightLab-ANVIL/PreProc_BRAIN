#!/bin/sh
# x.PreProc_DistortCorrect_FUGUE_ME.sh

# Converts a distorted functional space image to undistorted functional space
# Uses FUGUE in FSL
# Must have already run x.PreProc_TissueReg_func2anat_fmap.sh to get field map in radians and functional space

if [ $# -ne 4 ]
then
    echo "********************************************************************************************************"
    echo "Insufficient arguments supplied"
    echo "Input 1 should be the full path to distorted functional image"
    echo "Input 2 should be the effective echo spacing (dwell time) in seconds"
    echo "Input 3 should be the field map in radians and functional space, ex. _fieldmaprads2epi"
    echo "Input 4 should be the full path to the output directory"
    echo "*Note: do not include file extension - assumes nii.gz"
    echo "********************************************************************************************************"
    exit
fi

#define inputs
input_file_func_dist=${1}
dwelltime=${2}
input_file_fieldmap=${3}
output_dir=${4}

#Check the input files exist
echo "*******************************************************"
echo "Input files are ${input_file_func_dist} and ${input_file_fieldmap}"
echo "*******************************************************"
if [ ! -f "${input_file_func_dist}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the transformation matrix ${input_file_func_dist}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_file_fieldmap}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_fieldmap}"
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
input_prefix="$(basename -- $input_file_func_dist)"


if [ ! -f ${output_dir}/${input_prefix}_dc.nii.gz ]
then

  echo "*******************************************************************"
  echo "Distortion correcting ${input_file_func_dist} with FSL FUGUE"
  echo "*******************************************************************"

  fugue -i ${input_file_func_dist}.nii.gz --dwell=${dwelltime} --loadfmap=${input_file_fieldmap}.nii.gz -u ${output_dir}/${input_prefix}_dc.nii.gz

else
 echo "***********************************************************************"
 echo "Distortion correction of ${input_file_func_dist} already completed"
 echo "***********************************************************************"
fi
