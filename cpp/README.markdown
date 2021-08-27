# CocoaFob

## C++ implementation
Jaime O. Rios

## Introduction
This is the C++ port of CocoaFob, which allows for the same type of functionality Obj-C and Swift developers have, on any platform that supports C++.

This port uses CMake so you can create project files for the development environment your most comfortable with.

## Requirements
* CMake 3.16.2 or greater

## Building

Here's an example of how to build an Xcode project:

`cmake -S . -B build -G "Xcode"`

Navigate to the build folder, where you will find the the Xcode project file.

To see all of the build tools (Generators) that CMake supports you can bring up the list in the help guide:

`cmake --help`
