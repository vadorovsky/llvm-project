; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s

; Source code:
;   static volatile char a __attribute__((section("maps"))) = 3;
;   int foo() {
;     static volatile short b __attribute__((section("maps"))) = 4;
;     return a + b;
;   }
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm test.c

@foo.b = internal global i16 4, section "maps", align 2, !dbg !0
@a = internal global i8 3, section "maps", align 1, !dbg !10

; Function Attrs: norecurse nounwind
define dso_local i32 @foo() local_unnamed_addr #0 !dbg !2 {
  %1 = load volatile i8, ptr @a, align 1, !dbg !20, !tbaa !21
  %2 = sext i8 %1 to i32, !dbg !20
  %3 = load volatile i16, ptr @foo.b, align 2, !dbg !24, !tbaa !25
  %4 = sext i16 %3 to i32, !dbg !24
  %5 = add nsw i32 %4, %2, !dbg !27
  ret i32 %5, !dbg !28
}

; CHECK-BTF:             [1] FUNC_PROTO '(anon)' ret_type_id=2 vlen=0
; CHECK-BTF-NEXT:        [2] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [3] FUNC 'foo' type_id=1 linkage=global
; CHECK-BTF-NEXT:        [4] VOLATILE '(anon)' type_id=5
; CHECK-BTF-NEXT:        [5] INT 'short' size=2 bits_offset=0 nr_bits=16 encoding=SIGNED
; CHECK-BTF-NEXT:        [6] VAR 'foo.b' type_id=4, linkage=static
; CHECK-BTF-NEXT:        [7] VOLATILE '(anon)' type_id=8
; CHECK-BTF-NEXT:        [8] INT 'char' size=1 bits_offset=0 nr_bits=8 encoding=SIGNED
; CHECK-BTF-NEXT:        [9] VAR 'a' type_id=7, linkage=static
; CHECK-BTF-NEXT:        [10] DATASEC 'maps' size=0 vlen=2
; CHECK-BTF-NEXT:                type_id=6 offset=0 size=2
; CHECK-BTF-NEXT:                type_id=9 offset=2 size=1

attributes #0 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "frame-pointer"="all" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!7}
!llvm.module.flags = !{!16, !17, !18}
!llvm.ident = !{!19}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "b", scope: !2, file: !3, line: 3, type: !14, isLocal: true, isDefinition: true)
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
!12 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !13)
!13 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!14 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !15)
!15 = !DIBasicType(name: "short", size: 16, encoding: DW_ATE_signed)
!16 = !{i32 2, !"Dwarf Version", i32 4}
!17 = !{i32 2, !"Debug Info Version", i32 3}
!18 = !{i32 1, !"wchar_size", i32 4}
!19 = !{!"clang version 8.0.20181009 "}
!20 = !DILocation(line: 4, column: 10, scope: !2)
!21 = !{!22, !22, i64 0}
!22 = !{!"omnipotent char", !23, i64 0}
!23 = !{!"Simple C/C++ TBAA"}
!24 = !DILocation(line: 4, column: 14, scope: !2)
!25 = !{!26, !26, i64 0}
!26 = !{!"short", !22, i64 0}
!27 = !DILocation(line: 4, column: 12, scope: !2)
!28 = !DILocation(line: 4, column: 3, scope: !2)
