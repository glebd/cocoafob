cmake_minimum_required(VERSION 3.16.2)

######################################################################
# Project/solution name
project(CocoaFob VERSION 1.0)

# C++17
set(CMAKE_CXX_STANDARD 17)

# Folders for IDEs that support it
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# We need to specify these types since we are supporting multi-config IDEs like Xcode and Visual Studio
list(APPEND CMAKE_CONFIGURATION_TYPES "Debug" "Release")

######################################################################
# Conan helper to download required files
include(ConanHelper.cmake)

# Packages that project needs
conan_cmake_configure(
    REQUIRES
        openssl/1.0.2s
        catch2/2.13.7
    GENERATORS
        cmake_find_package_multi
)

# Each config has to be set up for each package, so we'll loop through each (Debug, Release)
foreach(type ${CMAKE_CONFIGURATION_TYPES})
    conan_cmake_autodetect(settings BUILD_TYPE ${type})
    conan_cmake_install(PATH_OR_REFERENCE .
                        BUILD missing
                        REMOTE conan-center
                        SETTINGS ${settings})
endforeach()

# Now call find_package
find_package(OpenSSL CONFIG)
find_package(catch2 CONFIG)

######################################################################
# Header and source files
set(base32_header_files
    "source/base32/decoder.h"
    "source/base32/encoder.h"
)
source_group(TREE "${CMAKE_SOURCE_DIR}/source" PREFIX "Header files" FILES ${base32_header_files})

set(header_files
    "source/CFobInternal.hpp"
)
source_group(TREE "${CMAKE_SOURCE_DIR}/source" PREFIX "Header files" FILES ${header_files})

set(include_files
    "include/CocoaFob/CFobCrypto.hpp"
    "include/CocoaFob/CFobDataTypes.hpp"
    "include/CocoaFob/CFobLicGenerator.hpp"
    "include/CocoaFob/CFobLicVerifier.hpp"
)
source_group(TREE "${CMAKE_SOURCE_DIR}/include" PREFIX "include files" FILES ${include_files})

set(source_files
    "source/base32/decoder.c"
    "source/base32/encoder.c"

    "source/CFobCrypto.cpp"
    "source/CFobInternal.cpp"
    "source/CFobLicGenerator.cpp"
    "source/CFobLicVerifier.cpp"
)
source_group(TREE "${CMAKE_SOURCE_DIR}/source" PREFIX "Source files" FILES ${source_files})

set(all_files
    ${base32_header_files}
    ${header_files}
    ${include_files}
    ${source_files}
)

######################################################################
# Static library target declaration
add_library(CocoaFob STATIC ${all_files})

# Internal
target_include_directories(CocoaFob
    PRIVATE
        "${CMAKE_SOURCE_DIR}/source/"
        "${CMAKE_SOURCE_DIR}/source/base32"
)

# Shared header search paths with projects that link against this target
target_include_directories(CocoaFob
    PUBLIC
        "${CMAKE_SOURCE_DIR}/include"
)

target_link_libraries(CocoaFob
    PUBLIC
        OpenSSL::OpenSSL
)

######################################################################
# install step setup
install(FILES ${include_files} DESTINATION "include/CocoaFob")
install(TARGETS CocoaFob
        CONFIGURATIONS Debug
        RUNTIME DESTINATION lib/Debug)
install(TARGETS CocoaFob
        CONFIGURATIONS Release
        RUNTIME DESTINATION lib/Release)

# Unit test target
add_subdirectory(ctest)
