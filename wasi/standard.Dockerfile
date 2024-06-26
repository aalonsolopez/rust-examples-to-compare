FROM rust:alpine3.19

COPY . .

RUN cargo build --release

CMD ["./target/release/wasi"]