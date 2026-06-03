cmake_minimum_required(VERSION 3.16)

project(frame_merger C ASM_NASM)

enable_language(ASM_NASM)

# =========================
# ARCH
# =========================
set(TARGET_ARCH "x64" CACHE STRING "x86 or x64")
set_property(CACHE TARGET_ARCH PROPERTY STRINGS x86 x64)

if(TARGET_ARCH STREQUAL "x86")
    set(ARCH_BITS 32)
elseif(TARGET_ARCH STREQUAL "x64")
    set(ARCH_BITS 64)
else()
    message(FATAL_ERROR "Invalid arch")
endif()

# =========================
# OS + NASM FORMAT
# =========================
if(WIN32)
    set(OS_TAG win)

    if(ARCH_BITS EQUAL 32)
        set(ASM_FORMAT win32)
    else()
        set(ASM_FORMAT win64)
    endif()

elseif(UNIX AND NOT APPLE)
    set(OS_TAG linux)

    if(ARCH_BITS EQUAL 32)
        set(ASM_FORMAT elf32)
    else()
        set(ASM_FORMAT elf64)
    endif()

else()
    message(FATAL_ERROR "Unsupported OS")
endif()

# =========================
# FORCE NASM COMMAND (IMPORTANT FIX)
# =========================
set(CMAKE_ASM_NASM_COMPILE_OBJECT
    "<CMAKE_ASM_NASM_COMPILER> -f ${ASM_FORMAT} <SOURCE> -o <OBJECT>"
)

# remove any default flags that may interfere
set(CMAKE_ASM_NASM_FLAGS "")

# =========================
# C SETTINGS
# =========================
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

if(UNIX AND ARCH_BITS EQUAL 32)
    add_compile_options(-m32)
    add_link_options(-m32)
endif()

# =========================
# SOURCES
# =========================
set(C_SOURCES
    src/main.c
    src/merge.c
    src/merge_opt.c
)

set(ASM_SOURCES
    ${CMAKE_SOURCE_DIR}/asm/${OS_TAG}${ARCH_BITS}/merge_asm_${OS_TAG}${ARCH_BITS}.asm
    ${CMAKE_SOURCE_DIR}/asm/${OS_TAG}${ARCH_BITS}/merge_simd_${OS_TAG}${ARCH_BITS}.asm
)

add_executable(frame_merger
    ${C_SOURCES}
    ${ASM_SOURCES}
)

set_source_files_properties(${ASM_SOURCES}
    PROPERTIES LANGUAGE ASM_NASM
)

# =========================
# OPTIMIZATION FLAGS
# =========================
target_compile_options(frame_merger PRIVATE
    $<$<COMPILE_LANGUAGE:C>:-O3>
    $<$<COMPILE_LANGUAGE:C>:-Wall>
    $<$<COMPILE_LANGUAGE:C>:-Wextra>
)

# =========================
# LIBS
# =========================
if(UNIX AND NOT APPLE)
    target_link_libraries(frame_merger PRIVATE m pthread)
endif()