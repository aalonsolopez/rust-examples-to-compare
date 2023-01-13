# HTTP server

Please [install the prerequisites](../README.md) first!

## Quick start with Docker

```
$ docker run --rm --runtime=io.containerd.wasmedge.v1 --platform=wasi/wasm32 secondstate/rust-example-server:latest
Listening on http://0.0.0.0:8080
```

From another terminal window, do the following.

```
$ curl http://localhost:8080/
Try POSTing data to /echo such as: `curl localhost:8080/echo -XPOST -d 'hello world'`

$ curl http://localhost:8080/echo -X POST -d "Hello WasmEdge!"
Hello WasmEdge!
```

## Code

The [`src/main.rs`](src/main.rs) source code shows how to start an async server using the `hyper` crate.

* The `main()` function is now an `async` function and annotated with the `tokio` macro. That means the tokio controller can spawn multiple instances of the `main()` app.
* Each instance of the `main()` app listens at port 8080 without blocking the port for everyone else. It receives a data `stream` for each incoming HTTP connection it captures.
  * The `accept()` function runs in a loop. It accepts an incoming connection, processes its data, and then start over.
  * The `await` means that the function is async. Multiple instances of an async function can run at the same time. When an async function instance returns, the `await` unblocks the next lines of code and allows the program to continue.
  * In our case, multiple instances of the `accept()` function can listen to the same port. When a request comes in, an instance of `accept()` will receive and process its data, while other instances of `accept()` can wait or process other requests at the same time.
* The `tokio::task::spawn` API designate the `handle_request()` function to be called whenever the data `stream` is available.
* The data in the `stream`, which is a HTTP request is passed to `handle_request()`, and the function returns an HTTP response struct.
* Inside `handle_request()`, it matches both the HTTP request method and path.
  * If the HTTP request is a GET at `/`, it returns a response with a help message.
  * If the HTTP request is a POST at `/echo`, it extracts the HTTP body and reverses it. The reversed string is returned as the HTTP response.
  * If no match is found, it returns an HTTP 404 error code.

## Step by step guide

Compile the Rust source code project to a Wasm bytecode file.

```
$ cargo build --target wasm32-wasi
```

Run the Wasm bytecode file in WasmEdge CLI.

```
$ wasmedge target/wasm32-wasi/debug/server.wasm
Listening on http://0.0.0.0:8080
```

From another terminal window, do the following.

```
$ curl http://localhost:8080/
Try POSTing data to /echo such as: `curl localhost:8080/echo -XPOST -d 'hello world'`

$ curl http://localhost:8080/echo -X POST -d "Hello WasmEdge!"
Hello WasmEdge!
```

## Build and publish on Docker

The `Dockerfile` follows the above steps to build and package a lightweight OCI-compliant container image for the Wasm app.
Now, we need to publish the container image to Docker Hub. The process is slightly different depending on how you plan to use the image.

### For Docker Desktop and containerd

For containerd based systems, such as the Docker Desktop and many flavors of Kubernetes,
you just need to specify that the WasmEdge application image is for the `wasi/wasm32` platform.

```
$ docker buildx build --platform wasi/wasm32 -t secondstate/rust-example-server .
... ...
$ docker push secondstate/rust-example-server
```

### For Podman, OpenShift and CRI-O

For `crun` based systems, such as Podman, OpenShift and CRI-O,
you will need to specify a special annotation for the image so that `crun` knowns to use WasmEdge to run it.
In this example, we push the image to Docker Hub with a `crun` tag.

```
$ sudo buildah build --annotation "module.wasm.image/variant=compat-smart" -t rust-example-server .
#
# make sure docker is install and running
# systemctl status docker
# to make sure regular user can use docker
# sudo usermod -aG docker $USER#
# newgrp docker

# You may need to use docker login to create the `~/.docker/config.json` for auth.
#
# docker login

$ sudo buildah push --authfile ~/.docker/config.json rust-example-string docker://docker.io/secondstate/rust-example-server:crun
```
