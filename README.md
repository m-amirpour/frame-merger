# Frame Merger

A cross-platform video frame merger written in C and x86 Assembly.

The program reads two videos frame-by-frame, merges their RGB pixels using saturating addition, and generates a new output video.

Supported implementations:

* Pure C
* x86 Assembly
* SIMD/MMX Assembly
* Benchmark mode

Supported platforms:

* Windows (x86 / x64)
* Linux (x86 / x64)

---

# Requirements

## Build

* CMake 3.16+
* Ninja
* NASM
* GCC / MinGW GCC

## Runtime

* FFmpeg
* FFprobe

Make sure both `ffmpeg` and `ffprobe` are available in your system PATH.

---

# Project Structure

```text
.
├── asm
│   ├── linux32
│   │   ├── merge_asm_linux32.asm
│   │   └── merge_simd_linux32.asm
│   ├── linux64
│   │   ├── merge_asm_linux64.asm
│   │   └── merge_simd_linux64.asm
│   ├── win32
│   │   ├── merge_asm_win32.asm
│   │   └── merge_simd_win32.asm
│   └── win64
│       ├── merge_asm_win64.asm
│       └── merge_simd_win64.asm
│
├── src
│   ├── main.c
│   ├── merge.c
│   └── merge_opt.c
│
├── vids
│   ├── vid1-raw.mov
│   ├── vid2-raw.mov
│   ├── vid1_ready.mov
│   └── vid2_ready.mov
│
├── output
│   └── output.mp4
│
├── prepare_videos.ps1
├── prepare_videos.sh
├── cli.py
├── CMakeLists.txt
├── CMakePresets.json
└── README.md
```

---

# Preparing Input Videos

This repository does NOT include any videos.

You must provide your own `.mov` files.

Place two videos inside the `vids` directory and rename them exactly as:

```text
vids/
├── vid1-raw.mov
└── vid2-raw.mov
```

Example:

```text
vids/
├── vid1-raw.mov    ← your first video
└── vid2-raw.mov    ← your second video
```

---

# Preparing Videos

The two videos must have the same:

* Resolution
* Frame rate
* Duration

Use one of the provided helper scripts to prepare them automatically.

## Windows

```powershell
.\prepare_videos.ps1
```

## Linux

```bash
chmod +x prepare_videos.sh
./prepare_videos.sh
```

The scripts will generate:

```text
vids/
├── vid1_ready.mov
└── vid2_ready.mov
```

These files are used by the merger application.

---

# Python CLI Helper

A Python command-line helper is also included.

It can automate common tasks such as:

* Preparing videos
* Configuring builds
* Building the project
* Running the executable

Usage:

```bash
python cli.py
```

or

```bash
python3 cli.py
```

Follow the on-screen menu.

---

# Building

## Windows x64

```powershell
cmake --preset win64
cmake --build build-win64
```

## Windows x86

```powershell
cmake --preset win32
cmake --build build-win32
```

## Linux x64

```bash
cmake --preset linux64
cmake --build build-linux64
```

## Linux x86

```bash
cmake --preset linux32
cmake --build build-linux32
```

---

# Running

## Windows x64

```powershell
.\build-win64\frame_merger.exe
```

## Windows x86

```powershell
.\build-win32\frame_merger.exe
```

## Linux x64

```bash
./build-linux64/frame_merger
```

## Linux x86

```bash
./build-linux32/frame_merger
```

---

# Modes

When the program starts:

```text
1) C
2) ASM
3) SIMD
4) BENCH
>
```

## C

Runs the reference C implementation.

## ASM

Runs the Assembly implementation.

## SIMD

Runs the SIMD/MMX implementation.

## BENCH

Runs all implementations and reports timing information.

---

# Output

The generated video is written to:

```text
output/output.mp4
```

The output directory is created automatically if it does not already exist.

---

# Notes

* Input videos must be `.mov` files.
* Raw videos must be named `vid1-raw.mov` and `vid2-raw.mov`.
* Prepared videos are generated automatically by the helper scripts.
* FFmpeg and FFprobe must be installed and accessible from PATH.
* The project supports Windows and Linux on both x86 and x64 architectures.
* SIMD implementations use aligned memory allocations for optimal performance.
