# ViridisOS Toolchain Documentation

## Document Metadata

* **Project:** ViridisOS
* **Component:** Cross-Compiler Toolchain
* **Phase:** 0.1 – Foundation & Toolchain
* **Version:** 0.1.0-alpha
* **Status:** Approved (Post-Verification)

---

## 1. Purpose and Scope

This document describes the design, architecture, build process, and usage of the **ViridisOS cross-compilation toolchain**.

The toolchain is a **critical infrastructure component**. Its purpose is to provide a **hermetic, deterministic, and host-independent** environment for building the ViridisOS kernel and all low-level components.

Out of scope:

* Kernel source code
* Bootloader implementation
* Emulator configuration (covered in Phase 0.2)

---

## 2. Design Goals

The toolchain was designed according to the following non-negotiable principles:

1. **Host Independence**
   The resulting binaries must not depend on the host operating system, libc, or compiler.

2. **Freestanding Compliance**
   All compiled code must support `-ffreestanding` semantics.

3. **Deterministic Builds**
   Given the same inputs, the toolchain must always produce the same outputs.

4. **Minimal Trusted Computing Base (TCB)**
   Only strictly required components are included.

5. **Future-Proofing**
   The architecture must support future kernel growth without reworking the toolchain.

---

## 3. Target Architecture

* **CPU Architecture:** x86_64 (Intel / AMD)
* **Target Triple:** `x86_64-elf`
* **Execution Model:** Bare-metal (no host OS assumptions)

### Rationale

The `x86_64-elf` target is an industry-standard choice for operating system development:

* No implicit libc dependency
* Clean separation from host toolchains
* Supported by Binutils, GCC, GDB, QEMU, and Bochs

---

## 4. Toolchain Components

### 4.1 Binutils

Provides:

* Assembler (`x86_64-elf-as`)
* Linker (`x86_64-elf-ld`)
* Binary inspection tools (`objdump`, `nm`, `readelf`)

**Key configuration flags:**

* `--target=x86_64-elf`
* `--with-sysroot`
* `--disable-nls`
* `--disable-werror`

---

### 4.2 GCC

Provides:

* `x86_64-elf-gcc` (C compiler)
* `x86_64-elf-g++` (C++ compiler)
* `libgcc` (minimal runtime support)

**Explicitly excluded:**

* libstdc++
* host headers
* threads
* shared libraries

**Enabled languages:**

* C
* C++

---

## 5. Compilation Model

All kernel and low-level code compiled using this toolchain **must** follow these rules:

* Freestanding environment
* No exceptions
* No RTTI
* No red zone
* No thread-safe statics

### Mandatory Compiler Flags

```
-ffreestanding
-mno-red-zone
-fno-exceptions
-fno-rtti
-fno-threadsafe-statics
```

These flags are enforced at the project level.

---

## 6. Docker-Based Build Environment

### 6.1 Purpose of Docker

Docker is used to:

* Isolate the build environment
* Eliminate host-specific variations
* Guarantee reproducibility

Docker **does not** store project source code permanently.

---

### 6.2 Container Responsibilities

The Docker image provides:

* System dependencies
* Build tools
* A controlled Linux environment

Project source code is mounted into the container at runtime using a volume.

---

### 6.3 Running the Toolchain Build

From the project root on the host system:

```
docker build -t viridis-toolchain tools/docker

docker run -it \
  -v "$(pwd)":/root/os-project \
  viridis-toolchain \
  bash
```

Inside the container:

```
cd /root/os-project
tools/toolchain/build_binutils.sh
tools/toolchain/build_gcc.sh
```

---

## 7. Directory Layout

```
tools/
├── docker/
│   └── Dockerfile
└── toolchain/
    ├── build_binutils.sh
    ├── build_gcc.sh
    └── env.sh
```

---

## 8. Verification Checklist (Definition of Done)

The toolchain is considered **valid and production-ready** only if all conditions below are met:

* `x86_64-elf-gcc --version` executes successfully
* `x86_64-elf-ld --version` executes successfully
* A freestanding C/C++ file compiles without errors
* No host headers or libraries are used
* Build completes without warnings or failures

---

## 9. Known Limitations

* No C standard library
* No C++ standard library
* No floating-point or SIMD assumptions
* No kernel debugging setup (covered in Phase 0.2)

---

## 10. Architectural Notes

This toolchain is intentionally minimal.

Any future changes (new architectures, new languages, or runtime features) **must** be documented as an Architectural Decision Record (ADR).

---

## 11. Status

* **Phase:** 0.1 – Completed
* **Stability:** Stable
* **Next Phase:** 0.2 – Testing Infrastructure (QEMU, GDB)

---

*End of document.*
