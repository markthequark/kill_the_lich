run:
	iex -S mix phx.server

# first time setup
setup: deps
	mix ecto.create
	mix ecsx.setup
	mix compile
	mix run priv/repo/seeds.exs

seed:
	mix run priv/repo/seeds.exs

deps:
	mix deps.get

test:
	mix test

pry_test:
	iex -S mix test --trace

format:
	mix format

static_analysis: credo dialyzer

credo:
	mix credo --strict

dialyzer:
	mix dialyzer

clean:
	mix clean

deploy:
	fly deploy

remote:
	fly ssh console -C "/app/bin/ship remote"

.PHONY: run setup seed deps test pry_test format static_analysis credo dialyzer clean deploy remote
