run:
	iex -S mix phx.server

deps:
	mix deps.get

# first time setup
setup: deps
	mix ecto.create
	mix ecsx.setup

.PHONY: run deps setup

