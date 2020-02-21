ERL_INCLUDE_PATH=/Users/barretthelms/.asdf/installs/erlang/21.1/usr/include

all: priv/fast_compare.so

priv/fast_compare.so: src/nif.c
	cc -fPIC -I$(ERL_INCLUDE_PATH) -dynamiclib -undefined dynamic_lookup -o priv/fast_compare.so src/nif.c


