# Sample toolchain file for crossiling to RISCV32

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv32)


set(COMPILER_PREFIX /opt/riscv64/bin/)
# Specify the cross compiler
# The target triple needs to match the prefix of the binutils exactly
# (e.g. CMake looks for arm-none-eabi-ar)
set(CMAKE_C_COMPILER ${COMPILER_PREFIX}riscv64-unknown-elf-gcc)
set(CMAKE_CXX_COMPILER ${COMPILER_PREFIX}riscv64-unknown-elf-g++)
set(CMAKE_ASM_COMPILER ${COMPILER_PREFIX}riscv64-unknown-elf-gcc)

# Specify compiler flags
if (CMAKE_SYSTEM_PROCESSOR STREQUAL "riscv32")
set(ARCH_FLAGS "-march=rv32gc")
elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "riscv64")
set(ARCH_FLAGS "-march=rv64gc")
else()
message(FATAL_ERROR "Riscv Toolchain is not support")
endif()
set(CMAKE_C_FLAGS "-Wall -std=gnu11 ${ARCH_FLAGS}")
set(CMAKE_CXX_FLAGS "-Wall -std=gnu++11 ${ARCH_FLAGS}")
set(CMAKE_ASM_FLAGS "-Wall ${ARCH_FLAGS} -x assembler-with-cpp")