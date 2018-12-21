# Jupyter Notebook Server Customized for Penn State's Astro 528

This is a custom Jupyter notebook server Astro 528 (Spring 2019).  
This includes kernels Julia (v1.0.2 and v0.7.0), R and Python kernels.  
It installs several common tools such as astropy, Jupyter notebook extensions and common Julia packages.
In particular, it sets up Julia so it can call Python and Python so it can call Julia.  This is particularly useful for using PyPlot, either directly or as the backend for Plots.jl.  
While setting it up, I found R installations sometimes stalled.  Therefore, I commented out some of the packages (particularly R pacakges) installed by default.  While R is avaliable, it is untested.

This is a customization of `jupyter/datascience-notebook`. See 
[https://jupyter-docker-stacks.readthedocs.io](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-datascience-notebook)
for a full list of notebooks available.

## Usage

### Install Docker
First, you will need to install [Docker](https://docs.docker.com/get-started/).  Make sure `docker run hello-world` works before proceeding.

### Jupyter Notebook

The following command will start the Jupyter notebook server and bind it to `localhost:8888`

```
docker-compose up
```
Then you can direct your webbrowser to http://127.0.0.1:8888 to access the server.  For security, you will be required to copy and paste a "token" that is displayed in the terminal window before accessing the server.  Note that only files saved in the work directory (or its subdirectories) will remain after you close the Jupyter server and docker.  

When running the docker-compose command, some configuration parameters are specified by the file 
docker-compose
```
notebook:
  image: astro528/notebook
  volumes:
    - .:/home/jovyan/work
  ports:
    - 8888:8888
```
This simple example specifies an image avaliable from cloud.docker.com, specifies which storage location on your local computer will appear as persistent storage in the work directory when running the Jupyter notebook server, and specifies which port the server will be accessible through.  

### Access Server

The following command will spin up a container with this image and enter you into bash.

```
docker run -it psuastro528/notebook bash
```

This can be useful for configuration and testing when you are adapting or building on this repository's Dockerfile for your own purposes.  Alternatively, one can access the shell from the Jupyter notebook server by choosing "New.Terminal".  (The New button is near the upper right.)

### Access Julia REPL

The following command will spin up a temporary container and enter into a Julia REPL.

```
docker run -it --rm psuastro528/notebook julia
```

## Development

You can further customize this container/image by editing the Dockerfile.  
To add new packages to the image add shell commands using the `RUN` prefix in `Dockerfile`.
It's easiest to follow the examples here.
