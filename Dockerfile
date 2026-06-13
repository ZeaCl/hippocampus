FROM hexpm/elixir:1.18.3-erlang-27.3.3-alpine-3.21.3 AS builder

WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force

COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

COPY config ./config
COPY lib ./lib
COPY priv ./priv

RUN mix compile
RUN mix release hippocampus

FROM alpine:3.21.3
RUN apk add --no-cache openssl ncurses-libs libstdc++ docker-cli

COPY --from=builder /app/_build/prod/rel/hippocampus /app
EXPOSE 4083
CMD ["/app/bin/hippocampus", "start"]
