# kuksa-automobile

## Running

### Podman Compose

```
podman-compose up --force-recreate --build --detach
```

### Manually

You will need to build each image (located in the images folder) with the following name
scheme: `localhost/$dirname:latest`.

#### Kuksa Val Server

```sh
podman run -it \
--replace \
--network=host \
--name kuksa-val-server \
-p 8090:8090 \
-p 50051:50051 \
localhost/kuksa-val-server:latest
```

#### Kuksa Databrokser

```sh
podman run \
-it --replace \
--network host \
--name kuksa-databroker \
-p 55555:55555 \
localhost/kuksa-databroker:latest	
```

### Kuksa Client

```sh
podman run -it \
--replace \
--network=host \
--name kuksa-client \
localhost/kuksa-client:latest
```

## Testing

### Kuksa Databroker

The databroker can be tested by running pub and sub apps from the kuksa-client container:

```sh
podman exec -it kuksa-client /opt/app/pubsub pub
```

```sh
podman exec -it kuksa-client /opt/app/pubsub sub
```

### Kuska Val Server

The server can be tested to run both "setvalue" and "getvalue" from the ckuksa-client container:

```sh
podman exec -it kuksa-client /opt/app/pubsub setvalue
```

```sh
podman exec -it kuksa-client /opt/app/pubsub getvalue
```

## License

[GPLv3-only](./LICENSE)
