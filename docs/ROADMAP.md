# OFFICIAL PROJECT ROADMAP: [CODENAME_TBD]
**Target Architecture:** x86_64 (Intel/AMD) | **Type:** General Purpose / Hybrid-Monolithic  
**Scheduling:** Preemptive SMP | **Userland:** Custom + POSIX compatibility | **License:** MIT

---

## Phase 0: Foundation & Toolchain (Environment Zero)
*Goal: Prepare an environment in which code can actually be compiled and executed.*

### 0.1. Cross-Compiler Toolchain
- [x] Build Binutils (target: `x86_64-elf` or custom target).
- [x] Build GCC/Clang (target: `x86_64-elf`, flags `-mno-red-zone`, `-ffreestanding`).
- [ ] Configure GDB for kernel debugging.
- [x] Prepare build scripts (Makefile or CMake) supporting ASM (`nasm`) and C/C++ compilation.

### 0.2. Testing Infrastructure
- [ ] QEMU run scripts with debugging flags (`-s -S`, `-d int`, `-monitor stdio`).
- [ ] Configure VirtualBox/Bochs as verification platforms.
- [ ] Integrate clang-format and cppcheck (static code analysis).

---

## Phase I: Bootloader & Architecture (The Boot Process)
*Goal: Take control of the CPU and transition from 16-bit Real Mode to 64-bit Long Mode.*

### 1.1. Stage 1 Bootloader (MBR - 512 bytes)
- [ ] Assembly code (16-bit).
- [ ] Set segments (`ds`, `es`, `ss` to 0).
- [ ] Set up the stack (Stack Pointer).
- [ ] Load Stage 2 from disk (BIOS INT 13h / Extended Read).
- [ ] Parse the partition table (optional).

### 1.2. Stage 2 Bootloader (Setup Environment)
- [ ] **A20 Line:** Check and enable the A20 line (Fast A20 / Keyboard Controller / BIOS INT 15h).
- [ ] **Memory Map:** Retrieve the physical memory map (E820 map) and store it in a safe location.
- [ ] **GDT (32-bit):** Load a temporary Global Descriptor Table for Protected Mode.
- [ ] **Switch to Protected Mode:** Set the PE bit in CR0, `jmp far` to a 32-bit code segment.

### 1.3. Switch to Long Mode (64-bit)
- [ ] **Paging Setup (Identity Mapping):**
  - [ ] Create PML4, PDPT, PD, PT.
  - [ ] Map the first few MB of physical memory 1:1 (Identity Map).
  - [ ] Enable PAE (Physical Address Extension) in CR4.
- [ ] **EFER MSR:** Set the LME (Long Mode Enable) bit in the IA32_EFER register.
- [ ] **Enable Paging:** Set the PG bit in CR0.
- [ ] **GDT (64-bit):** Load a GDT with Long Mode flags (Code Segment: L=1, D=0).
- [ ] **Far Jump:** Jump to the 64-bit kernel entry code (so-called “Trampoline”).

---

## Phase II: Kernel Core (Initialization)
*Goal: Create a runtime environment for C++ and basic communication.*

### 2.1. Kernel Entry & Runtime
- [ ] Kernel entry point in Assembly (set data segments to 0, set up virtual stack).
- [ ] Call `kmain()` (C++).
- [ ] **C++ Features:**
  - [ ] Support for `.ctors` section (calling global object constructors).
  - [ ] Stubs for `__cxa_pure_virtual` and `__stack_chk_fail`.
  - [ ] (Decision) Disable Exceptions and RTTI (`-fno-exceptions -fno-rtti`).

### 2.2. Basic Output (Debugging)
- [ ] **VGA Text Mode Driver:** Direct writing to `0xB8000`. Color handling, scrolling, screen clearing.
- [ ] **Serial Port Driver (COM1):** UART initialization. Critical for debug logging (dumping logs to host console).
- [ ] Implement `kprintf` (string formatting, hex, int).

---

## Phase III: Memory Management
*Goal: Full control over RAM. Without this, the system will crash on the first allocation.*

