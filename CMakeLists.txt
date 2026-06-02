cmake_minimum_required(VERSION 3.10)

project(frame_merger C ASM_NASM)

enable_language(ASM_NASM)

# =========================================================
# ARCHITECTURE OPTION (string-based, FIXED)
# =========================================================
set(TARGET_ARCH "x64" CACHE STRING "Target architecture (x86 or x64)")
set_property(CACHE TARGET_ARCH PROPERTY STRINGS x86 x64)

# =========================================================
# OS DETECTION
# =========================================================
if(WIN32)
    set(OS_TAG win)
elseif(UNIX AND NOT APPLE)
    set(OS_TAG linux)
elseif(APPLE)
    set(OS_TAG mac)
else()
    message(FATAL_ERROR "Unsupported OS")
endif()

# =========================================================
# ARCHITECTURE CONFIG
# =========================================================
if(TARGET_ARCH STREQUAL "x86")
    set(ARCH_BITS 32)
    set(NASM_FORMAT win32)
elseif(TARGET_ARCH STREQUAL "x64")
    set(ARCH_BITS 64)
    set(NASM_FORMAT win64)
else()
    message(FATAL_ERROR "TARGET_ARCH must be x86 or x64")
endif()

# =========================================================
# EXECUTABLE NAME (keep single binary)
# =========================================================
set(EXE_NAME frame_merger)

# =========================================================
# COMPILER FLAGS
# =========================================================
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

if(MSVC)
    # MSVC doesn't use -m32/-m64
    # architecture handled by generator
else()
    if(ARCH_BITS EQUAL 32)
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m32")
    else()
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -m64")
    endif()
endif()

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra")

# =========================================================
# NASM RULE (FIXED)
# =========================================================
set(CMAKE_ASM_NASM_COMPILE_OBJECT
    "<CMAKE_ASM_NASM_COMPILER> -f ${NASM_FORMAT} -o <OBJECT> <SOURCE>"
)

# =========================================================
# SOURCES
# =========================================================
set(C_SOURCES
    src/main.c
    src/merge.c
    src/merge_opt.c
)

set(ASM_SOURCES
    ${CMAKE_SOURCE_DIR}/asm/${OS_TAG}${ARCH_BITS}/merge_asm_${OS_TAG}${ARCH_BITS}.asm
    ${CMAKE_SOURCE_DIR}/asm/${OS_TAG}${ARCH_BITS}/merge_simd_${OS_TAG}${ARCH_BITS}.asm
)

# =========================================================
# EXECUTABLE
# =========================================================
add_executable(${EXE_NAME}
    ${C_SOURCES}
    ${ASM_SOURCES}
)

# =========================================================
# OPTIONAL: enforce warnings + optimizations
# =========================================================
if(NOT MSVC)
    target_compile_options(${EXE_NAME} PRIVATE -O3)
endif()