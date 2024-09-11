@echo off
REM Habilitar expansión de variables retardada
setlocal enabledelayedexpansion

REM Directorios para los archivos de entrada y salida
set input_dir=C:\Users\Ferna\Documentos\GitHub\siemens_to_ismrmrd\Conversion_dat_mrd
set output_dir=C:\Users\Ferna\Documentos\GitHub\siemens_to_ismrmrd\Conversion_dat_mrd

REM Directorio para guardar los archivos XML/XSL extraídos
set parameter_maps_dir=C:\Users\Ferna\Documentos\GitHub\siemens_to_ismrmrd\parameter_maps

REM Extraer el archivo incrustado IsmrmrdParameterMap_Siemens_NX.xsl si aún no está extraído
if not exist "%parameter_maps_dir%\IsmrmrdParameterMap_Siemens_NX.xsl" (
    echo Extrayendo IsmrmrdParameterMap_Siemens_NX.xsl...
    docker run --rm ^
        siemenstoismrmrd siemens_to_ismrmrd ^
        -e IsmrmrdParameterMap_Siemens_NX.xsl > "%parameter_maps_dir%\IsmrmrdParameterMap_Siemens_NX.xsl"
)

REM Verificar si el directorio de entrada contiene archivos .dat
if not exist "%input_dir%\*.dat" (
    echo No se encontraron archivos .dat en el directorio de entrada: %input_dir%
    exit /b
)

REM Iterar sobre todos los archivos .dat en el directorio de entrada
for %%f in ("%input_dir%\*.dat") do (
    REM Extraer el nombre del archivo sin la extensión
    set "filename=%%~nf"
    echo Procesando archivo %%f...

    REM Ejecutar el contenedor Docker y convertir el archivo usando el archivo XSL extraído
    docker run --rm ^
        -v "%input_dir%:/input" ^
        -v "%output_dir%:/output" ^
        -v "%parameter_maps_dir%:/parameter_maps" ^
        siemenstoismrmrd siemens_to_ismrmrd ^
        -f "/input/!filename!.dat" ^
        -x "/parameter_maps/IsmrmrdParameterMap_Siemens_NX.xsl" ^
		--skipSyncData ^
        -o "/output/!filename!.mrd"
    
    REM Verificar si la conversión fue exitosa
    if exist "%output_dir%\!filename!.mrd" (
        echo Archivo convertido con éxito: !filename!.mrd
    ) else (
        echo Error al convertir el archivo: !filename!.dat
    )
)

echo Conversión completa.
pause
