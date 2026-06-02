import os
import subprocess
import sys
import shutil

BUILD_DIR_X86 = "build32"
BUILD_DIR_X64 = "build64"
EXE_NAME = "frame_merger.exe" if os.name == "nt" else "frame_merger"

MINGW32_GCC = r"C:\msys64\mingw32\bin\i686-w64-mingw32-gcc.exe"
MINGW64_GCC = r"C:\msys64\mingw64\bin\gcc.exe"


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
    cc = MINGW32_GCC

elif arch == "2":
    build_dir = BUILD_DIR_X64
    target = "x64"
    cc = MINGW64_GCC

else:
    sys.exit("Invalid arch")


# 🧹 IMPORTANT: clean old cache (prevents Ninja/Make + arch mix bugs)
if os.path.exists(build_dir):
    shutil.rmtree(build_dir)

print("\n[CONFIGURING]")
run([
    "cmake",
    "-S", ".",
    "-B", build_dir,
    f"-DTARGET_ARCH={target}",
    f"-DCMAKE_C_COMPILER={cc}",
    "-G", "Ninja"
])

print("\n[BUILDING]")
run(["cmake", "--build", build_dir])

exe = os.path.join(build_dir, EXE_NAME)

print("\n[RUNNING]")
run([exe])