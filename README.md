# ViridisOS

## Overview

**ViridisOS** is a high-performance, general-purpose operating system built from scratch for the **x86_64** architecture.

The project is both **educational and engineering-driven**: while its development serves as a deep learning exercise in operating system internals, all design decisions, code quality, tooling, and documentation follow **commercial / industrial-grade standards**.

ViridisOS is developed with a *critical infrastructure mindset*: determinism, explicitness, and long-term maintainability take precedence over convenience.

---

## Project Status

* **Current Version:** `0.1.0-alpha`
* **Development Phase:** Phase 0 – Foundation & Toolchain
* **Stability:** Pre-Alpha (tooling stable, kernel not started)

### Completed Milestones

* ✅ Phase 0.1 – Cross-Compiler Toolchain

### Upcoming Milestones

* ⏳ Phase 0.2 – Testing Infrastructure (QEMU, GDB)
* ⏳ Phase I – Bootloader & Architecture

For a detailed long-term plan, see [`ROADMAP.md`](docs/ROADMAP.md).

---

## Core Design Principles

ViridisOS is developed according to the following principles:

* **Zero-Magic Rule** – no undocumented constants, implicit behavior, or hidden dependencies
* **Freestanding First** – no reliance on host OS facilities
* **Deterministic Builds** – reproducible results across systems
* **Explicit Architecture** – clarity over cleverness
* **Future-Proof Design** – architecture decisions documented and justified

These principles are formally defined in [`STANDARDS.md`](docs/STANDARDS.md).

---

## Toolchain (Phase 0.1)

A fully custom **cross-compilation toolchain** has been implemented as the foundation of the project.

### Target

* **Architecture:** x86_64 (Intel / AMD)
* **Target Triple:** `x86_64-elf`
* **Execution Model:** Bare metal (freestanding)

### Components

* GNU Binutils (`x86_64-elf-*`)
* GCC (C and C++)
* Minimal `libgcc` runtime
* No libc / libstdc++ / host headers

### Build Environment

The toolchain is built inside a **Docker-based hermetic environment** to ensure:

* Host independence
* Reproducibility
* Clean separation between tools and source code

Docker provides the build environment, while the project source tree is mounted into the container at runtime.

---

## Building the Toolchain

### Requirements (Host)

* Docker (modern version)

### Build Steps

From the project root directory:

```bash
docker build -t viridis-toolchain tools/docker

docker run -it \
  -v "$(pwd)":/root/os-project \
  viridis-toolchain \
  bash
```

Inside the container:

```bash
cd /root/os-project
tools/toolchain/build_binutils.sh
tools/toolchain/build_gcc.sh
```

### Verification

After a successful build, the following commands must work:

```bash
x86_64-elf-gcc --version
x86_64-elf-ld --version
```

A freestanding C/C++ file must compile without errors.

---

## Documentation

* 📘 **Toolchain Architecture:** [`docs/toolchain.md`](docs/toolchain.md)
* 📜 **Project Standards & Constitution:** [`docs/STANDARDS.md`](docs/STANDARDS.md)
* 🗺 **Long-Term Plan:** [`docs/ROADMAP.md`](docs/ROADMAP.md)

All technical documentation is written in English by design.

---

## Directory Structure (Planned)

```
/
├── build/                  # Build artifacts (gitignored)
├── docs/                   # Documentation
├── src/                    # Source code (bootloader, kernel, drivers)
├── tools/                  # Tooling (toolchain, scripts, Docker)
├── Makefile                # Main build entry point
└── README.md
```

---

## Versioning

ViridisOS follows a SemVer-inspired scheme adapted for operating system development:

* `MAJOR.MINOR.PATCH`

* Current phase: `0.x.x` (Pre-Alpha)

* **Major:** Architectural milestone (e.g. working userland)

* **Minor:** New subsystem or feature

* **Patch:** Bug fixes or refactors

Pre-release identifiers may be used: `-alpha.x`, `-beta.x`, `-rc.x`.

---

## License

ViridisOS is released under the **MIT License**.

---

## Disclaimer

This project is under active development.

Interfaces, internal APIs, and low-level details may change significantly before the first stable release.

---

*ViridisOS – engineered, not hacked.*
