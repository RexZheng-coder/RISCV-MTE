//===-- memtag.h ------------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef SCUDO_MEMTAG_H_
#define SCUDO_MEMTAG_H_



#include "internal_defs.h"
#include "memtag_zimte.h"
#include <stdlib.h>
#include <string.h>

#if SCUDO_CAN_USE_MTE
#include <sys/auxv.h>
#include <sys/prctl.h>
#endif

namespace scudo {

// // 在 memtag.h 文件中添加
// #if SCUDO_ZIMTE
// extern "C" {
// // 1. GENTAG: 生成随机标签并插入指针
// void *__builtin_riscv_zimte_gentag(void *ptr); 

// // 2. SETTAG: 将指针中的标签写入到内存块的影子内存中
// void __builtin_riscv_zimte_settag(void *ptr, int chunk_count); 

// // 3. SETINVTAG/CLEAR_PTAG: 标签清除和设置
// void __builtin_riscv_zimte_setinvtag(void *ptr, int chunk_count);
// } // extern "C"
// #endif

#if (__clang_major__ >= 12 && defined(__aarch64__) && !defined(__ILP32__)) ||  \
    defined(SCUDO_FUZZ)

// We assume that Top-Byte Ignore is enabled if the architecture supports memory
// tagging. Not all operating systems enable TBI, so we only claim architectural
// support for memory tagging if the operating system enables TBI.
// HWASan uses the top byte for its own purpose and Scudo should not touch it.
#if SCUDO_CAN_USE_MTE && !defined(SCUDO_DISABLE_TBI) &&                        \
    !__has_feature(hwaddress_sanitizer)
inline constexpr bool archSupportsMemoryTagging() { return true; }
#else
inline constexpr bool archSupportsMemoryTagging() { return false; }
#endif

inline constexpr uptr archMemoryTagGranuleSize() { return 16; }

inline uptr untagPointer(uptr Ptr) { return Ptr & ((1ULL << 56) - 1); }

inline uint8_t extractTag(uptr Ptr) { return (Ptr >> 56) & 0xf; }

// --- 在 memtag.h 文件中，第一个 #if (__clang_major__ >= 12 && defined(__aarch64__)...) 块之后插入 ---

#elif SCUDO_ZIMTE 
// -----------------------------------------------------------
// RISC-V Zimte MTE Implementation
// -----------------------------------------------------------

inline constexpr bool archSupportsMemoryTagging() { return true; }

inline constexpr uptr archMemoryTagGranuleSize() { return 16; } // Zimte 粒度也是 16 字节

inline uptr untagPointer(uptr Ptr) { 
  // 假设标签占用最高 8 位 (与 ARM MTE 类似)，清除 ptag，保留地址
  return Ptr & ((1ULL << 56) - 1); 
}

inline uint8_t extractTag(uptr Ptr) { 
  // 提取最高 4 位标签 (对应 QEMU 的 ptw=4 设置)
  return (Ptr >> 56) & 0xf; 
}

#else

inline constexpr bool archSupportsMemoryTagging() { return false; }

inline NORETURN uptr archMemoryTagGranuleSize() {
  UNREACHABLE("memory tagging not supported");
}

inline NORETURN uptr untagPointer(uptr Ptr) {
  (void)Ptr;
  UNREACHABLE("memory tagging not supported");
}

inline NORETURN uint8_t extractTag(uptr Ptr) {
  (void)Ptr;
  UNREACHABLE("memory tagging not supported");
}

#endif

#if __clang_major__ >= 12 && defined(__aarch64__) && !defined(__ILP32__)

#if SCUDO_CAN_USE_MTE

inline bool systemSupportsMemoryTagging() {
#ifndef HWCAP2_MTE
#define HWCAP2_MTE (1 << 18)
#endif
  return getauxval(AT_HWCAP2) & HWCAP2_MTE;
}

inline bool systemDetectsMemoryTagFaultsTestOnly() {
#ifndef PR_SET_TAGGED_ADDR_CTRL
#define PR_SET_TAGGED_ADDR_CTRL 54
#endif
#ifndef PR_GET_TAGGED_ADDR_CTRL
#define PR_GET_TAGGED_ADDR_CTRL 56
#endif
#ifndef PR_TAGGED_ADDR_ENABLE
#define PR_TAGGED_ADDR_ENABLE (1UL << 0)
#endif
#ifndef PR_MTE_TCF_SHIFT
#define PR_MTE_TCF_SHIFT 1
#endif
#ifndef PR_MTE_TAG_SHIFT
#define PR_MTE_TAG_SHIFT 3
#endif
#ifndef PR_MTE_TCF_NONE
#define PR_MTE_TCF_NONE (0UL << PR_MTE_TCF_SHIFT)
#endif
#ifndef PR_MTE_TCF_SYNC
#define PR_MTE_TCF_SYNC (1UL << PR_MTE_TCF_SHIFT)
#endif
#ifndef PR_MTE_TCF_MASK
#define PR_MTE_TCF_MASK (3UL << PR_MTE_TCF_SHIFT)
#endif
  int res = prctl(PR_GET_TAGGED_ADDR_CTRL, 0, 0, 0, 0);
  if (res == -1)
    return false;
  return (static_cast<unsigned long>(res) & PR_MTE_TCF_MASK) != PR_MTE_TCF_NONE;
}

inline void enableSystemMemoryTaggingTestOnly() {
  prctl(PR_SET_TAGGED_ADDR_CTRL,
        PR_TAGGED_ADDR_ENABLE | PR_MTE_TCF_SYNC | (0xfffe << PR_MTE_TAG_SHIFT),
        0, 0, 0);
}

#else // !SCUDO_CAN_USE_MTE

inline bool systemSupportsMemoryTagging() { return false; }

inline NORETURN bool systemDetectsMemoryTagFaultsTestOnly() {
  UNREACHABLE("memory tagging not supported");
}

inline NORETURN void enableSystemMemoryTaggingTestOnly() {
  UNREACHABLE("memory tagging not supported");
}

#endif // SCUDO_CAN_USE_MTE

class ScopedDisableMemoryTagChecks {
  uptr PrevTCO;
  bool active;

public:
  ScopedDisableMemoryTagChecks(bool cond = true) : active(cond) {
    if (!active)
      return;
    __asm__ __volatile__(
        R"(
        .arch_extension memtag
        mrs %0, tco
        msr tco, #1
        )"
        : "=r"(PrevTCO));
  }

