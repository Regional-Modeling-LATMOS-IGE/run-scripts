#!/bin/bash
#-------- Set up and run WRF-Chem with SAPRC99_MOSAIC chemistry+aerosols --------

# Resources used
#PBS -l "nodes=3:ppn=8"
#PBS -l vmem=64G
#PBS -l mem=64G
#PBS -q week
#PBS -j eo


#-------- Input --------
CASENAME='print_HgBr_newIJ'

# Root directory with the compiled WRF-Chem executables (main/wrf.exe and main/real.exe)
WRFDIR='/data/thomas/WRF-mercury-1D/'

# Root directory for WRF output
OUTDIR_root="/data/thomas/output"
echo $OUTDIR_root

OUTDIR="$OUTDIR_root"/"$CASENAME"
echo $OUTDIR
rm -rf $OUTDIR
mkdir $OUTDIR

##-------- Parameters --------
## WRF-Chem input data directory
WRFCHEM_INPUT_DATA_DIR="/data/marelle/WRFChem/wrf_utils/wrfchem_input"

##-------- Set up job environment --------
##cd $PBS_O_WORKDIR

## Load modules used for WRFChem compilation
module purge   # clear any inherited modules
module load openmpi/1.6.5-ifort
module load hdf5/1.8.14-ifort
module load netcdf4/4.3.3.1-ifort
NETCDF_ROOT='/opt/netcdf43/ifort'
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$NETCDF_ROOT/lib"
# Must set large stack size (unlimited for simplicity)
ulimit -s unlimited
# Set ulimit also to unlimited (probably not necessary)
ulimit unlimited

##-------- Set up WRF-Chem input and output directories & files  --------
## Directory containing real output (e.g. wrfinput_d01, wrfbdy_d01 files)
##REALDIR="${INDIR_ROOT}/real_${CASENAME}_$(date -d "$date_e - 1 day" "+%Y")"
REALDIR="/data/sahmed/WRFChem/WRFChem_OUTPUT/real_WRFChem_MERCURY_1C_2012"

## Also create a temporary run directory
SCRATCH="${OUTDIR}.scratch"
mkdir $SCRATCH
cd $SCRATCH
echo $PWD
echo "Running on $SCRATCH"
cp "$PBS_O_WORKDIR/"* "$SCRATCH/"

##-------- Run real, WRF  --------
## Copy the WRF run directory (contains auxilliary files etc.) and the REAL &
## WRF executables to $SCRATCH/
cp "$WRFDIR/run/"* "$SCRATCH/"
cp "$WRFDIR/main/wrf.exe" "$SCRATCH/wrf.exe"

## Copy the input files from real
cp "${REALDIR}/"*"d01"* "$SCRATCH/"

## Copy namelist from real
cp "$PBS_O_WORKDIR/namelist.input" "$SCRATCH/"

# Transfer other input data
cp "$WRFCHEM_INPUT_DATA_DIR/upper_bdy/clim_p_trop.nc" "$SCRATCH/"
cp "$WRFCHEM_INPUT_DATA_DIR/upper_bdy/ubvals_b40.20th.track1_1996-2005.nc" "$SCRATCH/"

## Run wrf.exe --------
mpirun wrf.exe

# Check the end of the log file in case the code crashes
tail -n20 rsl.error.0000

## Transfer files to the output dir
mv "$SCRATCH/wrfout_"* "$OUTDIR/"
mv "$SCRATCH/wrfrst_"* "$OUTDIR/"
cp "$SCRATCH/rsl."* "$OUTDIR/" 
cp "$SCRATCH/namelist.input" "$OUTDIR/" 
rm -rf "$SCRATCH"

