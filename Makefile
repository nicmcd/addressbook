CXX := g++-4.8
CFLAGS := -Wall -Wextra -O2 -pedantic --std=c++11
CFLAGS += -Isrc
CFLAGS += $(shell pkg-config --cflags protobuf)
LD_FLAGS := $(shell pkg-config --libs protobuf)
LINT_FLAGS := --filter=-legal/copyright,-readability/streams,-build/namespaces

.PHONY: clean

all: bin/manager bin/search

bin/manager: bin bld/manager/manager.cc.o bld/common/addressbook.pb.cc.o bld/common/welcome.cc.o
	$(CXX) $(CFLAGS) -o bin/manager bld/manager/manager.cc.o bld/common/addressbook.pb.cc.o bld/common/welcome.cc.o $(LD_FLAGS)

bin/search: bin bld/search/search.cc.o bld/common/addressbook.pb.cc.o bld/common/welcome.cc.o
	$(CXX) $(CFLAGS) -o bin/search bld/search/search.cc.o bld/common/addressbook.pb.cc.o bld/common/welcome.cc.o $(LD_FLAGS)

bin:
	mkdir -p bin

bld/manager/manager.cc.o: bld/manager src/manager/manager.cc src/common/addressbook.pb.h bld/manager/manager.cc.lint
	$(CXX) $(CFLAGS) -c -o bld/manager/manager.cc.o src/manager/manager.cc

bld/manager:
	mkdir -p bld/manager

bld/search/search.cc.o: bld/search src/search/search.cc src/common/addressbook.pb.h bld/search/search.cc.lint
	$(CXX) $(CFLAGS) -c -o bld/search/search.cc.o src/search/search.cc

bld/search:
	mkdir -p bld/search

bld/common/addressbook.pb.cc.o: bld/common src/common/addressbook.pb.cc src/common/addressbook.pb.h
	$(CXX) $(CFLAGS) -c -o bld/common/addressbook.pb.cc.o src/common/addressbook.pb.cc

bld/common/welcome.cc.o: bld/common src/common/welcome.cc src/common/welcome.h bld/common/welcome.cc.lint bld/common/welcome.h.lint
	$(CXX) $(CFLAGS) -c -o bld/common/welcome.cc.o src/common/welcome.cc

bld/common:
	mkdir -p bld/common

src/manager/manager.cc: src/common/addressbook.pb.h

src/search/search.cc: src/common/addressbook.pb.h

bld/manager/manager.cc.lint:
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/manager/manager.cc && echo "linted" > bld/manager/manager.cc.lint

bld/search/search.cc.lint:
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/search/search.cc && echo "linted" > bld/search/search.cc.lint

bld/common/welcome.cc.lint:
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/common/welcome.cc && echo "linted" > bld/common/welcome.cc.lint

bld/common/welcome.h.lint:
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/common/welcome.h && echo "linted" > bld/common/welcome.h.lint

src/common/addressbook.pb.cc: src/common/addressbook.proto
	cd src; protoc --cpp_out=. common/addressbook.proto

src/common/addressbook.pb.h: src/common/addressbook.proto
	cd src; protoc --cpp_out=. common/addressbook.proto

clean:
	rm -rf bin bld src/common/addressbook.pb.cc src/common/addressbook.pb.h
