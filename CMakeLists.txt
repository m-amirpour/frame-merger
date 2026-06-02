cmake_minimum_required(VERSION 3.10)

project(frame_merger C ASM_NASM)

enable_language(ASM_NASM)

# =========================================================
# ARCHITECTURE OPTION
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
    message(FATAL_ERROR "macOS not currently supported")
else()
    message(FATAL_ERROR "Unsupported OS")
endif()

# =========================================================
# ARCH DETECTION
# =========================================================
if(TARGET_ARCH STREQUAL "x86")
    set(ARCH_BITS 32)
elseif(TARGET_ARCH STREQUAL "x64")
    set(ARCH_BITS 64)
else()
    message(FATAL_ERROR "TARGET_ARCH must be x86 or x64")
endif()

# =========================================================
# NASM OUTPUT FORMAT
# =========================================================
if(WIN32)

    if(ARCH_BITS EQUAL 32)
        set(NASM_FORMAT win32)
    else()
        set(NASM_FORMAT win64)
    endif()

elseif(UNIX)

    if(ARCH_BITS EQUAL 32)
        set(NASM_FORMAT elf32)
    else()
        set(NASM_FORMAT elf64)
    endif()

endif()

# =========================================================
# C SETTINGS
# =========================================================
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

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
add_executable(frame_merger
    ${C_SOURCES}
    ${ASM_SOURCES}
)

# =========================================================
# NASM FLAGS
# =========================================================
set_source_files_properties(
    ${ASM_SOURCES}
    PROPERTIES
    LANGUAGE ASM_NASM
)

target_compile_options(frame_merger PRIVATE
    $<$<COMPILE_LANGUAGE:C>:-Wall -Wextra -O3>
)

target_compile_options(frame_merger PRIVATE
    $<$<COMPILE_LANGUAGE:ASM_NASM>:-f ${NASM_FORMAT}>
)

# =========================================================
# LINUX LIBRARIES
# =========================================================
if(UNIX AND NOT APPLE)
    target_link_libraries(frame_merger PRIVATE m pthread)
endif()