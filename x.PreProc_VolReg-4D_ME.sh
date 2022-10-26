#!/bin/sh
# x.PreProc_VolReg-4D_ME

# For use with multi-echo data
# Uses 3dvolreg to register the first echo to a reference image, saves motion parameters,
# and applies the same motion parameters to the rest of the echoes using 3dAllineate
# Your input files must be named ${input_prefix}_${echonum}.nii.gz

if [ $# -ne 7 ]
then
    echo "**************************************************************************************"
    echo "Insufficient arguments supplied"
    echo "Input 1 should be the full path to the 4D input scan FOLDER*"
    echo "Input 2 should be the file prefix of the 4D input scans"
    echo "Input 3 should be the number of echoes collected"
    echo "Input 4 should be the full path to reference scan* (this can be the same as input 1, echo 1)"
    echo "Input 5 should be the volume number of reference scan"
    echo "Input 6 should be the full path to the output directory"
    echo "Input 7 should be 1 (yes) or 0 (no) to output motion derivatives and quadratic terms"
    echo "*Do not include file extension - assumes nii.gz"
    echo
    echo "Example usage: ./x.PreProc_VolReg-4D_ME.sh '~/func/BHAUD' 'pilot-01_BHAUD' 5 '~/func/BHAUD/pilot-01_BHAUD_1' 0 ~/func 0"
    echo "**************************************************************************************"
    exit
fi

#define inputs
input_folder=${1}
input_prefix=${2}
num_echoes=${3}
ref_file=${4}
ref_vol=${5}
output_dir=${6}
quad_deriv=${7}

#Check input 7 to output motion derivatives and quadratic terms
if [ ${quad_deriv} != 0 ] && [ ${quad_deriv} != 1 ]; then
  echo "*****************************"
  echo "Input 7 is unknown... exiting"
  echo "*****************************"
  exit
fi

#Check the input file exists (first echo)
echo "***************************"
echo "Input file is ${input_folder}/${input_prefix}_1"
echo "***************************"
if [ ! -f "${input_folder}/${input_prefix}_1.nii.gz" ]
then
  echo "************************************************"
  echo "Cannot locate the NIFTI input file ${input_folder}/${input_prefix}_1.nii.gz"
  echo "...exiting!"
  echo "************************************************"
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
# input_prefix="$(basename -- $input_file)"

#Create a symbolic link of the original dataset in the output directory
if [ ! -f "${output_dir}/${input_prefix}_ORIG.nii.gz" ]
then
  ln -s "${input_folder}/${input_prefix}.nii.gz" "${output_dir}/${input_prefix}_ORIG.nii.gz"
fi

# Volume Registration

if [ ! -f ${output_dir}/${input_prefix}_1_mc.nii.gz ]
then
  echo "****************************************************"
  echo "Running volume registration on ${input_prefix}_1.nii.gz"
  echo "****************************************************"

  #Run volume registration (AFNI)
  3dvolreg -dfile ${output_dir}/${input_prefix}_1_mc.1D \
  -base ${ref_file}.nii.gz[${ref_vol}] \
  -maxdisp1D ${output_dir}/${input_prefix}_1_mc_maxdisp.1D \
  -prefix ${output_dir}/${input_prefix}_1_mc.nii.gz \
  -1Dmatrix_save ${output_dir}/${input_prefix}_1_mc.aff12.1D \
  ${input_folder}/${input_prefix}_1.nii.gz

  #Demean the saved motion parameters
  # 0: roll; 1: pitch; 2: yaw; 3: dS (z); 4: dL (x); 5: dP (y)
  if [ ! -f ${output_dir}/${input_prefix}_1_mc_demean.1D ]
  then
    echo "*******************************************"
    echo "Demeaning and saving the motion parameters!"
    echo "*******************************************"
    1d_tool.py -infile ${output_dir}/${input_prefix}_1_mc.1D[1..6] \
    -demean -write ${output_dir}/${input_prefix}_1_mc_demean.1D
  fi

  #Calculate the motion derivatives and quadratic terms, if requested
  if [ "${quad_deriv}" -eq 1 ]; then
    echo "*************************************************"
    echo "Making derivative and quadratic motion regressors"
    echo "*************************************************"
    # Output temporal derivatives of motion regressor
    1d_tool.py -infile ${output_dir}/${input_prefix}_1_mc.1D[1..6] \
    -derivative -write ${output_dir}/${input_prefix}_1_mc_deriv.1D
    # Output quadratics (squared) of motion regressor
    1dcat `1deval -1D: -a ${output_dir}/${input_prefix}_1_mc.1D[1] -expr 'a*a'` \
    `1deval -1D: -a ${output_dir}/${input_prefix}_1_mc.1D[2]  -expr 'a*a'` \
    `1deval -1D: -a ${output_dir}/${input_prefix}_1_mc.1D[3] -expr 'a*a'` \
    `1deval -1D: -a ${output_dir}/${input_prefix}_1_mc.1D[4] -expr 'a*a'` \
    `1deval -1D: -a ${output_dir}/${input_prefix}_1_mc.1D[5] -expr 'a*a'` \
    `1deval -1D: -a ${output_dir}/${input_prefix}_1_mc.1D[6] -expr 'a*a'` > ${output_dir}/${input_prefix}_1_mc_quad.1D
    # Demean the derivative and quadratic motion regressor
    1d_tool.py -infile ${output_dir}/${input_prefix}_1_mc_deriv.1D \
    -demean -write ${output_dir}/${input_prefix}_1_mc_deriv_demean.1D
    1d_tool.py -infile ${output_dir}/${input_prefix}_1_mc_quad.1D \
    -demean -write ${output_dir}/${input_prefix}_1_mc_quad_demean.1D
  fi

  # Use motion parameters from echo 1 to motion correct the other echoes
  for echonum in $(eval echo "{2..$num_echoes}")
  do

    echo "*************************************************"
    echo "Running volume registration on ${input_prefix}_${echonum}.nii.gz"
    echo "*************************************************"

    3dAllineate -input ${input_folder}/${input_prefix}_${echonum}.nii.gz \
    -prefix ${output_dir}/${input_prefix}_${echonum}_mc.nii.gz \
    -1Dmatrix_apply ${output_dir}/${input_prefix}_1_mc.aff12.1D

  done #end loop through rest of echoes

else
  echo "**************************************************************"
  echo "Volume registration already complete for ${input_prefix}"
  echo "**************************************************************"
fi
