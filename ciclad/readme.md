A simple run script example is provided in 

> run_simple.sh

This is for running WRF-Chem after all the pre-processing steps are completed.  Steps include:

- Creating an output folder
- Creating a temporary scratch folder
- Copying all input files for running WRF-Chem (emissions, etc)
- Copying the executibles and input for running WRF-Chem
- Setting paths and loading modules
- Copying output from real
- Copying the namelist
- Running WRF-Chem using mpi run
- Moving output from the scratch folder to the output folder, removing the scratch folder
