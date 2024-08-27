@echo off
REM Directory for input and output files
set input_dir=C:\Users\Ferna\Documentos\GitHub\siemens_to_ismrmrd\Conversion_dat_mrd
set output_dir=C:\Users\Ferna\Documentos\GitHub\siemens_to_ismrmrd\Conversion_dat_mrd

REM Iterate over all .dat files in the input directory
for %%f in (%input_dir%\*.dat) do (
    REM Extract the filename without the extension
    set "filename=%%~nf"
    echo Processing file %%f...
    
    REM Convert file using siemens_to_ismrmrd
    docker run --rm ^
        -v %input_dir%:/input ^
        -v %output_dir%:/output ^
        siemenstoismrmrd_fixed siemens_to_ismrmrd ^
        -f /input/%%~nf.dat ^
        -o /output/%%~nf.h5 ^
        --debug
)

pause
