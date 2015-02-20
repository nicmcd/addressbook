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