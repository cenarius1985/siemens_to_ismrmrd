@echo off

REM Directorio de entrada y salida
set input_dir=C:\Users\Ferna\Documentos\GitHub\siemens_to_ismrmrd\Conversion_dat_mrd
set output_dir=C:\Users\Ferna\Documentos\GitHub\siemens_to_ismrmrd\Conversion_dat_mrd

REM Itera sobre todos los archivos .dat en el directorio de entrada
for %%f in (%input_dir%\*.dat) do (
    REM Extrae el nombre del archivo sin la extensión
    set filename=%%~nf
    echo Procesando archivo %%f...
    
    REM Ejecuta el contenedor de Docker para convertir el archivo .dat a .h5
    docker run --rm -v %input_dir%:/flywheel/v0/input/dat -v %output_dir%:/flywheel/v0/output siemens_to_ismrmrd siemens_to_ismrmrd -f /flywheel/v0/input/dat/%%~nf.dat -o /flywheel/v0/output/%%~nf.h5
)

pause
