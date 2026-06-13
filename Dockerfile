FROM hexpm/elixir:1.18.3-erlang-27.3.3-alpine-3.21.3 AS deps

RUN apk add --no-cache build-base git
WORKDIR /app
RUN mix local.hex --force && mix local.rebar --force
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

FROM deps AS build
ENV MIX_ENV=prod
COPY config ./config
COPY lib ./lib
COPY priv ./priv
RUN mix deps.compile
RUN mix compile
RUN mix release

FROM alpine:3.21.3 AS runtime
RUN apk add --no-cache ncurses-libs openssl libstdc++ bash docker-cli
WORKDIR /app
COPY --from=build /app/_build/prod/rel/hippocampus ./
EXPOSE 4083
ENV HOME=/app PORT=4083 MIX_ENV=prod SHELL=/bin/bash
HEALTHCHECK --interval=30s --timeout=3s --start-period=20s --retries=3 \
    CMD wget --spider -q http://localhost:4083/health || exit 1
CMD ["bin/hippocampus", "start"]