### 3.1. Physical Memory Manager (PMM)
- [ ] Parse the E820 map provided by the bootloader.
- [ ] **Bitmap Allocator:** Implement a bitmap where 1 bit = 4KB (page).
- [ ] Functions: `pmm_alloc_block()`, `pmm_free_block()`.
- [ ] Handle memory reserved by the kernel and bootloader.

### 3.2. Virtual Memory Manager (VMM)
- [ ] Page table abstraction (PML4 -> PT).
- [ ] Functions: `vmm_map_page(phys, virt, flags)`, `vmm_unmap_page(virt)`.
- [ ] **Higher Half Kernel:** Remap the kernel to higher addresses (e.g. `0xFFFF8000...`), unmap the lower half (security).
- [ ] Page Fault (`#PF`) handling – handler displaying the fault address (CR2).

### 3.3. Heap Allocator (Kernel Heap)
- [ ] Initial implementation: Simple singly linked list.
- [ ] Functions: `kmalloc(size)`, `kfree(ptr)`, `krealloc`.
- [ ] Implement `new` and `delete` operators (global override).

---

## Phase IV: Interrupts & Hardware (Hardware Abstraction Layer)
*Goal: Respond to external events.*

### 4.1. Descriptor Tables Reloaded
- [ ] **IDT (Interrupt Descriptor Table):** Full table of 256 entries.
- [ ] **ISR (Interrupt Service Routines):** Assembly stubs for CPU exceptions (0–31), e.g. Divide by Zero, GPF, Page Fault.
- [ ] Stack trace dumping in case of Kernel Panic.

### 4.2. PIC & APIC
- [ ] Remap Legacy PIC (Programmable Interrupt Controller) – shift IRQs to vectors 32+.
- [ ] (Target) Disable PIC and switch to **APIC (Advanced PIC)** – required for multicore.
- [ ] Calibrate Local APIC Timer (using PIT or ACPI PM Timer for measurement).

### 4.3. Basic Input
- [ ] **PS/2 Keyboard Driver:** IRQ 1 handling. Map scancodes to ASCII characters. Circular input buffer.

---

## Phase V: Scheduling & Multitasking (The Heart)
*Goal: Run multiple threads simultaneously with preemption.*

### 5.1. Process Structures
- [ ] Define `PCB` (Process Control Block) / `TaskStruct`.
- [ ] Store CPU context (all GPR registers, RFLAGS, RIP, CR3).
- [ ] Allocate a Kernel Stack for each thread.

### 5.2. Context Switching (Assembly)
- [ ] Function `switch_task(next_task_struct)`.
- [ ] Save registers on the current thread’s stack.
- [ ] Swap RSP to the new thread’s RSP.
- [ ] Restore registers (POP).
- [ ] `iretq` or `ret`.

### 5.3. Scheduler (Preemptive)
- [ ] Hook into **Timer Interrupt** (PIT or APIC Timer).
- [ ] Algorithm: Round Robin (cyclic queue).
- [ ] Process states: `READY`, `RUNNING`, `BLOCKED`, `TERMINATED`.
- [ ] `yield()` function (voluntary time relinquish).

### 5.4. Synchronization (Concurrency)
- [ ] **Spinlocks:** Atomic locks (`lock bts` or `xchg`) to protect kernel structures.
- [ ] **Semaphores / Mutexes:** Put waiting threads to sleep (no busy waiting!).
- [ ] Disable interrupts (`cli`/`sti`) in scheduler critical sections.

### 5.5. SMP (Symmetric Multiprocessing)
- [ ] Parse ACPI tables (MADT) to detect cores.
- [ ] **Trampoline Code:** 16-bit startup code for AP (Application Processors).
- [ ] Initialize each core (GDT, IDT, Paging per-core).
- [ ] Per-CPU variables (GS register base).

---

## Phase VI: File Systems & VFS (Storage)
*Goal: Persistent data storage.*

### 6.1. Disk Drivers
- [ ] **ATA/PIO Driver:** Basic IDE disk support (slow but simple).
- [ ] (Later) **AHCI/SATA Driver:** DMA support and modern controllers.

### 6.2. Virtual File System (VFS)
- [ ] Structures: `vnode`, `file`, `mountpoint`, `stat`.
- [ ] Operations: `open`, `read`, `write`, `close`, `mkdir`, `readdir`.
- [ ] DevFS (`/dev`) support – devices as files.

