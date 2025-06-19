; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s

; Source code:
;   struct t1 {char m1; int n1;} a;
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm t.c

%struct.t1 = type { i8, i32 }

@a = common dso_local local_unnamed_addr global %struct.t1 zeroinitializer, align 4, !dbg !0

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!12, !13, !14}
!llvm.ident = !{!15}

; CHECK-BTF:             [1] STRUCT 't1' size=8 vlen=2
; CHECK-BTF-NEXT:                'm1' type_id=2 bits_offset=0
; CHECK-BTF-NEXT:                'n1' type_id=3 bits_offset=32
; CHECK-BTF-NEXT:        [2] INT 'char' size=1 bits_offset=0 nr_bits=8 encoding=SIGNED
; CHECK-BTF-NEXT:        [3] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "a", scope: !2, file: !3, line: 1, type: !6, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 8.0.0 (trunk 345296) (llvm/trunk 345297)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !5, nameTableKind: None)
!3 = !DIFile(filename: "t.c", directory: "/home/yhs/tmp")
!4 = !{}
!5 = !{!0}
!6 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "t1", file: !3, line: 1, size: 64, elements: !7)
!7 = !{!8, !10}
!8 = !DIDerivedType(tag: DW_TAG_member, name: "m1", scope: !6, file: !3, line: 1, baseType: !9, size: 8)
!9 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!10 = !DIDerivedType(tag: DW_TAG_member, name: "n1", scope: !6, file: !3, line: 1, baseType: !11, size: 32, offset: 32)
!11 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!12 = !{i32 2, !"Dwarf Version", i32 4}
!13 = !{i32 2, !"Debug Info Version", i32 3}
!14 = !{i32 1, !"wchar_size", i32 4}
!15 = !{!"clang version 8.0.0 (trunk 345296) (llvm/trunk 345297)"}
