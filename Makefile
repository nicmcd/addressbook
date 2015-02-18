.SUFFIXES:

CXX := g++
CFLAGS := -Wall -Wextra -O2 -pedantic --std=c++11 -Wfatal-errors
CFLAGS += -Isrc
CFLAGS += $(shell pkg-config --cflags protobuf)
LD_FLAGS := $(shell pkg-config --libs protobuf)
LINT_FLAGS := --filter=-legal/copyright,-readability/streams,-build/namespaces

.PHONY: all clean cleanbin cleanbld

all: bin/manager bin/search bin/unit_tests bin/graph.png

########################################
### Directory building
bin:
	mkdir -p bin

bld:
	mkdir -p bld

bld/src/common:
	mkdir -p bld/src/common

bld/src/manager:
	mkdir -p bld/src/manager

bld/src/search:
	mkdir -p bld/src/search

########################################
### Executable linking
bin/manager: bld/src/manager/manager.cc.o bld/src/common/libcommon.a | bin
	$(CXX) $(CFLAGS) -o bin/manager bld/src/manager/manager.cc.o bld/src/common/libcommon.a $(LD_FLAGS)

bin/search: bld/src/search/search.cc.o bld/src/common/libcommon.a | bin
	$(CXX) $(CFLAGS) -o bin/search bld/src/search/search.cc.o bld/src/common/libcommon.a $(LD_FLAGS) -lz

bin/unit_tests: bld/src/common/dummy_TEST.cc.o bld/src/common/dummy.cc.o gtest/make/gtest_main.a | bin
	$(CXX) $(CFLAGS) -o bin/unit_tests gtest/make/gtest_main.a bld/src/common/dummy_TEST.cc.o bld/src/common/dummy.cc.o $(LD_FLAGS)

########################################
### Shared static library archive
bld/src/common/libcommon.a: bld/src/common/AddressBook.pb.cc.o bld/src/common/Person.pb.cc.o bld/src/common/PhoneNumber.pb.cc.o bld/src/common/dummy.cc.o | bld/src/common
	ar cr bld/src/common/libcommon.a bld/src/common/AddressBook.pb.cc.o bld/src/common/Person.pb.cc.o bld/src/common/PhoneNumber.pb.cc.o bld/src/common/dummy.cc.o

########################################
### Object file compilation
bld/src/manager/manager.cc.o: src/common/AddressBook.pb.h bld/src/manager/manager.cc.lint | bld/src/manager
	$(CXX) $(CFLAGS) -c -o bld/src/manager/manager.cc.o src/manager/manager.cc

bld/src/search/search.cc.o: src/common/AddressBook.pb.h bld/src/search/search.cc.lint bld/libz.exists | bld/src/search
	$(CXX) $(CFLAGS) -c -o bld/src/search/search.cc.o src/search/search.cc

bld/src/common/dummy.cc.o: bld/src/common/dummy.cc.lint bld/src/common/dummy.h.lint | bld/src/common
	$(CXX) $(CFLAGS) -c -o bld/src/common/dummy.cc.o src/common/dummy.cc

bld/src/common/dummy_TEST.cc.o: bld/src/common/dummy_TEST.cc.lint | bld/src/common
	$(CXX) $(CFLAGS) -Igtest/include -c -o bld/src/common/dummy_TEST.cc.o src/common/dummy_TEST.cc

bld/src/common/AddressBook.pb.cc.o: src/common/AddressBook.pb.cc src/common/AddressBook.pb.h | bld/src/common
	$(CXX) $(CFLAGS) -c -o bld/src/common/AddressBook.pb.cc.o src/common/AddressBook.pb.cc

bld/src/common/Person.pb.cc.o: src/common/Person.pb.cc src/common/Person.pb.h | bld/src/common
	$(CXX) $(CFLAGS) -c -o bld/src/common/Person.pb.cc.o src/common/Person.pb.cc

bld/src/common/PhoneNumber.pb.cc.o: src/common/PhoneNumber.pb.cc src/common/PhoneNumber.pb.h | bld/src/common
	$(CXX) $(CFLAGS) -c -o bld/src/common/PhoneNumber.pb.cc.o src/common/PhoneNumber.pb.cc

########################################
### C++ linting
bld/src/manager/manager.cc.lint: src/manager/manager.cc | bld/src/manager
	python cpplint/cpplint.py --root=src $(LINT_FLAGS) src/manager/manager.cc && echo "linted" > bld/src/manager/manager.cc.lint

bld/src/search/search.cc.lint: src/search/search.cc | bld/src/search
	python cpplint/cpplint.py --root=src $(LINT_FLAGS) src/search/search.cc && echo "linted" > bld/src/search/search.cc.lint

bld/src/common/dummy.cc.lint: src/common/dummy.cc | bld/src/common
	python cpplint/cpplint.py --root=src $(LINT_FLAGS) src/common/dummy.cc && echo "linted" > bld/src/common/dummy.cc.lint

bld/src/common/dummy.h.lint: src/common/dummy.h | bld/src/common
	python cpplint/cpplint.py --root=src $(LINT_FLAGS) src/common/dummy.h && echo "linted" > bld/src/common/dummy.h.lint

bld/src/common/dummy_TEST.cc.lint: src/common/dummy_TEST.cc | bld/src/common
	python cpplint/cpplint.py --root=src $(LINT_FLAGS) src/common/dummy_TEST.cc && echo "linted" > bld/src/common/dummy_TEST.cc.lint

########################################
### Protobuf code generation & dependencies
src/common/AddressBook.pb.cc: src/common/AddressBook.proto src/common/AddressBook.pb.h
	cd src; protoc --cpp_out=. common/AddressBook.proto

src/common/AddressBook.pb.h: src/common/AddressBook.proto src/common/Person.pb.h
	cd src; protoc --cpp_out=. common/AddressBook.proto

src/common/Person.pb.cc: src/common/Person.proto src/common/Person.pb.h
	cd src; protoc --cpp_out=. common/Person.proto

src/common/Person.pb.h: src/common/Person.proto src/common/PhoneNumber.pb.h
	cd src; protoc --cpp_out=. common/Person.proto

src/common/PhoneNumber.pb.cc: src/common/PhoneNumber.proto src/common/PhoneNumber.pb.h
	cd src; protoc --cpp_out=. common/PhoneNumber.proto

src/common/PhoneNumber.pb.h: src/common/PhoneNumber.proto
	cd src; protoc --cpp_out=. common/PhoneNumber.proto

########################################
### Library existence check
bld/libz.exists: | bld
	ldconfig -p | egrep "^\s*libz\.so" > bld/libz.exists

########################################
### Source dependencies
src/manager/manager.cc: src/common/AddressBook.pb.h src/common/dummy.h

src/search/search.cc: src/common/AddressBook.pb.h src/common/dummy.h

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
clean: cleanbin cleanpb cleanbld

cleanall: cleanbin cleanpb cleanbld cleansub

cleanbin:
	rm -rf bin

cleanbld:
	rm -rf bld

cleanpb:
	rm -f src/common/AddressBook.pb.cc src/common/AddressBook.pb.h
	rm -f src/common/Person.pb.cc src/common/Person.pb.h
	rm -f src/common/PhoneNumber.pb.cc src/common/PhoneNumber.pb.h

cleansub:
	cd gtest/make; make clean
