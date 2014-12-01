.SUFFIXES:

CXX := g++
CFLAGS := -Wall -Wextra -O2 -pedantic --std=c++11 -Wfatal-errors
CFLAGS += -Isrc
CFLAGS += $(shell pkg-config --cflags protobuf)
LD_FLAGS := $(shell pkg-config --libs protobuf)
LINT_FLAGS := --filter=-legal/copyright,-readability/streams,-build/namespaces

.PHONY: all clean cleanbin cleanbld

all: bin/manager bin/search bin/unit_tests

bin/manager: bld/src/manager/manager.cc.o bld/src/common/addressbook.pb.cc.o bld/src/common/dummy.cc.o | bin
	$(CXX) $(CFLAGS) -o bin/manager bld/src/manager/manager.cc.o bld/src/common/addressbook.pb.cc.o bld/src/common/dummy.cc.o $(LD_FLAGS)

bin/search: bld/src/search/search.cc.o bld/src/common/addressbook.pb.cc.o bld/src/common/dummy.cc.o bld/libz.exists | bin
	$(CXX) $(CFLAGS) -o bin/search bld/src/search/search.cc.o bld/src/common/addressbook.pb.cc.o bld/src/common/dummy.cc.o $(LD_FLAGS) -lz

bin/unit_tests: bld/src/common/dummy_TEST.cc.o bld/src/common/dummy.cc.o | bin
	$(CXX) $(CFLAGS) -o bin/unit_tests /home/nic/.google/gtest-1.7.0/make/gtest_main.a bld/src/common/dummy_TEST.cc.o bld/src/common/dummy.cc.o $(LD_FLAGS)

bin:
	mkdir -p bin

bld/src/manager/manager.cc.o: src/common/addressbook.pb.h bld/src/manager/manager.cc.lint | bld/src/manager 
	$(CXX) $(CFLAGS) -c -o bld/src/manager/manager.cc.o src/manager/manager.cc

bld/src/manager:
	mkdir -p bld/src/manager

bld/src/search/search.cc.o: src/common/addressbook.pb.h bld/src/search/search.cc.lint | bld/src/search 
	$(CXX) $(CFLAGS) -Ilib -c -o bld/src/search/search.cc.o src/search/search.cc

bld/src/search:
	mkdir -p bld/src/search

bld/src/common/addressbook.pb.cc.o: src/common/addressbook.pb.cc src/common/addressbook.pb.h | bld/src/common
	$(CXX) $(CFLAGS) -c -o bld/src/common/addressbook.pb.cc.o src/common/addressbook.pb.cc

bld/src/common/dummy.cc.o: bld/src/common/dummy.cc.lint bld/src/common/dummy.h.lint | bld/src/common 
	$(CXX) $(CFLAGS) -c -o bld/src/common/dummy.cc.o src/common/dummy.cc

bld/src/common/dummy_TEST.cc.o: bld/src/common/dummy_TEST.cc.lint | bld/src/common 
	$(CXX) $(CFLAGS) -I/home/nic/.google/gtest-1.7.0/include -c -o bld/src/common/dummy_TEST.cc.o src/common/dummy_TEST.cc

bld/src/common:
	mkdir -p bld/src/common

src/manager/manager.cc: src/common/addressbook.pb.h

src/search/search.cc: src/common/addressbook.pb.h

src/common/dummy.cc: src/common/dummy.h

src/common/dummy_TEST.cc: src/common/dummy.h

bld/src/manager/manager.cc.lint: src/manager/manager.cc | bld/src/manager
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/manager/manager.cc && echo "linted" > bld/src/manager/manager.cc.lint

bld/src/search/search.cc.lint: src/search/search.cc | bld/src/search
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/search/search.cc && echo "linted" > bld/src/search/search.cc.lint

bld/src/common/dummy.cc.lint: src/common/dummy.cc | bld/src/common
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/common/dummy.cc && echo "linted" > bld/src/common/dummy.cc.lint

bld/src/common/dummy.h.lint: src/common/dummy.h | bld/src/common
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/common/dummy.h && echo "linted" > bld/src/common/dummy.h.lint

bld/src/common/dummy_TEST.cc.lint: src/common/dummy_TEST.cc | bld/src/common
	python ~/.google/cpplint.py --root=src $(LINT_FLAGS) src/common/dummy_TEST.cc && echo "linted" > bld/src/common/dummy_TEST.cc.lint

src/common/addressbook.pb.cc: src/common/addressbook.proto
	cd src; protoc --cpp_out=. common/addressbook.proto

src/common/addressbook.pb.h: src/common/addressbook.proto
	cd src; protoc --cpp_out=. common/addressbook.proto

bld/libz.exists:
	ldconfig -p | egrep "^\s*libz\.so" > bld/libz.exists

clean: cleanbin cleanbld 

cleanbin:
	rm -rf bin 

cleanbld:
	rm -rf bld
	rm -f src/common/addressbook.pb.cc src/common/addressbook.pb.h
