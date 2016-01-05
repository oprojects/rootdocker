
FROM oproject/debian

MAINTAINER Omar Zapata <Omar.Zapata@cern.ch>

USER root

# Install ROOT prerequisites
RUN apt-get update
### Core
RUN apt-get -y install git cmake gcc g++ gfortran doxygen
### X libraries
RUN apt-get -y install libx11-dev libxext-dev libxft-dev libxpm-dev
### Python
RUN apt-get -y install python-dev python-numpy-dev python-pip python-scipy python-matplotlib
### Python installed with pip
RUN pip install metakernel scikit-learn scipy matplotlib
### Math libraries
RUN apt-get -y install libgsl0-dev
### Other libraries
RUN apt-get -y install libxml2-dev
### ROOT-R prerequisites
RUN apt-get -y install r-base-dev
RUN R Rscript -e "install.packages(c('Rcpp','RInside'),repos='http://cran.cnr.Berkeley.edu')"

# Install (R TMVA) packages
# NOTES:
# C50:  Decision trees and rule-based models
# RSNNS: R Stuttgart Neural Network Simulator
# xgboost: Extreme Gradient Boosting
# e1071: For Support Vector Machine
RUN Rscript -e "install.packages(c('C50','RSNNS','xgboost','e1071'),repos='http://cran.cnr.Berkeley.edu')"

# Install (Python TMVA) packages
RUN pip install scikit-learn

# Download and install ROOT master
WORKDIR /opt
RUN git clone http://github.com/root-mirror/root
RUN mkdir root/bin
WORKDIR /opt/root/bin
RUN cmake -Dr=ON ..
RUN make -j 16

# Creating user
RUN useradd -ms /bin/bash cernphsft

USER cernphsft

WORKDIR /home/cernphsft

# Set ROOT environment
ENV ROOTSYS         "/opt/root"
ENV PATH            "$ROOTSYS/bin:$ROOTSYS/bin/bin:$PATH"
ENV LD_LIBRARY_PATH "$ROOTSYS/lib:$LD_LIBRARY_PATH"
ENV PYTHONPATH      "$ROOTSYS/lib:PYTHONPATH"

# Customise the ROOTbook
RUN mkdir -p $HOME/.ipython/kernels $HOME/.ipython/profile_default/static
RUN cp -r $ROOTSYS/etc/notebook/kernels/root $HOME/.ipython/kernels
RUN cp -r $ROOTSYS/etc/notebook/custom       $HOME/.ipython/profile_default/static