  ~ScopedDisableMemoryTagChecks() {
    if (!active)
      return;
    __asm__ __volatile__(
        R"(
        .arch_extension memtag
        msr tco, %0
        )"
        :
        : "r"(PrevTCO));
  }
};

inline uptr selectRandomTag(uptr Ptr, uptr ExcludeMask) {
  ExcludeMask |= 1; // Always exclude Tag 0.
  uptr TaggedPtr;
  __asm__ __volatile__(
      R"(
      .arch_extension memtag
      irg %[TaggedPtr], %[Ptr], %[ExcludeMask]
      )"
      : [TaggedPtr] "=r"(TaggedPtr)
      : [Ptr] "r"(Ptr), [ExcludeMask] "r"(ExcludeMask));
  return TaggedPtr;
}

inline uptr addFixedTag(uptr Ptr, uptr Tag) {
  DCHECK_LT(Tag, 16);
  DCHECK_EQ(untagPointer(Ptr), Ptr);
  return Ptr | (Tag << 56);
}

inline uptr storeTags(uptr Begin, uptr End) {
  DCHECK_EQ(0, Begin % 16);
  uptr LineSize, Next, Tmp;
  __asm__ __volatile__(
      R"(
    .arch_extension memtag

    // Compute the cache line size in bytes (DCZID_EL0 stores it as the log2
    // of the number of 4-byte words) and bail out to the slow path if DCZID_EL0
    // indicates that the DC instructions are unavailable.
    DCZID .req %[Tmp]
    mrs DCZID, dczid_el0
    tbnz DCZID, #4, 3f
    and DCZID, DCZID, #15
    mov %[LineSize], #4
    lsl %[LineSize], %[LineSize], DCZID
    .unreq DCZID

    // Our main loop doesn't handle the case where we don't need to perform any
    // DC GZVA operations. If the size of our tagged region is less than
    // twice the cache line size, bail out to the slow path since it's not
    // guaranteed that we'll be able to do a DC GZVA.
    Size .req %[Tmp]
    sub Size, %[End], %[Cur]
    cmp Size, %[LineSize], lsl #1
    b.lt 3f
    .unreq Size

    LineMask .req %[Tmp]
    sub LineMask, %[LineSize], #1

    // STZG until the start of the next cache line.
    orr %[Next], %[Cur], LineMask
  1:
    stzg %[Cur], [%[Cur]], #16
    cmp %[Cur], %[Next]
    b.lt 1b

    // DC GZVA cache lines until we have no more full cache lines.
    bic %[Next], %[End], LineMask
    .unreq LineMask
  2:
    dc gzva, %[Cur]
    add %[Cur], %[Cur], %[LineSize]
    cmp %[Cur], %[Next]
    b.lt 2b

    // STZG until the end of the tagged region. This loop is also used to handle
    // slow path cases.
  3:
    cmp %[Cur], %[End]
    b.ge 4f
    stzg %[Cur], [%[Cur]], #16
    b 3b

  4:
  )"
      : [Cur] "+&r"(Begin), [LineSize] "=&r"(LineSize), [Next] "=&r"(Next),
        [Tmp] "=&r"(Tmp)
      : [End] "r"(End)
      : "memory");
  DCHECK_EQ(0, Begin % 16);
  return Begin;
}

inline void storeTag(uptr Ptr) {
  DCHECK_EQ(0, Ptr % 16);
  __asm__ __volatile__(R"(
    .arch_extension memtag
    stg %0, [%0]
  )"
                       :
                       : "r"(Ptr)
                       : "memory");
}

inline uptr loadTag(uptr Ptr) {
  DCHECK_EQ(0, Ptr % 16);
  uptr TaggedPtr = Ptr;
  __asm__ __volatile__(
      R"(
      .arch_extension memtag
      ldg %0, [%0]
      )"
      : "+r"(TaggedPtr)
      :
      : "memory");
  return TaggedPtr;
}

