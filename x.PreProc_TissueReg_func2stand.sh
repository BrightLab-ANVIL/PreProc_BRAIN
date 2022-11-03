#!/bin/sh
# x.PreProc_TissueReg_func2stand.sh

# Registers an image in functional space to standard space
# Outputs are transformation matrices for anat2stand, stand2anat, func2stand, and stand2func
# Uses FNIRT in FSL (nonlinear)
# Must have already run x.PreProc_TissueReg_func2anat.sh to get func2anat transformation matrix
# Currently works only for MNI space. To use with a different standard, will have to find a different --config file to use with FNIRT

if [ $# -ne 8 ]
then
    echo "********************************************************************************************************"
    echo "Insufficient arguments supplied"
    echo "Input 1 should be the full path to the func2anat transformation matrix"
    echo "Input 2 should be the full path to the anat input scan (brain extracted)"
    echo "Input 3 should be the full path to the anat input scan (NOT brain extracted)"
    echo "Input 4 should be the full path to the standard input scan, ex. MNI152_T1_2mm_brain (brain extracted)"
    echo "Input 5 should be the full path to the standard input scan, ex. MNI152_T1_2mm (NOT brain extracted)"
    echo "Input 6 should be the full path to the standard brain mask, ex. MNI152_T1_2mm_brain_mask_dil"
    echo "Input 7 should be the full path to the output directory"
    echo "Input 8 should be the subject ID"
    echo "*Note: do not include file extension - assumes nii.gz and .mat"
    echo "********************************************************************************************************"
    exit
fi

#define inputs
input_file_func2anat=${1}
input_file_anat_brain=${2}
input_file_anat=${3}
input_file_stand_brain=${4}
input_file_stand=${5}
input_file_stand_mask=${6}
output_dir=${7}
subject=${8}

#Check the input files exist
echo "*******************************************************"
echo "Input files are ${input_file_func2anat} and ${input_file_anat_brain} and ${input_file_anat} and ${input_file_stand_brain} and ${input_file_stand} and ${input_file_stand_mask}"
echo "*******************************************************"
if [ ! -f "${input_file_func2anat}.mat" ]
then
  echo "***************************************************"
  echo "Cannot locate the transformation matrix ${input_file_func2anat}"
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

if [ ! -f "${input_file_anat}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_anat}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_file_stand_brain}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_stand_brain}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_file_stand}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_stand}"
  echo "...exiting!"
  echo "***************************************************"
  exit
fi

if [ ! -f "${input_file_stand_mask}.nii.gz" ]
then
  echo "***************************************************"
  echo "Cannot locate the NIFTI input file ${input_file_stand_mask}"
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


#Registration from func to stand

if [ ! -f ${output_dir}/${subject}_func2stand_warp.nii.gz ]
then

  echo "*******************************************************************"
  echo "Registering ${input_file_anat_brain} to ${input_file_stand_brain} with FSL FNIRT"
  echo "*******************************************************************"

  # stuctural <-> standard
  flirt -in ${input_file_anat_brain}.nii.gz -ref ${input_file_stand_brain}.nii.gz -out ${output_dir}/${subject}_anat2stand -omat ${output_dir}/${subject}_anat2stand.mat -cost corratio -dof 12 \
    -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear
  fnirt --iout=${output_dir}/${subject}_anat2stand_head --in=${input_file_anat}.nii.gz --aff=${output_dir}/${subject}_anat2stand.mat --cout=${output_dir}/${subject}_anat2stand_warp \
    --iout=${output_dir}/${subject}_anat2stand --jout=${output_dir}/${subject}_anat2anat_jac --config=T1_2_MNI152_2mm --ref=${input_file_stand}.nii.gz --refmask=${input_file_stand_mask}.nii.gz --warpres=5,5,5
  applywarp -i ${input_file_anat_brain}.nii.gz -r ${input_file_stand_brain}.nii.gz -o ${output_dir}/${subject}_anat2stand.nii.gz -w ${output_dir}/${subject}_anat2stand_warp
  convert_xfm -inverse -omat ${output_dir}/${subject}_stand2anat.mat ${output_dir}/${subject}_anat2stand.mat

  echo "*****************************"
  echo "Concatenating with func2anat"
  echo "*****************************"

  # concatenate: functional <-> MNI standard
  convert_xfm -omat ${output_dir}/${subject}_func2stand.mat -concat ${output_dir}/${subject}_anat2stand.mat ${input_file_func2anat}.mat
  convertwarp --ref=${input_file_stand_brain}.nii.gz --premat=${output_dir}/${subject}_func2anat.mat --warp1=${output_dir}/${subject}_anat2stand_warp --out=${output_dir}/${subject}_func2stand_warp

  echo "*******************************"
  echo "Inverting transformation matrix"
  echo "*******************************"
  convert_xfm -inverse -omat ${output_dir}/${subject}_stand2func.mat ${output_dir}/${subject}_func2stand.mat

else
 echo "***********************************************************************"
 echo "Registration from func to ${input_file_stand_brain} already completed"
 echo "***********************************************************************"
fi
