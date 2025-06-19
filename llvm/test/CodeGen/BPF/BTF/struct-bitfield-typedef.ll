; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s

; Source code:
;   typedef int _int;
;   typedef _int __int;
;   struct {char m:2; __int n:3; char p;} a;
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm t.c

%struct.anon = type { i8, i8, [2 x i8] }

@a = common dso_local local_unnamed_addr global %struct.anon zeroinitializer, align 4, !dbg !0

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!15, !16, !17}
!llvm.ident = !{!18}

; CHECK-BTF:             [1] STRUCT '(anon)' size=4 vlen=3
; CHECK-BTF-NEXT:                'm' type_id=2 bits_offset=0 bitfield_size=2
; CHECK-BTF-NEXT:                'n' type_id=3 bits_offset=2 bitfield_size=3
; CHECK-BTF-NEXT:                'p' type_id=2 bits_offset=8 bitfield_size=0
; CHECK-BTF-NEXT:        [2] INT 'char' size=1 bits_offset=0 nr_bits=8 encoding=SIGNED
; CHECK-BTF-NEXT:        [3] TYPEDEF '__int' type_id=4
; CHECK-BTF-NEXT:        [4] TYPEDEF '_int' type_id=5
; CHECK-BTF-NEXT:        [5] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "a", scope: !2, file: !3, line: 3, type: !6, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 8.0.0 (trunk 345296) (llvm/trunk 345297)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !5, nameTableKind: None)
!3 = !DIFile(filename: "t.c", directory: "/home/yhs/tmp")
!4 = !{}
!5 = !{!0}
!6 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !3, line: 3, size: 32, elements: !7)
!7 = !{!8, !10, !14}
!8 = !DIDerivedType(tag: DW_TAG_member, name: "m", scope: !6, file: !3, line: 3, baseType: !9, size: 2, flags: DIFlagBitField, extraData: i64 0)
!9 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!10 = !DIDerivedType(tag: DW_TAG_member, name: "n", scope: !6, file: !3, line: 3, baseType: !11, size: 3, offset: 2, flags: DIFlagBitField, extraData: i64 0)
!11 = !DIDerivedType(tag: DW_TAG_typedef, name: "__int", file: !3, line: 2, baseType: !12)
!12 = !DIDerivedType(tag: DW_TAG_typedef, name: "_int", file: !3, line: 1, baseType: !13)
!13 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!14 = !DIDerivedType(tag: DW_TAG_member, name: "p", scope: !6, file: !3, line: 3, baseType: !9, size: 8, offset: 8)
!15 = !{i32 2, !"Dwarf Version", i32 4}
!16 = !{i32 2, !"Debug Info Version", i32 3}
!17 = !{i32 1, !"wchar_size", i32 4}
!18 = !{!"clang version 8.0.0 (trunk 345296) (llvm/trunk 345297)"}
