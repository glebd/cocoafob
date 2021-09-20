
######################################################################
# Header and source files
set(header_files
    "CFob_ctest_common.hpp"
)
source_group("Header files" FILES ${header_files})

set(source_files
    "CFobCrypto_ctest.cpp"
    "CFobLicGenerator_ctest.cpp"
    "CFobLicVerifier_ctest.cpp"
    "CFob_ctest_common.cpp"
)
source_group("Source files" FILES ${source_files})

######################################################################
# Unit test target setup
add_executable(UnitTests ${source_files} ${header_files})

target_link_libraries(UnitTests
    PRIVATE
        CocoaFob
        Catch2::Catch2
)
