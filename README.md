# AddressBook

This project was built largely from the code found here:
https://developers.google.com/protocol-buffers/docs/cpptutorial

The purpose of this project is to create a complicated build that a future build system
might be able to handle elegantly without explicitly defining all dependencies.

This is a sample C++ application with an explicit Makefile for the build process.
This project builds two binaries which share common code. The common code is
compiled into a static library. The application utilizes multiple imported protobufs.
There is also a graphviz graph definition that graphically shows the dependencies.
The Makefile builds the graph file as well. The application utilizes Google's 
Test framework as well as Google's cpplint syntax checker. The Makefile handles
all of this.

The Makefile is big and ugly. Even worse is that it took me way to long to write and 
verify. I'm hoping there will be a future build system that will allow me to define
custom patterns that can be used to define build targets, dependencies, outputs, etc.
The biggest problem with today's systems is that when you realize you want to add another
layer to your build (e.g. adding gtest for example), it breaks your Makefile. I also don't
want to have to learn another syntax.

## Environment Setup
```bash
sudo apt-get install protobuf-compiler libprotobuf-dev graphviz
```

## Build Process
```bash
git clone git@github.com:nicmcd/addressbook.git
cd addressbook
git submodule init
git submodule update
make
```
