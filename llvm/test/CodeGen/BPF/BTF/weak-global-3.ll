; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; 
; Source code:
;   const volatile char g __attribute__((weak)) = 2;
;   int test() {
;     return g;
;   }
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm test.c

@g = weak_odr dso_local constant i8 2, align 1, !dbg !0

; Function Attrs: nofree norecurse nounwind willreturn
define dso_local i32 @test() local_unnamed_addr #0 !dbg !13 {
entry:
  %0 = load volatile i8, ptr @g, align 1, !dbg !17, !tbaa !18
  %conv = sext i8 %0 to i32, !dbg !17
  ret i32 %conv, !dbg !21
}

; CHECK-BTF:             [1] FUNC_PROTO '(anon)' ret_type_id=2 vlen=0
; CHECK-BTF-NEXT:        [2] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [3] FUNC 'test' type_id=1 linkage=global
; CHECK-BTF-NEXT:        [4] CONST '(anon)' type_id=5
; CHECK-BTF-NEXT:        [5] VOLATILE '(anon)' type_id=6
; CHECK-BTF-NEXT:        [6] INT 'char' size=1 bits_offset=0 nr_bits=8 encoding=SIGNED
; CHECK-BTF-NEXT:        [7] VAR 'g' type_id=4, linkage=global
; CHECK-BTF-NEXT:        [8] DATASEC '.rodata' size=0 vlen=1
; CHECK-BTF-NEXT:                type_id=7 offset=0 size=1

attributes #0 = { nofree norecurse nounwind willreturn "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!9, !10, !11}
!llvm.ident = !{!12}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "g", scope: !2, file: !3, line: 1, type: !6, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 13.0.0 (https://github.com/llvm/llvm-project.git 9cc417cbca1cece0d55fa3d1e15682943a06139e)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !5, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "test.c", directory: "/tmp/home/yhs/btf/tests")
!4 = !{}
!5 = !{!0}
!6 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !7)
!7 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !8)
!8 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!9 = !{i32 7, !"Dwarf Version", i32 4}
!10 = !{i32 2, !"Debug Info Version", i32 3}
!11 = !{i32 1, !"wchar_size", i32 4}
!12 = !{!"clang version 13.0.0 (https://github.com/llvm/llvm-project.git 9cc417cbca1cece0d55fa3d1e15682943a06139e)"}
!13 = distinct !DISubprogram(name: "test", scope: !3, file: !3, line: 2, type: !14, scopeLine: 2, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !4)
!14 = !DISubroutineType(types: !15)
!15 = !{!16}
!16 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!17 = !DILocation(line: 3, column: 10, scope: !13)
!18 = !{!19, !19, i64 0}
!19 = !{!"omnipotent char", !20, i64 0}
!20 = !{!"Simple C/C++ TBAA"}
!21 = !DILocation(line: 3, column: 3, scope: !13)
