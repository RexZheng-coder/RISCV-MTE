#ifndef SCUDO_MEMTAG_ZIMTE_H_
#define SCUDO_MEMTAG_ZIMTE_H_

#include "internal_defs.h"

namespace scudo {

// 使用 GCC Builtin 的优化版本
inline uptr addTagImmediate(uptr Ptr, uptr Tag) {
  DCHECK_LT(Tag, 16);
  
  // Tag 0 特殊处理（无需调用指令）
  if (Tag == 0) return Ptr;
  
  void* Result;
  switch (Tag) {
    case 1:  Result = __builtin_riscv_zimte_addtag((void*)Ptr, 1); break;
    case 2:  Result = __builtin_riscv_zimte_addtag((void*)Ptr, 2); break;
    case 3:  Result = __builtin_riscv_zimte_addtag((void*)Ptr, 3); break;
    case 4:  Result = __builtin_riscv_zimte_addtag((void*)Ptr, 4); break;
    case 5:  Result = __builtin_riscv_zimte_addtag((void*)Ptr, 5); break;
    case 6:  Result = __builtin_riscv_zimte_addtag((void*)Ptr, 6); break;
    case 7:  Result = __builtin_riscv_zimte_addtag((void*)Ptr, 7); break;
    case 8:  Result = __builtin_riscv_zimte_addtag((void*)Ptr, 8); break;
    case 9:  Result = __builtin_riscv_zimte_addtag((void*)Ptr, 9); break;
    case 10: Result = __builtin_riscv_zimte_addtag((void*)Ptr, 10); break;
    case 11: Result = __builtin_riscv_zimte_addtag((void*)Ptr, 11); break;
    case 12: Result = __builtin_riscv_zimte_addtag((void*)Ptr, 12); break;
    case 13: Result = __builtin_riscv_zimte_addtag((void*)Ptr, 13); break;
    case 14: Result = __builtin_riscv_zimte_addtag((void*)Ptr, 14); break;
    case 15: Result = __builtin_riscv_zimte_addtag((void*)Ptr, 15); break;
    default: Result = (void*)Ptr; break;
  }
  return (uptr)Result;
}

inline void setTagImmediate(uptr Ptr, uptr Tag) {
  DCHECK_LT(Tag, 16);
  
  switch (Tag) {
    case 0:  __builtin_riscv_zimte_settag((void*)Ptr, 0); break;
    case 1:  __builtin_riscv_zimte_settag((void*)Ptr, 1); break;
    case 2:  __builtin_riscv_zimte_settag((void*)Ptr, 2); break;
    case 3:  __builtin_riscv_zimte_settag((void*)Ptr, 3); break;
    case 4:  __builtin_riscv_zimte_settag((void*)Ptr, 4); break;
    case 5:  __builtin_riscv_zimte_settag((void*)Ptr, 5); break;
    case 6:  __builtin_riscv_zimte_settag((void*)Ptr, 6); break;
    case 7:  __builtin_riscv_zimte_settag((void*)Ptr, 7); break;
    case 8:  __builtin_riscv_zimte_settag((void*)Ptr, 8); break;
    case 9:  __builtin_riscv_zimte_settag((void*)Ptr, 9); break;
    case 10: __builtin_riscv_zimte_settag((void*)Ptr, 10); break;
    case 11: __builtin_riscv_zimte_settag((void*)Ptr, 11); break;
    case 12: __builtin_riscv_zimte_settag((void*)Ptr, 12); break;
    case 13: __builtin_riscv_zimte_settag((void*)Ptr, 13); break;
    case 14: __builtin_riscv_zimte_settag((void*)Ptr, 14); break;
    case 15: __builtin_riscv_zimte_settag((void*)Ptr, 15); break;
  }
}

} // namespace scudo

#endif // SCUDO_MEMTAG_ZIMTE_H_

