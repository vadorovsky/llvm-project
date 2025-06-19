; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; Source code:
;   struct t {
;     int a;
;     int b;
;     char c[];
;   };
;   static volatile struct t sv = {3, 4, "abcdefghi"};
;   int test() { return sv.a; }
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm test.c

@sv = internal global { i32, i32, [10 x i8] } { i32 3, i32 4, [10 x i8] c"abcdefghi\00" }, align 4, !dbg !0

; Function Attrs: norecurse nounwind
define dso_local i32 @test() local_unnamed_addr #0 !dbg !21 {
  %1 = load volatile i32, ptr @sv, align 4, !dbg !24, !tbaa !25
  ret i32 %1, !dbg !29
}

; CHECK-BTF:             [1] FUNC_PROTO '(anon)' ret_type_id=2 vlen=0
; CHECK-BTF-NEXT:        [2] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [3] FUNC 'test' type_id=1 linkage=global
; CHECK-BTF-NEXT:        [4] VOLATILE '(anon)' type_id=5
; CHECK-BTF-NEXT:        [5] STRUCT 't' size=8 vlen=3
; CHECK-BTF-NEXT:                'a' type_id=2 bits_offset=0
; CHECK-BTF-NEXT:                'b' type_id=2 bits_offset=32
; CHECK-BTF-NEXT:                'c' type_id=7 bits_offset=64
; CHECK-BTF-NEXT:        [6] INT 'char' size=1 bits_offset=0 nr_bits=8 encoding=SIGNED
; CHECK-BTF-NEXT:        [7] ARRAY '(anon)' type_id=6 index_type_id=8 nr_elems=0
; CHECK-BTF-NEXT:        [8] INT '__ARRAY_SIZE_TYPE__' size=4 bits_offset=0 nr_bits=32 encoding=(none)
; CHECK-BTF-NEXT:        [9] VAR 'sv' type_id=4, linkage=static
; CHECK-BTF-NEXT:        [10] DATASEC '.data' size=0 vlen=1
; CHECK-BTF-NEXT:                type_id=9 offset=0 size=20

attributes #0 = { norecurse nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "less-precise-fpmad"="false" "frame-pointer"="all" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!17, !18, !19}
!llvm.ident = !{!20}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "sv", scope: !2, file: !3, line: 6, type: !6, isLocal: true, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 8.0.20181009 ", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !5, nameTableKind: None)
!3 = !DIFile(filename: "test.c", directory: "/home/yhs/work/tests/llvm/bug")
!4 = !{}
!5 = !{!0}
!6 = !DIDerivedType(tag: DW_TAG_volatile_type, baseType: !7)
!7 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "t", file: !3, line: 1, size: 64, elements: !8)
!8 = !{!9, !11, !12}
!9 = !DIDerivedType(tag: DW_TAG_member, name: "a", scope: !7, file: !3, line: 2, baseType: !10, size: 32)
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !DIDerivedType(tag: DW_TAG_member, name: "b", scope: !7, file: !3, line: 3, baseType: !10, size: 32, offset: 32)
!12 = !DIDerivedType(tag: DW_TAG_member, name: "c", scope: !7, file: !3, line: 4, baseType: !13, offset: 64)
!13 = !DICompositeType(tag: DW_TAG_array_type, baseType: !14, elements: !15)
!14 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!15 = !{!16}
!16 = !DISubrange(count: -1)
!17 = !{i32 2, !"Dwarf Version", i32 4}
!18 = !{i32 2, !"Debug Info Version", i32 3}
!19 = !{i32 1, !"wchar_size", i32 4}
!20 = !{!"clang version 8.0.20181009 "}
!21 = distinct !DISubprogram(name: "test", scope: !3, file: !3, line: 7, type: !22, isLocal: false, isDefinition: true, scopeLine: 7, isOptimized: true, unit: !2, retainedNodes: !4)
!22 = !DISubroutineType(types: !23)
!23 = !{!10}
!24 = !DILocation(line: 7, column: 24, scope: !21)
!25 = !{!26, !26, i64 0}
!26 = !{!"int", !27, i64 0}
!27 = !{!"omnipotent char", !28, i64 0}
!28 = !{!"Simple C/C++ TBAA"}
!29 = !DILocation(line: 7, column: 14, scope: !21)
