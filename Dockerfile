# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

# Set when building on Travis so that certain long-running build steps can
# be skipped to shorten build time.
ARG TEST_ONLY_BUILD

USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    tzdata \
    gfortran \
    gcc && \
    rm -rf /var/lib/apt/lists/*

# Julia dependencies
# install Julia packages in /opt/julia instead of $HOME
ENV JULIA_DEPOT_PATH=/opt/julia/depot
ENV JULIA_PKGDIR=/opt/julia/pkgdir
ENV JULIA_VERSION=0.7.0
ENV PYTHON=/opt/conda/bin/python

# First install v0.7.0 to help debug old packages/examples
RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    echo "35211bb89b060bfffe81e590b8aeb8103f059815953337453f632db9d96c1bd6 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz

# Now install a recent version v1.*
ENV JULIA_VERSION=1.0.2
RUN mkdir /opt/julia-${JULIA_VERSION} && \
    cd /tmp && \
    wget -q https://julialang-s3.julialang.org/bin/linux/x64/`echo ${JULIA_VERSION} | cut -d. -f 1,2`/julia-${JULIA_VERSION}-linux-x86_64.tar.gz && \
    echo "e0e93949753cc4ac46d5f27d7ae213488b3fef5f8e766794df0058e1b3d2f142 *julia-${JULIA_VERSION}-linux-x86_64.tar.gz" | sha256sum -c - && \
    tar xzf julia-${JULIA_VERSION}-linux-x86_64.tar.gz -C /opt/julia-${JULIA_VERSION} --strip-components=1 && \
    rm /tmp/julia-${JULIA_VERSION}-linux-x86_64.tar.gz
RUN ln -fs /opt/julia-${JULIA_VERSION}/bin/julia /usr/local/bin/julia

# Show Julia where conda libraries are \
RUN mkdir /etc/julia && \
    echo "push!(Libdl.DL_LOAD_PATH, \"$CONDA_DIR/lib\")" >> /etc/julia/juliarc.jl && \
    # Create JULIA_PKGDIR \
    mkdir /opt/julia && \ 
    mkdir $JULIA_PKGDIR && \
    chown $NB_USER $JULIA_PKGDIR && \
    mkdir $JULIA_DEPOT_PATH && \
    chown $NB_USER $JULIA_DEPOT_PATH && \
    fix-permissions $JULIA_DEPOT_PATH && \
    fix-permissions $JULIA_PKGDIR

USER $NB_UID

# Astropy
RUN conda install astropy --yes

# Module for PyCall
RUN conda install pyqt --yes

# Install Jupyter notebook extensions
RUN conda install -c conda-forge jupyter_contrib_nbextensions --yes
RUN jupyter contrib nbextension install --user
RUN jupyter nbextension enable code_font_size/code_font_size
RUN jupyter nbextension enable codefolding/main
RUN jupyter nbextension enable exercise2/main
RUN jupyter nbextension enable rubbermand/main
RUN jupyter nbextension enable scratchpad/main
RUN jupyter nbextension enable spellchecker/main
RUN jupyter nbextension enable toc2/main
RUN jupyter nbextension enable tree-filter/index


# Allow python to call Julia
RUN python3 -m pip install --user julia --no-warn-script-location

# R packages including IRKernel which gets installed globally.
RUN conda install --quiet --yes \
    'rpy2=2.8*' \
    'r-base=3.4.1' \
    'r-irkernel=0.8*' 
#    'r-plyr=1.8*' \
#    'r-devtools=1.13*' \
#    'r-tidyverse=1.1*' \
#    'r-shiny=1.0*' \
#    'r-rmarkdown=1.8*' \
#    'r-forecast=8.2*' \
#    'r-rsqlite=2.0*' \
#    'r-reshape2=1.4*' \
#    'r-nycflights13=0.2*' \
#    'r-caret=6.0*' \
#    'r-rcurl=1.95*' \
#    'r-crayon=1.3*' \
#    'r-randomforest=4.6*' \
#    'r-htmltools=0.3*' \
#    'r-sparklyr=0.7*' \
#    'r-htmlwidgets=1.0*' \
#    'r-hexbin=1.27*' && \
#    conda clean -tipsy && \
RUN    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Add Julia packages. Only add HDF5 if this is not a test-only build since
# it takes roughly half the entire build time of all of the images on Travis
# to add this one package and often causes Travis to timeout.
#
# Install IJulia as jovyan and then move the kernelspec out
# to the system share location. Avoids problems with runtime UID change not
# taking effect properly on the .local folder in the jovyan home dir.

# First for v0.7
RUN /opt/julia-0.7.0/bin/julia -e 'import Pkg; Pkg.update()' && \
    /opt/julia-0.7.0/bin/julia -e 'import Pkg; Pkg.add("Glob")' && \
    /opt/julia-0.7.0/bin/julia -e 'import Pkg; Pkg.add("NBInclude")' && \
    /opt/julia-0.7.0/bin/julia -e 'import Pkg; Pkg.add("Weave")' && \
    /opt/julia-0.7.0/bin/julia -e 'import Pkg; Pkg.add("Conda")' && \
    /opt/julia-0.7.0/bin/julia -e 'import Pkg; Pkg.add("PyCall")' && \
    /opt/julia-0.7.0/bin/julia -e 'import Pkg; Pkg.add("LaTeXStrings")' && \
    /opt/julia-0.7.0/bin/julia -e 'import Pkg; Pkg.add("PyPlot")' && \
    /opt/julia-0.7.0/bin/julia -e 'import Pkg; Pkg.add("Plots")' && \
    /opt/julia-0.7.0/bin/julia -e 'import Pkg; Pkg.add("IJulia")' && \
    /opt/julia-0.7.0/bin/julia -e 'using Glob' && \
    /opt/julia-0.7.0/bin/julia -e 'using NBInclude' && \
    /opt/julia-0.7.0/bin/julia -e 'using Weave' && \
    /opt/julia-0.7.0/bin/julia -e 'using Conda' && \
    /opt/julia-0.7.0/bin/julia -e 'using PyCall' && \
    /opt/julia-0.7.0/bin/julia -e 'using LaTeXStrings' && \
    /opt/julia-0.7.0/bin/julia -e 'using PyPlot' && \
    /opt/julia-0.7.0/bin/julia -e 'using Plots' && \
    /opt/julia-0.7.0/bin/julia -e 'using IJulia' 

# Now for v1.*
RUN julia -e 'import Pkg; Pkg.update()' && \
    (test $TEST_ONLY_BUILD || julia -e 'import Pkg; Pkg.add("HDF5")') && \
    (test $TEST_ONLY_BUILD || julia -e 'import Pkg; Pkg.add("FITSIO")') && \
    julia -e 'import Pkg; Pkg.add("Glob")' && \
    julia -e 'import Pkg; Pkg.add("NBInclude")' && \
    julia -e 'import Pkg; Pkg.add("Weave")' && \
    julia -e 'import Pkg; Pkg.add("DataFrames")' && \
    julia -e 'import Pkg; Pkg.add("CSV")' && \
    julia -e 'import Pkg; Pkg.add("Distributions")' && \
    #julia -e 'import Pkg; Pkg.add("Gadfly")' && \
    #julia -e 'import Pkg; Pkg.add("RDatasets")' && \
    julia -e 'import Pkg; Pkg.add("Conda")' && \
    julia -e 'import Pkg; Pkg.add("PyCall")' && \
    julia -e 'import Pkg; Pkg.add("LaTeXStrings")' && \
    julia -e 'import Pkg; Pkg.add("PyPlot")' && \
    julia -e 'import Pkg; Pkg.add("Plots")' && \
    julia -e 'import Pkg; Pkg.add("IJulia"); Pkg.build("IJulia")' && \
    # Precompile Julia packages \
    julia -e 'using Glob' && \
    julia -e 'using NBInclude' && \
    julia -e 'using Weave' && \
    julia -e 'using DataFrames' && \
    julia -e 'using CSV' && \
    julia -e 'using Distributions' && \
    #julia -e 'using Gadfly' && \
    #julia -e 'using RDatasets' && \
    julia -e 'using Conda' && \
    julia -e 'using PyCall' && \
    julia -e 'using LaTeXStrings' && \
    julia -e 'using PyPlot' && \
    julia -e 'using Plots' && \
    julia -e 'using IJulia' && \
    # move kernelspec out of home \
    mv $HOME/.local/share/jupyter/kernels/julia* $CONDA_DIR/share/jupyter/kernels/ && \
    chmod -R go+rx $CONDA_DIR/share/jupyter && \
    rm -rf $HOME/.local && \
    fix-permissions $JULIA_PKGDIR $CONDA_DIR/share/jupyter
