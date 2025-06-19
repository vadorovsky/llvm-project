; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s

; Source code:
;   typedef int * int_ptr;
;   static int * volatile v1;
;   static const int * volatile v2;
;   static volatile int_ptr v3 = 0;
;   static volatile const int_ptr v4 = 0;
;   long foo() { return (long)(v1 - v2 + v3 - v4); }
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm test.c

@v1 = internal global ptr null, align 8, !dbg !0
@v2 = internal global ptr null, align 8, !dbg !8
@v3 = internal global ptr null, align 8, !dbg !14
@v4 = internal constant ptr null, align 8, !dbg !19

; Function Attrs: norecurse nounwind
define dso_local i64 @foo() local_unnamed_addr #0 !dbg !27 {
  %1 = load volatile ptr, ptr @v1, align 8, !dbg !29, !tbaa !30
  %2 = load volatile ptr, ptr @v2, align 8, !dbg !34, !tbaa !30
  %3 = ptrtoint ptr %1 to i64, !dbg !35
  %4 = ptrtoint ptr %2 to i64, !dbg !35
  %5 = sub i64 %3, %4, !dbg !35
  %6 = ashr exact i64 %5, 2, !dbg !35
  %7 = load volatile ptr, ptr @v3, align 8, !dbg !36, !tbaa !30
  %8 = getelementptr inbounds i32, ptr %7, i64 %6, !dbg !37
  %9 = load volatile ptr, ptr @v4, align 8, !dbg !38, !tbaa !30
  %10 = ptrtoint ptr %8 to i64, !dbg !39
  %11 = ptrtoint ptr %9 to i64, !dbg !39
  %12 = sub i64 %10, %11, !dbg !39
  %13 = ashr exact i64 %12, 2, !dbg !39
  ret i64 %13, !dbg !40
}

; CHECK-BTF:             [1] FUNC_PROTO '(anon)' ret_type_id=2 vlen=0
; CHECK-BTF-NEXT:        [2] INT 'long int' size=8 bits_offset=0 nr_bits=64 encoding=SIGNED
; CHECK-BTF-NEXT:        [3] FUNC 'foo' type_id=1 linkage=global
; CHECK-BTF-NEXT:        [4] VOLATILE '(anon)' type_id=5
; CHECK-BTF-NEXT:        [5] PTR '(anon)' type_id=6
; CHECK-BTF-NEXT:        [6] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [7] VAR 'v1' type_id=4, linkage=static
; CHECK-BTF-NEXT:        [8] VOLATILE '(anon)' type_id=9
; CHECK-BTF-NEXT:        [9] PTR '(anon)' type_id=10
; CHECK-BTF-NEXT:        [10] CONST '(anon)' type_id=6
; CHECK-BTF-NEXT:        [11] VAR 'v2' type_id=8, linkage=static
; CHECK-BTF-NEXT:        [12] VOLATILE '(anon)' type_id=13
; CHECK-BTF-NEXT:        [13] TYPEDEF 'int_ptr' type_id=5
; CHECK-BTF-NEXT:        [14] VAR 'v3' type_id=12, linkage=static
; CHECK-BTF-NEXT:        [15] CONST '(anon)' type_id=12
; CHECK-BTF-NEXT:        [16] VAR 'v4' type_id=15, linkage=static
; CHECK-BTF-NEXT:        [17] DATASEC '.bss' size=0 vlen=3
; CHECK-BTF-NEXT:                type_id=7 offset=0 size=8
; CHECK-BTF-NEXT:                type_id=11 offset=8 size=8
; CHECK-BTF-NEXT:                type_id=14 offset=16 size=8
; CHECK-BTF-NEXT:        [18] DATASEC '.rodata' size=0 vlen=1
; CHECK-BTF-NEXT:                type_id=16 offset=0 size=8

attributes #0 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "frame-pointer"="all" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!23, !24, !25}
!llvm.ident = !{!26}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "v1", scope: !2, file: !3, line: 2, type: !22, isLocal: true, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 8.0.20181009 ", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !5, globals: !7, nameTableKind: None)
!3 = !DIFile(filename: "test.c", directory: "/home/yhs/work/tests/llvm/bugs")
!4 = !{}
!5 = !{!6}
!6 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!7 = !{!0, !8, !14, !19}
!8 = !DIGlobalVariableExpression(var: !9, expr: !DIExpression())
!9 = distinct !DIGlobalVariable(name: "v2", scope: !2, file: !3, line: 3, type: !10, isLocal: true, isDefinition: true)
!10 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !11)
!11 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !12, size: 64)
!12 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !13)
!13 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!14 = !DIGlobalVariableExpression(var: !15, expr: !DIExpression())
!15 = distinct !DIGlobalVariable(name: "v3", scope: !2, file: !3, line: 4, type: !16, isLocal: true, isDefinition: true)
!16 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !17)
!17 = !DIDerivedType(tag: DW_TAG_typedef, name: "int_ptr", file: !3, line: 1, baseType: !18)
!18 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !13, size: 64)
!19 = !DIGlobalVariableExpression(var: !20, expr: !DIExpression())
!20 = distinct !DIGlobalVariable(name: "v4", scope: !2, file: !3, line: 5, type: !21, isLocal: true, isDefinition: true)
!21 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !16)
!22 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !18)
!23 = !{i32 2, !"Dwarf Version", i32 4}
!24 = !{i32 2, !"Debug Info Version", i32 3}
!25 = !{i32 1, !"wchar_size", i32 4}
!26 = !{!"clang version 8.0.20181009 "}
!27 = distinct !DISubprogram(name: "foo", scope: !3, file: !3, line: 6, type: !28, isLocal: false, isDefinition: true, scopeLine: 6, isOptimized: true, unit: !2, retainedNodes: !4)
!28 = !DISubroutineType(types: !5)
!29 = !DILocation(line: 6, column: 28, scope: !27)
!30 = !{!31, !31, i64 0}
!31 = !{!"any pointer", !32, i64 0}
!32 = !{!"omnipotent char", !33, i64 0}
!33 = !{!"Simple C/C++ TBAA"}
!34 = !DILocation(line: 6, column: 33, scope: !27)
!35 = !DILocation(line: 6, column: 31, scope: !27)
!36 = !DILocation(line: 6, column: 38, scope: !27)
!37 = !DILocation(line: 6, column: 36, scope: !27)
!38 = !DILocation(line: 6, column: 43, scope: !27)
!39 = !DILocation(line: 6, column: 41, scope: !27)
!40 = !DILocation(line: 6, column: 14, scope: !27)