### 6.3. Custom Filesystem & Format
- [ ] Design CustomFS specification (Superblock, Inode Table, Data Blocks).
- [ ] Implement CustomFS driver.
- [ ] Format virtual disk with CustomFS.

---

## Phase VII: Userland & System Calls (Separation)
*Goal: Secure application execution.*

### 7.1. Ring 3 Entry
- [ ] Configure GDT for User Code and User Data segments (Ring 3).
- [ ] Code to drop a process from Ring 0 to Ring 3 (`iretq` with prepared stack).
- [ ] TSS (Task State Segment): Set RSP0 (return to kernel on interrupt).

### 7.2. System Calls (Syscalls)
- [ ] Configure `syscall` / `sysret` instructions (MSRs `LSTAR`, `STAR`, `SFMASK`).
- [ ] Syscall dispatcher (large switch/table in the kernel).
- [ ] Implement basic syscalls: `sys_write` (console), `sys_exit`, `sys_yield`.

### 7.3. Custom Executable Format
- [ ] Executable file header specification.
- [ ] Kernel loader: load file into memory, map sections, jump to Entry Point.

### 7.4. Standard Library (Userland)
- [ ] `start.asm`: Application startup code (crt0), calling `main`.
- [ ] Implement syscall wrappers.
- [ ] Basic C functions: `stdio.h`, `stdlib.h`, `string.h`.

---

## Phase VIII: Graphical Interface (GUI)
*Goal: Move away from the text console.*

### 8.1. Framebuffer
- [ ] Switch video mode in the bootloader (or via BGA – Bochs Graphics Adapter).
- [ ] Map LFB (Linear Frame Buffer) memory into the VMM.
- [ ] Primitive functions: `put_pixel`, `draw_rect`, `draw_line`.

### 8.2. Windowing System (Compositor in Kernel)
- [ ] `Window` structure.
- [ ] Z-Order (window stacking order).
- [ ] “Dirty Rectangles” algorithm (redraw only changes).
- [ ] Double Buffering (prevent flickering).

### 8.3. Input Integration
- [ ] Mouse driver (PS/2 Mouse).
- [ ] Hardware or software cursor rendering.
- [ ] Event Loop: Dispatch events (clicks, keys) to the active window.

---

## Phase IX: Networking
*Goal: Communicate with the outside world.*

### 9.1. PCI Subsystem
- [ ] Scan PCI/PCIe bus.
- [ ] Detect devices and load appropriate drivers.

### 9.2. NIC Driver
- [ ] Driver for popular cards (e.g. Intel E1000 or Realtek 8139).
- [ ] DMA handling for network packets (Ring Buffers).
- [ ] Network card interrupt handling.

### 9.3. TCP/IP Stack
- [ ] Ethernet layer (MAC).
- [ ] ARP (Address Resolution Protocol).
- [ ] IPv4 protocol.
- [ ] ICMP protocol (Ping).
- [ ] UDP and TCP protocols (state machine).
- [ ] Socket Interface (userland API).

---

## Phase X: Self-Hosting & Final Polish
*Goal: The system builds itself.*

### 10.1. Toolchain Port
- [ ] Port a compiler (e.g. TCC – Tiny C Compiler or GCC) to the custom OS.
- [ ] Port Make and Binutils.

### 10.2. Shell & Utilities
- [ ] Write a shell with script support.
- [ ] System utilities: `ls`, `cat`, `ps`, `top`, `netstat`.

---

## Appendix: Architectural Decisions (ADR Summary)

| ID | Topic | Decision | Rationale |
| :--- | :--- | :--- | :--- |
| **ADR-01** | Bootloader | Custom (ASM) | Full control, educational goal, learning the Real→Long Mode transition. |
| **ADR-02** | Kernel Language | C++ (Freestanding) | C performance + object abstraction for managing complexity (VMM, drivers). |
| **ADR-03** | Scheduling | Preemptive | Required for desktop system stability (preempt hung processes). |
| **ADR-04** | Graphics | In-Kernel Windowing | Higher performance, simpler initial architecture than X11/Wayland server. |
| **ADR-05** | API | Custom + POSIX Layer | Innovation in custom API with the ability to port software via a POSIX shim. |