#!/bin/sh
# Dirty hack to automatically get matlab path
MATLAB_PATH=$(matlab -nosplash -nodesktop -r "try; f=matlabroot; fprintf('%s:',f); catch; end; exit" | tail -n1 | awk -F: '{print $1}')
echo "export MATLAB=${MATLAB_PATH}" >> src/cuda/config

# CUDAHOME
CUDA_VERSION=$(nvcc --version | grep -oP '(?<=release )[0-9.]+')
CUDAHOME=$(whereis "cuda-${CUDA_VERSION}" | awk '{print $2}')
if [ -z "$CUDAHOME" ]; then
    CUDAHOME=$(whereis "cuda" | awk '{print $2}')
fi
echo "export CUDAHOME=${CUDAHOME}" >> src/cuda/config

# SM
CUDA_SM=$(python src/cuda/sm.py)
echo "export GPUARCH=${CUDA_SM}" >> src/cuda/config

# CUDAMATLAB
BASEDIR="$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
CUDAMATLAB=${BASEDIR}src/cuda/CudaMATLAB
echo "export TDA=${BASEDIR}src/cuda" >> src/cuda/config
echo "CUDAMATLAB=${CUDAMATLAB}" >> src/cuda/config

# Get nvmex and nvopts.sh
wget -q --show-progress http://developer.download.nvidia.com/compute/cuda/1_1/Matlab_Cuda_1.1.tgz
tar -xzf Matlab_Cuda_1.1.tgz
mv Matlab_Cuda_1.1/nvmex ${CUDAMATLAB}
mv Matlab_Cuda_1.1/nvopts.sh ${CUDAMATLAB}
rm -rf Matlab_Cuda_1.1
rm Matlab_Cuda_1.1.tgz

cat ${CUDAMATLAB}/nvmex | sed -i '1447,1454 s/^/#/' > ${CUDAMATLAB}/nvmex

# Build openph :)
cd src/cuda/pms
make
