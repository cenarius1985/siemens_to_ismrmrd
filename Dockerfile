# Primera fase: ismrmrd_base
FROM ubuntu:22.04 as ismrmrd_base

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Chicago

# Instalar las dependencias necesarias, incluidas las bibliotecas de desarrollo y herramientas de compilación
RUN apt-get update && apt-get install -y git cmake g++ libhdf5-dev libxml2-dev libxslt1-dev libboost-all-dev xsdcxx libxerces-c-dev libtinyxml-dev libpugixml-dev libhdf5-serial-dev h5utils hdf5-tools

RUN mkdir -p /opt/code

# Crear directorio para siemens_to_ismrmrd y copiar el contenido
RUN mkdir -p /opt/code/siemens_to_ismrmrd
COPY . /opt/code/siemens_to_ismrmrd/

# Clonar y compilar la biblioteca ISMRMRD
RUN cd /opt/code && \
    git clone https://github.com/ismrmrd/ismrmrd.git && \
    cd ismrmrd && \
    git checkout $(cat /opt/code/siemens_to_ismrmrd/dependencies/ismrmrd | xargs) && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j $(nproc) && \
    make install

# Compilar el convertidor siemens_to_ismrmrd
RUN cd /opt/code/siemens_to_ismrmrd && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j $(nproc) && \
    make install

# Crear un archivo comprimido con las bibliotecas de ISMRMRD para la siguiente fase
RUN cd /usr/local/lib && tar -czvf libismrmrd.tar.gz libismrmrd*

# Segunda fase: imagen ligera con las dependencias mínimas
FROM ubuntu:22.04

# Instalar las dependencias mínimas necesarias para ejecutar el convertidor y las bibliotecas ISMRMRD
RUN apt-get update && apt-get install -y --no-install-recommends libxslt1.1 libhdf5-dev libxerces-c-dev libboost-all-dev libpugixml1v5 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar el binario de siemens_to_ismrmrd y las bibliotecas de la fase anterior
COPY --from=ismrmrd_base /usr/local/bin/siemens_to_ismrmrd  /usr/local/bin/siemens_to_ismrmrd
COPY --from=ismrmrd_base /usr/local/lib/libismrmrd.tar.gz   /usr/local/lib/

# Descomprimir las bibliotecas de ISMRMRD y ejecutar ldconfig para actualizar las referencias de las bibliotecas
RUN cd /usr/local/lib && tar -zxvf libismrmrd.tar.gz && rm libismrmrd.tar.gz && ldconfig
