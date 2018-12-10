FROM jupyter/datascience-notebook

RUN python -m pip install -U matplotlib
RUN python -m pip install -U numpy
RUN python -m pip install -U pip
RUN pip install julia