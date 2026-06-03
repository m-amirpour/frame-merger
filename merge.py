import os
import subprocess
import sys
import shutil
import platform

BUILD_DIR_X86 = "build32"
BUILD_DIR_X64 = "build64"
EXE_NAME = "frame_merger.exe" if os.name == "nt" else "frame_merger"

# Detect OS
IS_WINDOWS = platform.system() == "Windows"

if IS_WINDOWS:
    MINGW32_GCC = r"C:\msys64\mingw32\bin\i686-w64-mingw32-gcc.exe"
    MINGW64_GCC = r"C:\msys64\mingw64\bin\gcc.exe"
    NASM = r"C:\msys64\usr\bin\nasm.exe"  # optional
else:  # Linux / macOS
    # Use system GCC (multilib required for 32‑bit)
    MINGW32_GCC = None
    MINGW64_GCC = "gcc"

def run(cmd):
    print("\n>", " ".join(cmd))
    subprocess.run(cmd, check=True)

print("Select architecture:")
print("1) 32-bit")
print("2) 64-bit")
arch = input("> ").strip()

if arch == "1":
    build_dir = BUILD_DIR_X86
    target = "x86"
    cc = MINGW32_GCC if IS_WINDOWS else "gcc"
elif arch == "2":
    build_dir = BUILD_DIR_X64
    target = "x64"
    cc = MINGW64_GCC if IS_WINDOWS else "gcc"
else:
    sys.exit("Invalid arch")

# Clean old CMake cache
if os.path.exists(build_dir):
    shutil.rmtree(build_dir)

print("\n[CONFIGURING]")
cmake_cmd = [
    "cmake", "-S", ".", "-B", build_dir,
    f"-DTARGET_ARCH={target}",
    "-G", "Ninja"
]
if IS_WINDOWS:
    cmake_cmd.append(f"-DCMAKE_C_COMPILER={cc}")
    if os.path.exists(NASM):
        cmake_cmd.append(f"-DCMAKE_ASM_NASM_COMPILER={NASM}")
else:
    # On Linux, let CMake find the compiler automatically
    # The CMakeLists.txt already adds -m32 when needed
    pass

run(cmake_cmd)

print("\n[BUILDING]")
run(["cmake", "--build", build_dir])

exe_path = os.path.join(build_dir, EXE_NAME)
if not os.path.exists(exe_path):
    sys.exit("Build succeeded but executable not found")

print("\n[RUNNING]")
run([exe_path])
