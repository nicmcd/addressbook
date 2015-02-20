.SUFFIXES:

CXX := g++
CFLAGS := -Wall -Wextra -O2 -pedantic --std=c++11 -Wfatal-errors
CFLAGS += -Isrc -Igen
CFLAGS += $(shell pkg-config --cflags protobuf)
LD_FLAGS := $(shell pkg-config --libs protobuf)
LINT_FLAGS := --filter=-legal/copyright,-readability/streams,-build/namespaces

.PHONY: all clean cleanall cleanbin cleangen cleanbld cleansub

all: bin/manager bin/search bin/unit_tests bin/graph.png

########################################
### Directory building
bin:
	mkdir bin

gen:
	mkdir gen

gen/common: | gen
	mkdir gen/common

gen/manager: | gen
	mkdir gen/manager

gen/search: | gen
	mkdir gen/search

bld:
	mkdir bld

bld/common: | bld
	mkdir bld/common

bld/manager: | bld
	mkdir bld/manager

bld/search: | bld
	mkdir bld/search

########################################
### Executable linking
bin/manager: bld/manager/manager.cc.o bld/common/libcommon.a | bin
	$(CXX) $(CFLAGS) -o bin/manager bld/manager/manager.cc.o bld/common/libcommon.a $(LD_FLAGS)

bin/search: bld/search/search.cc.o bld/common/libcommon.a | bin
	$(CXX) $(CFLAGS) -o bin/search bld/search/search.cc.o bld/common/libcommon.a $(LD_FLAGS) -lz

bin/unit_tests: bld/common/dummy_TEST.cc.o bld/common/dummy.cc.o gtest/make/gtest_main.a | bin
	$(CXX) $(CFLAGS) -o bin/unit_tests gtest/make/gtest_main.a bld/common/dummy_TEST.cc.o bld/common/dummy.cc.o $(LD_FLAGS)

########################################
### Shared static library archive
bld/common/libcommon.a: bld/common/AddressBook.pb.cc.o bld/common/Person.pb.cc.o bld/common/PhoneNumber.pb.cc.o bld/common/dummy.cc.o | bld/common
	ar cr bld/common/libcommon.a bld/common/AddressBook.pb.cc.o bld/common/Person.pb.cc.o bld/common/PhoneNumber.pb.cc.o bld/common/dummy.cc.o

########################################
### Object file compilation
bld/manager/manager.cc.o: gen/common/AddressBook.pb.h bld/manager/manager.cc.lint | bld/manager
	$(CXX) $(CFLAGS) -c -o bld/manager/manager.cc.o src/manager/manager.cc

bld/search/search.cc.o: gen/common/AddressBook.pb.h bld/search/search.cc.lint bld/libz.exists | bld/search
	$(CXX) $(CFLAGS) -c -o bld/search/search.cc.o src/search/search.cc

bld/common/dummy.cc.o: bld/common/dummy.cc.lint bld/common/dummy.h.lint | bld/common
	$(CXX) $(CFLAGS) -c -o bld/common/dummy.cc.o src/common/dummy.cc

bld/common/dummy_TEST.cc.o: bld/common/dummy_TEST.cc.lint | bld/common
	$(CXX) $(CFLAGS) -Igtest/include -c -o bld/common/dummy_TEST.cc.o src/common/dummy_TEST.cc

bld/common/AddressBook.pb.cc.o: gen/common/AddressBook.pb.cc gen/common/AddressBook.pb.h | bld/common
	$(CXX) $(CFLAGS) -c -o bld/common/AddressBook.pb.cc.o gen/common/AddressBook.pb.cc

bld/common/Person.pb.cc.o: gen/common/Person.pb.cc gen/common/Person.pb.h | bld/common
	$(CXX) $(CFLAGS) -c -o bld/common/Person.pb.cc.o gen/common/Person.pb.cc

bld/common/PhoneNumber.pb.cc.o: gen/common/PhoneNumber.pb.cc gen/common/PhoneNumber.pb.h | bld/common
	$(CXX) $(CFLAGS) -c -o bld/common/PhoneNumber.pb.cc.o gen/common/PhoneNumber.pb.cc

########################################
### C++ linting
bld/manager/manager.cc.lint: src/manager/manager.cc | bld/manager
	python cpplint/cpplint.py --root=src $(LINT_FLAGS) src/manager/manager.cc && echo "linted" > bld/manager/manager.cc.lint

bld/search/search.cc.lint: src/search/search.cc | bld/search
	python cpplint/cpplint.py --root=src $(LINT_FLAGS) src/search/search.cc && echo "linted" > bld/search/search.cc.lint

bld/common/dummy.cc.lint: src/common/dummy.cc | bld/common
	python cpplint/cpplint.py --root=src $(LINT_FLAGS) src/common/dummy.cc && echo "linted" > bld/common/dummy.cc.lint

bld/common/dummy.h.lint: src/common/dummy.h | bld/common
	python cpplint/cpplint.py --root=src $(LINT_FLAGS) src/common/dummy.h && echo "linted" > bld/common/dummy.h.lint

bld/common/dummy_TEST.cc.lint: src/common/dummy_TEST.cc | bld/common
	python cpplint/cpplint.py --root=src $(LINT_FLAGS) src/common/dummy_TEST.cc && echo "linted" > bld/common/dummy_TEST.cc.lint

########################################
### Protobuf code generation & dependencies
gen/common/AddressBook.pb.cc: src/common/AddressBook.proto gen/common/AddressBook.pb.h | gen/common
	cd src; protoc --cpp_out=../gen common/AddressBook.proto

gen/common/AddressBook.pb.h: src/common/AddressBook.proto gen/common/Person.pb.h | gen/common
	cd src; protoc --cpp_out=../gen common/AddressBook.proto

gen/common/Person.pb.cc: src/common/Person.proto gen/common/Person.pb.h | gen/common
	cd src; protoc --cpp_out=../gen common/Person.proto

gen/common/Person.pb.h: src/common/Person.proto gen/common/PhoneNumber.pb.h | gen/common
	cd src; protoc --cpp_out=../gen common/Person.proto

gen/common/PhoneNumber.pb.cc: src/common/PhoneNumber.proto gen/common/PhoneNumber.pb.h | gen/common
	cd src; protoc --cpp_out=../gen common/PhoneNumber.proto

gen/common/PhoneNumber.pb.h: src/common/PhoneNumber.proto | gen/common
	cd src; protoc --cpp_out=../gen common/PhoneNumber.proto

########################################
### Library existence check
bld/libz.exists: | bld
	ldconfig -p | egrep "^\s*libz\.so" > bld/libz.exists

########################################
### Source dependencies
src/manager/manager.cc: gen/common/AddressBook.pb.h src/common/dummy.h

src/search/search.cc: gen/common/AddressBook.pb.h src/common/dummy.h

src/common/dummy.cc: src/common/dummy.h

src/common/dummy_TEST.cc: src/common/dummy.h

src/common/dummy.h:

src/common/AddressBook.proto: src/common/Person.proto

src/common/Person.proto: src/common/PhoneNumber.proto

src/common/PhoneNumber.proto:

########################################
### GTest submodule
gtest/make/gtest_main.a:
	cd gtest/make; make gtest_main.a

########################################
### Dependency graph
bin/graph.png: graph.gv | bin
	dot -Tpng graph.gv -o bin/graph.png

########################################
### Cleaning
clean: cleanbin cleangen cleanbld

cleanall: cleanbin cleangen cleanbld cleansub

cleanbin:
	rm -rf bin

cleanbld:
	rm -rf bld

cleangen:
	rm -rf gen

cleansub:
	cd gtest/make; make clean
