# PROJECT CONSTITUTION & ENGINEERING STANDARDS

**Version:** 1.0.0 | **Status:** Active | **Enforcement:** Strict

---

## 1. PROJECT VISION & PHILOSOPHY

This project is a high-performance, general-purpose Operating System built from scratch. While it serves an educational purpose, the code quality, architecture, and documentation must meet **commercial/industrial standards**.

### 1.1. The "Zero-Magic" Rule

- **No Magic Numbers:** Every constant (address, size, bitmask) must be defined as a `constexpr` or `#define` with a descriptive name.
- **No Magic Blobs:** We do not use pre-compiled binaries (except strict firmware requirements). Every byte of the kernel is compiled from our source.
- **Explicit over Implicit:** Code readability and explicitness take precedence over clever one-liners.

### 1.2. The Criticality Mindset

- **Kernel Panic is a Failure:** The kernel should be robust enough to recover from driver errors. A panic is only allowed if hardware integrity is compromised.
- **Memory Discipline:** \* Every allocation (`kmalloc`/`new`) implies a responsibility to free.
  - Memory leaks in the kernel are considered **Blocker Bugs**.
- **Concurrency Awareness:** Every global variable is assumed to be accessed by multiple cores (SMP) simultaneously. Proper locking (Spinlocks/Mutexes) is mandatory from Day 1.

---

## 2. TECHNOLOGY STACK & CONSTRAINTS

### 2.1. Allowed Languages & Standards

| Layer           | Language    | Standard      | Compiler Flags (Critical)                                                        |
| :-------------- | :---------- | :------------ | :------------------------------------------------------------------------------- |
| **Bootloader**  | Assembly    | NASM          | `[BITS 16]`, `[BITS 32]`, `[BITS 64]`                                            |
| **Kernel Core** | C++         | C++20 / C++23 | `-ffreestanding -mno-red-zone -fno-exceptions -fno-rtti -fno-threadsafe-statics` |
| **Low-level**   | C           | C17           | `-ffreestanding -nostdlib`                                                       |
| **Scripts**     | Bash/Python | Latest        | N/A                                                                              |

### 2.2. Forbidden Technologies (Strict)

1.  **Host Standard Library:** Usage of `<iostream>`, `<vector>`, `<string>`, `<thread>`, or standard C headers (`stdio.h`) inside the kernel is **strictly prohibited**. We build our own `kstd` library.
2.  **C++ Runtime Overhead:** \* **NO Exceptions (`try`/`catch`):** Kernel cannot handle stack unwinding complexity initially. Use error codes or `std::expected` pattern.
    - **NO RTTI (`dynamic_cast`, `typeid`):** We do not need runtime type reflection.
3.  **Floating Point (Initially):** Usage of `float`/`double` / SSE / AVX registers in the kernel is forbidden until we implement full FPU Context Switching (saving XMM/YMM registers).

---

## 3. ARCHITECTURE & FUTURE-PROOFING

### 3.1. Hardware Abstraction Layer (HAL)

To support future architectures (ARM64, RISC-V), direct hardware access must be abstracted.

- **Wrong:** Writing to `0xB8000` (VGA) directly in `main.cpp`.
- **Right:** `Graphics::Console::Write()` -> calls `HAL::Video::DrawChar()`.
- **Rule:** Architecture-specific code (ASM inline, specific registers) resides **only** in `src/arch/x86_64/`. The core kernel (`src/kernel/`) must be agnostic.

### 3.2. Modular Design

- **Microkernel-ish Monolith:** The kernel is monolithic (performance), but subsystems (Scheduler, VFS, Net) must be loosely coupled.
- **Driver Interface:** Drivers must follow a defined interface (e.g., `IDevice`, `IBlockDevice`) allowing for dynamic loading/unloading in the future.

---

## 4. DEVELOPMENT WORKFLOW & VERSIONING

### 4.1. Versioning Strategy (OS-SemVer)

Current Phase: **0.x.x (Pre-Alpha)**

- **Major (X.0.0):** Architecture shift or reaching a Milestone (e.g., "Userland works").
- **Minor (0.X.0):** New feature (e.g., "Added FAT32 support").
- **Patch (0.0.X):** Bug fix or minor refactor.

### 4.2. Git Workflow & Branching

- `main`: Always stable, compiles, runs.
- `dev`: Integration branch.
- `feature/name`: Specific features (e.g., `feature/paging`).
- **Pull Requests:** Code review is mandatory before merging to `main`.

### 4.3. Commit Message Convention (Conventional Commits)

Format: `type(scope): subject`

- `feat(vmm)`: Add page table walking
- `fix(scheduler)`: Fix deadlock in task switching
- `docs(readme)`: Update build instructions
- `chore(build)`: Upgrade Docker image
- `refactor(drivers)`: Clean up serial port code

---

## 5. CODING STANDARDS (STYLE GUIDE)

### 5.1. Naming Conventions

- **Files:** `snake_case.cpp` (e.g., `memory_manager.cpp`)
- **Classes/Structs:** `PascalCase` (e.g., `PageDirectory`)
- **Functions/Methods:** `PascalCase` (e.g., `AllocateBlock`)
- **Variables (Local):** `snake_case` (e.g., `current_process`)
- **Variables (Member):** `m_snakeCase` (e.g., `m_bufferSize`)
- **Constants/Macros:** `SCREAMING_SNAKE_CASE` (e.g., `PAGE_SIZE`)
- **Namespaces:** Essential for grouping. Use `Kernel::Memory`, `Kernel::Drivers`.

### 5.2. File Headers

Every source file must begin with:

```cpp
/*
 * [ViridisOS] - Kernel Source
 * Copyright (C) [Year] [Bartosz Widelski]
 * * File: [Filename]
 * Description: [Short description of what this file does]
 */
```

### 5.3. Documentation (Doxygen)

Critical functions must be documented in the header file:

```cpp
/**
 * @brief Allocates a physical memory block.
 * @param size The size in bytes (must be aligned).
 * @return void* Pointer to the block or nullptr if OOM.
 * @note This function acquires the PMM spinlock.
 */
void* Allocate(size_t size);
```

---

## 6. TESTING & QA

### 6.1. Verification Levels

1. **Build Check:** Does it compile without warnings (`-Wall -Wextra -Werror`)?
2. **Boot Check:** Does it boot in QEMU without crashing?
3. **Sanity Check:** Do unit tests (inside kernel) pass? (e.g., alloc/free 1000 times).

### 6.2. Emulators

We officially support and test against:

1. **QEMU (Primary):** For rapid development and debugging.
2. **Bochs:** For strict hardware verification (it catches errors QEMU ignores).
3. **VirtualBox/VMware:** For "real-world" virtualization tests.

---

## 7. DIRECTORY STRUCTURE (MANDATORY)

```text
/
├── build/                  # Artifacts (ignored by git)
├── docs/                   # Documentation (Roadmap, ADRs, Standards)
├── src/
│   ├── arch/               # Architecture specific code
│   │   └── x86_64/         # Intel/AMD 64-bit specific (ASM, IDT, Paging)
│   ├── boot/               # Bootloader code
│   ├── drivers/            # Hardware drivers (VGA, Serial, Keyboard)
│   ├── kernel/             # Core Kernel logic (Scheduler, VMM, IPC)
│   │   ├── mm/             # Memory Management
│   │   └── sched/          # Scheduler
│   ├── lib/                # Internal Kernel Library (kstring, kvector)
│   └── include/            # Global headers
├── tools/                  # Build scripts, Dockerfile, Linker scripts
├── Makefile                # Main build entry
└── README.md
```