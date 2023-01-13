# Control flows

Please [install the prerequisites](../README.md) first!

## Quick start with Docker

```
$ docker run --rm --runtime=io.containerd.wasmedge.v1 --platform=wasi/wasm32 secondstate/rust-example-control:latest
Hello WasmEdge!
Howdy WasmEdge!
Hola WasmEdge!
Bonjour WasmEdge!
guten tag WasmEdge!
WasmEdge 你好!
こんにちは  WasmEdge!
Salve WasmEdge!
Salve WasmEdge!
```

## Code

The [`src/main.rs`](src/main.rs) source code shows

* The `for` loop starts from value `0` and repeats `10` times, each increasing by `1`.
* The `match` clause matches the control variable to specific values and branches to the corresponding statements. If control variable does not match any listed value, it will match to the `_` branch.


## Step by step guide

Compile the Rust source code project to a Wasm bytecode file.

```
$ cargo build --target wasm32-wasi
```

Run the Wasm bytecode file in WasmEdge CLI.

```
$ wasmedge target/wasm32-wasi/debug/control.wasm
Hello WasmEdge!
Howdy WasmEdge!
Hola WasmEdge!
Bonjour WasmEdge!
guten tag WasmEdge!
WasmEdge 你好!
こんにちは  WasmEdge!
Salve WasmEdge!
Salve WasmEdge!
```

## Build and publish on Docker

The `Dockerfile` follows the above steps to build and package a lightweight OCI-compliant container image for the Wasm app.
Now, we need to publish the container image to Docker Hub. The process is slightly different depending on how you plan to use the image.

### For Docker Desktop and containerd

For containerd based systems, such as the Docker Desktop and many flavors of Kubernetes,
you just need to specify that the WasmEdge application image is for the `wasi/wasm32` platform.

```
$ docker buildx build --platform wasi/wasm32 -t secondstate/rust-example-control .
... ...
$ docker push secondstate/rust-example-control
```

### For Podman, OpenShift and CRI-O

For `crun` based systems, such as Podman, OpenShift and CRI-O,
you will need to specify a special annotation for the image so that `crun` knowns to use WasmEdge to run it.
In this example, we push the image to Docker Hub with a `crun` tag.

```
$ sudo buildah build --annotation "module.wasm.image/variant=compat-smart" -t rust-example-control .
#
# make sure docker is install and running
# systemctl status docker
# to make sure regular user can use docker
# sudo usermod -aG docker $USER#
# newgrp docker

# You may need to use docker login to create the `~/.docker/config.json` for auth.
#
# docker login

$ sudo buildah push --authfile ~/.docker/config.json rust-example-string docker://docker.io/secondstate/rust-example-control:crun
```

