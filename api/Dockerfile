FROM rust:1.94
WORKDIR /usr/src/app
COPY Cargo.toml Cargo.lock ./
COPY src ./src
RUN cargo build
CMD ["cargo", "run"]
