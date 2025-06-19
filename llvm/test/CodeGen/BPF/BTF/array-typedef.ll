; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s

; Source code:
;   typedef unsigned _int;
;   typedef _int __int;
;   __int a[10];
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm t.c

@a = common dso_local local_unnamed_addr global [10 x i32] zeroinitializer, align 4, !dbg !0

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!12, !13, !14}
!llvm.ident = !{!15}

; CHECK-BTF:             [1] TYPEDEF '__int' type_id=2
; CHECK-BTF-NEXT:        [2] TYPEDEF '_int' type_id=3
; CHECK-BTF-NEXT:        [3] INT 'unsigned int' size=4 bits_offset=0 nr_bits=32 encoding=(none)
; CHECK-BTF-NEXT:        [4] ARRAY '(anon)' type_id=1 index_type_id=5 nr_elems=10
; CHECK-BTF-NEXT:        [5] INT '__ARRAY_SIZE_TYPE__' size=4 bits_offset=0 nr_bits=32 encoding=(none)

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "a", scope: !2, file: !3, line: 3, type: !6, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 8.0.0 (trunk 345296) (llvm/trunk 345297)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !5, nameTableKind: None)
!3 = !DIFile(filename: "t.c", directory: "/home/yhs/tmp")
!4 = !{}
!5 = !{!0}
!6 = !DICompositeType(tag: DW_TAG_array_type, baseType: !7, size: 320, elements: !10)
!7 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int", file: !3, line: 2, baseType: !8)
!8 = !DIDerivedType(tag: DW_TAG_typedef, name: "_int", file: !3, line: 1, baseType: !9)
!9 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!10 = !{!11}
!11 = !DISubrange(count: 10)
!12 = !{i32 2, !"Dwarf Version", i32 4}
!13 = !{i32 2, !"Debug Info Version", i32 3}
!14 = !{i32 1, !"wchar_size", i32 4}
!15 = !{!"clang version 8.0.0 (trunk 345296) (llvm/trunk 345297)"}