// --- 插入点 2: 在文件后半部分的 #else 之前 ---

#elif SCUDO_ZIMTE 

// ============================================================================
// RISC-V Zimte (MTE) Implementation
// ============================================================================


inline bool systemSupportsMemoryTagging() { 
  const char *env = getenv("SCUDO_MTE_ENABLE");
  if (env && strcmp(env, "1") == 0) {
      return true;
  }
  return false;
  // return true; 
}
inline bool systemDetectsMemoryTagFaultsTestOnly() { return true; }
inline void enableSystemMemoryTaggingTestOnly() {}

struct ScopedDisableMemoryTagChecks {
  ScopedDisableMemoryTagChecks(bool cond = true) {}
};

// 3. 标签操作 API
inline uptr selectRandomTag(uptr Ptr, uptr ExcludeMask) {
  void* Result = __builtin_riscv_zimte_gentag((void*)Ptr);
  return (uptr)Result;
}


inline uptr addFixedTag(uptr Ptr, uptr Tag) {
  DCHECK_LT(Tag, 16);
  DCHECK_EQ(untagPointer(Ptr), Ptr);
  
  if (Tag == 0) return Ptr;
  return addTagImmediate(Ptr, Tag);  // 调用 memtag_zimte.h
}


inline uptr storeTags(uptr Begin, uptr End) {
  DCHECK_EQ(0, Begin % 16);  // 必须 16 字节对齐
  DCHECK_EQ(0, End % 16);
  
  uptr Tag = extractTag(Begin);
  
  // 为每个 16 字节块设置标签
  for (uptr Ptr = Begin; Ptr < End; Ptr += 16) {
    // 先将标签添加到指针
    uptr TaggedPtr = addFixedTag(Ptr, Tag);
    // 然后调用 settag 将 ptag 写入内存
    __builtin_riscv_zimte_settag(reinterpret_cast<void*>(TaggedPtr), 1);
  }
  
  return End;
}

inline void storeTag(uptr Ptr) {
  DCHECK_EQ(0, Ptr % 16);
  
  // Ptr 已经包含标签，直接调用 settag
  __builtin_riscv_zimte_settag(reinterpret_cast<void*>(Ptr), 1);
}

inline uptr loadTag(uptr Ptr) {
  // Zimte 暂无直接读取指令，返回指针自带 tag
  return Ptr; 
}

#else

inline NORETURN bool systemSupportsMemoryTagging() {
  UNREACHABLE("memory tagging not supported");
}

inline NORETURN bool systemDetectsMemoryTagFaultsTestOnly() {
  UNREACHABLE("memory tagging not supported");
}

inline NORETURN void enableSystemMemoryTaggingTestOnly() {
  UNREACHABLE("memory tagging not supported");
}

struct ScopedDisableMemoryTagChecks {
  ScopedDisableMemoryTagChecks(UNUSED bool cond = true) {}
};

inline NORETURN uptr selectRandomTag(uptr Ptr, uptr ExcludeMask) {
  (void)Ptr;
  (void)ExcludeMask;
  UNREACHABLE("memory tagging not supported");
}

inline NORETURN uptr addFixedTag(uptr Ptr, uptr Tag) {
  (void)Ptr;
  (void)Tag;
  UNREACHABLE("memory tagging not supported");
}

inline NORETURN uptr storeTags(uptr Begin, uptr End) {
  (void)Begin;
  (void)End;
  UNREACHABLE("memory tagging not supported");
}

inline NORETURN void storeTag(uptr Ptr) {
  (void)Ptr;
  UNREACHABLE("memory tagging not supported");
}

inline NORETURN uptr loadTag(uptr Ptr) {
  (void)Ptr;
  UNREACHABLE("memory tagging not supported");
}

#endif

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wmissing-noreturn"
inline void setRandomTag(void *Ptr, uptr Size, uptr ExcludeMask,
                         uptr *TaggedBegin, uptr *TaggedEnd) {
  *TaggedBegin = selectRandomTag(reinterpret_cast<uptr>(Ptr), ExcludeMask);
  *TaggedEnd = storeTags(*TaggedBegin, *TaggedBegin + Size);
}
#pragma GCC diagnostic pop

inline void *untagPointer(void *Ptr) {
  return reinterpret_cast<void *>(untagPointer(reinterpret_cast<uptr>(Ptr)));
}

inline void *loadTag(void *Ptr) {
  return reinterpret_cast<void *>(loadTag(reinterpret_cast<uptr>(Ptr)));
}

inline void *addFixedTag(void *Ptr, uptr Tag) {
  return reinterpret_cast<void *>(
      addFixedTag(reinterpret_cast<uptr>(Ptr), Tag));
}

template <typename Config>
inline constexpr bool allocatorSupportsMemoryTagging() {
  return archSupportsMemoryTagging() && Config::getMaySupportMemoryTagging() &&
         (1 << SCUDO_MIN_ALIGNMENT_LOG) >= archMemoryTagGranuleSize();
}

} // namespace scudo

#endif
