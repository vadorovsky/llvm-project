//===---- BPF.cpp ---------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "Target.h"
#include "llvm/BinaryFormat/ELF.h"

using namespace llvm;
using namespace llvm::ELF;
using namespace lld;
using namespace lld::elf;

namespace {
class BPF final : public TargetInfo {
public:
  BPF(Ctx &ctx);
  int64_t getImplicitAddend(const uint8_t *buf, RelType type) const override;
  void relocate(uint8_t *loc, const Relocation &rel,
                uint64_t val) const override;
  RelType getDynRel(RelType type) const override;
  RelExpr getRelExpr(RelType type, const Symbol &s,
                     const uint8_t *loc) const override;
};
} // namespace

BPF::BPF(Ctx &ctx): TargetInfo(ctx) {
  relativeRel = R_BPF_64_32;
  symbolicRel = R_BPF_64_64;
  defaultCommonPageSize = 8;
  defaultMaxPageSize = 8;
  defaultImageBase = 0;
}

int64_t BPF::getImplicitAddend(const uint8_t *buf, RelType type) const {
  switch (type) {
  case R_BPF_NONE:
    return 0;
  case R_BPF_64_64:
    return read32(ctx, buf + 4);
  case R_BPF_64_ABS64:
    return read64(ctx, buf);
  case R_BPF_64_ABS32:
  case R_BPF_64_NODYLD32:
    return read32(ctx, buf);
  case R_BPF_64_32:
    // The addend is the (sec_offset/8 - 1) which could be negative.
    return (int32_t)(uint32_t)(read32(ctx, buf + 4) * 8);
  default:
    llvm_unreachable("unknown relocation");
  }
}

void BPF::relocate(uint8_t *loc, const Relocation &rel, uint64_t val) const {
  switch (rel.type) {
  case R_BPF_NONE:
    break;
  case R_BPF_64_64:
    write32(ctx, loc + 4, (uint32_t)val);
    break;
  case R_BPF_64_ABS64:
    write64(ctx, loc, val);
    break;
  case R_BPF_64_ABS32:
  case R_BPF_64_NODYLD32:
    write32(ctx, loc, (uint32_t)val);
    break;
  case R_BPF_64_32:
    write32(ctx, loc + 4, (uint32_t)(val / 8));
    break;
  default:
    llvm_unreachable("unknown relocation");
  }
}

RelType BPF::getDynRel(RelType type) const { return R_BPF_NONE; }

RelExpr BPF::getRelExpr(RelType type, const Symbol &s,
                        const uint8_t *loc) const {
  switch (type) {
  case R_BPF_NONE:
    return R_NONE;
  case R_BPF_64_64:
  case R_BPF_64_ABS64:
  case R_BPF_64_ABS32:
  case R_BPF_64_NODYLD32:
  case R_BPF_64_32:
    return R_ABS;
  default:
    llvm_unreachable("unknown relocation");
  }
}

void elf::setBPFTargetInfo(Ctx &ctx) { ctx.target.reset(new BPF(ctx)); }
