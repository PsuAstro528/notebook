# Python Notebook with Julia Docker Image

Custom Python notebook and Julia server for PsuAstro528.  This is a customization of `jupyter/datascience-notebook`. See 
[https://jupyter-docker-stacks.readthedocs.io](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-datascience-notebook)
for a full list of notebooks available.

## Usage

@todo: this isn't set up yet. Needs configured through docker hub.

docker command
```
docker run --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v "$PWD":/home/jovyan/work PSUAstro528/notebook
```

docker-compose
```
notebook:
  image: PSUAstro528/notebook
  volumes:
    - .:/home/jovyan/work
  ports:
    - 8888:8888
```


## Development

To add new libraries to the image add commands using the `RUN` prefix in `Dockerfile`.

### Jupyter Notebook

This will start the Jupyter notebook and bind it to `localhost:8888`

```
docker-compose up
```

### Access Server

This command will spin up a container with this image and enter you into bash. 

```
docker-compose run --rm notebook bash
```