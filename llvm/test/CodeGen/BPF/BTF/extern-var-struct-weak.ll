; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
;
; Source code:
;   typedef struct t1 { int f1; } __t1;
;   extern __t1 global __attribute__((weak));
;   int test() { return global.f1; }
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm test.c

%struct.t1 = type { i32 }

@global = extern_weak dso_local local_unnamed_addr global %struct.t1, align 4, !dbg !0
; Function Attrs: norecurse nounwind readonly
define dso_local i32 @test() local_unnamed_addr #0 !dbg !15 {
entry:
  %0 = load i32, ptr @global, align 4, !dbg !18, !tbaa !19
  ret i32 %0, !dbg !24
}

; CHECK-BTF:             [1] FUNC_PROTO '(anon)' ret_type_id=2 vlen=0
; CHECK-BTF-NEXT:        [2] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [3] FUNC 'test' type_id=1 linkage=global
; CHECK-BTF-NEXT:        [4] TYPEDEF '__t1' type_id=5
; CHECK-BTF-NEXT:        [5] STRUCT 't1' size=4 vlen=1
; CHECK-BTF-NEXT:                'f1' type_id=2 bits_offset=0
; CHECK-BTF-NEXT:        [6] VAR 'global' type_id=4, linkage=extern

attributes #0 = { norecurse nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!11, !12, !13}
!llvm.ident = !{!14}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "global", scope: !2, file: !3, line: 2, type: !6, isLocal: false, isDefinition: false)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 10.0.0 (https://github.com/llvm/llvm-project.git 71a9518c93fe1dce9611c24bc707e5baf1f39f0d)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !5, nameTableKind: None)
!3 = !DIFile(filename: "test.c", directory: "/tmp/home/yhs/work/tests/extern")
!4 = !{}
!5 = !{!0}
!6 = !DIDerivedType(tag: DW_TAG_typedef, name: "__t1", file: !3, line: 1, baseType: !7)
!7 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "t1", file: !3, line: 1, size: 32, elements: !8)
!8 = !{!9}
!9 = !DIDerivedType(tag: DW_TAG_member, name: "f1", scope: !7, file: !3, line: 1, baseType: !10, size: 32)
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !{i32 7, !"Dwarf Version", i32 4}
!12 = !{i32 2, !"Debug Info Version", i32 3}
!13 = !{i32 1, !"wchar_size", i32 4}
!14 = !{!"clang version 10.0.0 (https://github.com/llvm/llvm-project.git 71a9518c93fe1dce9611c24bc707e5baf1f39f0d)"}
!15 = distinct !DISubprogram(name: "test", scope: !3, file: !3, line: 3, type: !16, scopeLine: 3, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !4)
!16 = !DISubroutineType(types: !17)
!17 = !{!10}
!18 = !DILocation(line: 3, column: 28, scope: !15)
!19 = !{!20, !21, i64 0}
!20 = !{!"t1", !21, i64 0}
!21 = !{!"int", !22, i64 0}
!22 = !{!"omnipotent char", !23, i64 0}
!23 = !{!"Simple C/C++ TBAA"}
!24 = !DILocation(line: 3, column: 14, scope: !15)
