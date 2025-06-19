; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s

; Source code:
;   static volatile const char __attribute__((section("maps"))) a;
;   int foo() {
;     static volatile const short b __attribute__((section("maps"))) = 3;
;     return a + b;
;   }
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm test.c

@foo.b = internal constant i16 3, section "maps", align 2, !dbg !0
@a = internal constant i8 0, section "maps", align 1, !dbg !10

; Function Attrs: norecurse nounwind
define dso_local i32 @foo() local_unnamed_addr #0 !dbg !2 {
  %1 = load volatile i8, ptr @a, align 1, !dbg !22, !tbaa !23
  %2 = sext i8 %1 to i32, !dbg !22
  %3 = load volatile i16, ptr @foo.b, align 2, !dbg !26, !tbaa !27
  %4 = sext i16 %3 to i32, !dbg !26
  %5 = add nsw i32 %4, %2, !dbg !29
  ret i32 %5, !dbg !30
}

; CHECK-BTF:             [1] FUNC_PROTO '(anon)' ret_type_id=2 vlen=0
; CHECK-BTF-NEXT:        [2] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [3] FUNC 'foo' type_id=1 linkage=global
; CHECK-BTF-NEXT:        [4] CONST '(anon)' type_id=5
; CHECK-BTF-NEXT:        [5] VOLATILE '(anon)' type_id=6
; CHECK-BTF-NEXT:        [6] INT 'short' size=2 bits_offset=0 nr_bits=16 encoding=SIGNED
; CHECK-BTF-NEXT:        [7] VAR 'foo.b' type_id=4, linkage=static
; CHECK-BTF-NEXT:        [8] CONST '(anon)' type_id=9
; CHECK-BTF-NEXT:        [9] VOLATILE '(anon)' type_id=10
; CHECK-BTF-NEXT:        [10] INT 'char' size=1 bits_offset=0 nr_bits=8 encoding=SIGNED
; CHECK-BTF-NEXT:        [11] VAR 'a' type_id=8, linkage=static
; CHECK-BTF-NEXT:        [12] DATASEC 'maps' size=0 vlen=2
; CHECK-BTF-NEXT:                type_id=7 offset=0 size=2
; CHECK-BTF-NEXT:                type_id=11 offset=2 size=1

attributes #0 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "frame-pointer"="all" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!7}
!llvm.module.flags = !{!18, !19, !20}
!llvm.ident = !{!21}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "b", scope: !2, file: !3, line: 3, type: !15, isLocal: true, isDefinition: true)
!2 = distinct !DISubprogram(name: "foo", scope: !3, file: !3, line: 2, type: !4, isLocal: false, isDefinition: true, scopeLine: 2, isOptimized: true, unit: !7, retainedNodes: !8)
!3 = !DIFile(filename: "test.c", directory: "/home/yhs/work/tests/llvm/bug")
!4 = !DISubroutineType(types: !5)
!5 = !{!6}
!6 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!7 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 8.0.20181009 ", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !8, globals: !9, nameTableKind: None)
!8 = !{}
!9 = !{!0, !10}
!10 = !DIGlobalVariableExpression(var: !11, expr: !DIExpression())
!11 = distinct !DIGlobalVariable(name: "a", scope: !7, file: !3, line: 1, type: !12, isLocal: true, isDefinition: true)
!12 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !13)
!13 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !14)
!14 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!15 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !16)
!16 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !17)
!17 = !DIBasicType(name: "short", size: 16, encoding: DW_ATE_signed)
!18 = !{i32 2, !"Dwarf Version", i32 4}
!19 = !{i32 2, !"Debug Info Version", i32 3}
!20 = !{i32 1, !"wchar_size", i32 4}
!21 = !{!"clang version 8.0.20181009 "}
!22 = !DILocation(line: 4, column: 10, scope: !2)
!23 = !{!24, !24, i64 0}
!24 = !{!"omnipotent char", !25, i64 0}
!25 = !{!"Simple C/C++ TBAA"}
!26 = !DILocation(line: 4, column: 14, scope: !2)
!27 = !{!28, !28, i64 0}
!28 = !{!"short", !24, i64 0}
!29 = !DILocation(line: 4, column: 12, scope: !2)
!30 = !DILocation(line: 4, column: 3, scope: !2)
