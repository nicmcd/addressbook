CXX := g++-4.8
CFLAGS := -Wall -Wextra -O2 -pedantic --std=c++11 -Wfatal-errors
CFLAGS += -Isrc
CFLAGS += $(shell pkg-config --cflags protobuf)
LD_FLAGS := $(shell pkg-config --libs protobuf)
LINT_FLAGS := --filter=-legal/copyright,-readability/streams,-build/namespaces

.PHONY: clean

all: bin/manager bin/search bin/unit_tests

bin/manager: bin bld/manager/manager.cc.o bld/common/addressbook.pb.cc.o bld/common/dummy.cc.o
	$(CXX) $(CFLAGS) -o bin/manager bld/manager/manager.cc.o bld/common/addressbook.pb.cc.o bld/common/dummy.cc.o $(LD_FLAGS)

bin/search: bin bld/search/search.cc.o bld/common/addressbook.pb.cc.o bld/common/dummy.cc.o
	$(CXX) $(CFLAGS) -o bin/search bld/search/search.cc.o bld/common/addressbook.pb.cc.o bld/common/dummy.cc.o $(LD_FLAGS)

bin/unit_tests: bin bld/common/dummy_TEST.cc.o bld/common/dummy.cc.o
	$(CXX) $(CFLAGS) -o bin/unit_tests /home/nic/.google/gtest-1.7.0/make/gtest_main.a bld/common/dummy_TEST.cc.o bld/common/dummy.cc.o $(LD_FLAGS)

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

bld/common/dummy.cc.o: bld/common src/common/dummy.cc src/common/dummy.h bld/common/dummy.cc.lint bld/common/dummy.h.lint
	$(CXX) $(CFLAGS) -c -o bld/common/dummy.cc.o src/common/dummy.cc

bld/common/dummy_TEST.cc.o: bld/common src/common/dummy_TEST.cc bld/common/dummy_TEST.cc.lint
	$(CXX) $(CFLAGS) -I/home/nic/.google/gtest-1.7.0/include -c -o bld/common/dummy_TEST.cc.o src/common/dummy_TEST.cc

bld/common:
	mkdir -p bld/common

src/manager/manager.cc: src/common/addressbook.pb.h

src/search/search.cc: src/common/addressbook.pb.h

bld/manager/manager.cc.lint:
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/manager/manager.cc && echo "linted" > bld/manager/manager.cc.lint

bld/search/search.cc.lint:
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/search/search.cc && echo "linted" > bld/search/search.cc.lint

bld/common/dummy.cc.lint:
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/common/dummy.cc && echo "linted" > bld/common/dummy.cc.lint

bld/common/dummy.h.lint:
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/common/dummy.h && echo "linted" > bld/common/dummy.h.lint

bld/common/dummy_TEST.cc.lint:
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/common/dummy_TEST.cc && echo "linted" > bld/common/dummy_TEST.cc.lint

src/common/addressbook.pb.cc: src/common/addressbook.proto
	cd src; protoc --cpp_out=. common/addressbook.proto

src/common/addressbook.pb.h: src/common/addressbook.proto
	cd src; protoc --cpp_out=. common/addressbook.proto

clean:
	rm -rf bin bld src/common/addressbook.pb.cc src/common/addressbook.pb.h
