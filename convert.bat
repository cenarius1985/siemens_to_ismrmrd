@echo off
REM Directory for input and output files
set input_dir=C:\Users\Ferna\Documentos\GitHub\siemens_to_ismrmrd\Conversion_dat_mrd
set output_dir=C:\Users\Ferna\Documentos\GitHub\siemens_to_ismrmrd\Conversion_dat_mrd
set parameter_maps_dir=C:\Users\Ferna\Documentos\GitHub\siemens_to_ismrmrd\parameter_maps

REM Iterate over all .dat files in the input directory
for %%f in (%input_dir%\*.dat) do (
    REM Extract the filename without the extension
    set filename=%%~nf
    echo Processing file %%f...
    
    REM Convert first measurement
    docker run --rm ^
        -v %input_dir%:/flywheel/v0/input/dat ^
        -v %output_dir%:/flywheel/v0/output ^
        -v %parameter_maps_dir%:/flywheel/v0/input/parameter_maps ^
        siemenstoismrmrd_v2 siemens_to_ismrmrd ^
        -f /flywheel/v0/input/dat/%%~nf.dat ^
        -o /flywheel/v0/output/%%~nf_measurement1.h5 ^
        -m /flywheel/v0/input/parameter_maps/IsmrmrdParameterMap_Siemens.xml ^
        -z 1 ^
        --debug

    REM Convert second measurement
    docker run --rm ^
        -v %input_dir%:/flywheel/v0/input/dat ^
        -v %output_dir%:/flywheel/v0/output ^
        -v %parameter_maps_dir%:/flywheel/v0/input/parameter_maps ^
        siemenstoismrmrd_v2 siemens_to_ismrmrd ^
        -f /flywheel/v0/input/dat/%%~nf.dat ^
        -o /flywheel/v0/output/%%~nf_measurement2.h5 ^
        -m /flywheel/v0/input/parameter_maps/IsmrmrdParameterMap_Siemens.xml ^
        -z 2 ^
        --debug
)
pause