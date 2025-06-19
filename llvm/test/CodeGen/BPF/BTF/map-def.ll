; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s

; Source code:
;   struct key_type {
;     int a;
;     int b;
;   };
;   struct map_type {
;     struct key_ptr key;
;     unsigned *value;
;   };
;   struct map_type __attribute__((section(".maps"))) hash_map;
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm t.c

%struct.map_type = type { ptr, ptr }
%struct.key_type = type { i32, i32 }

@hash_map = dso_local local_unnamed_addr global %struct.map_type zeroinitializer, section ".maps", align 8, !dbg !0

; CHECK-BTF:             [1] PTR '(anon)' type_id=2
; CHECK-BTF-NEXT:        [2] STRUCT 'key_type' size=8 vlen=2
; CHECK-BTF-NEXT:                'a' type_id=3 bits_offset=0
; CHECK-BTF-NEXT:                'b' type_id=3 bits_offset=32
; CHECK-BTF-NEXT:        [3] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [4] PTR '(anon)' type_id=5
; CHECK-BTF-NEXT:        [5] INT 'unsigned int' size=4 bits_offset=0 nr_bits=32 encoding=(none)
; CHECK-BTF-NEXT:        [6] STRUCT 'map_type' size=16 vlen=2
; CHECK-BTF-NEXT:                'key' type_id=1 bits_offset=0
; CHECK-BTF-NEXT:                'value' type_id=4 bits_offset=64
; CHECK-BTF-NEXT:        [7] VAR 'hash_map' type_id=6, linkage=global
; CHECK-BTF-NEXT:        [8] DATASEC '.maps' size=0 vlen=1
; CHECK-BTF-NEXT:                type_id=7 offset=0 size=16

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!18, !19, !20}
!llvm.ident = !{!21}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "hash_map", scope: !2, file: !3, line: 9, type: !6, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 9.0.0 (trunk 364157) (llvm/trunk 364156)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !5, nameTableKind: None)
!3 = !DIFile(filename: "t.c", directory: "/tmp/home/yhs/work/tests/llvm")
!4 = !{}
!5 = !{!0}
!6 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "map_type", file: !3, line: 5, size: 128, elements: !7)
!7 = !{!8, !15}
!8 = !DIDerivedType(tag: DW_TAG_member, name: "key", scope: !6, file: !3, line: 6, baseType: !9, size: 64)
!9 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !10, size: 64)
!10 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "key_type", file: !3, line: 1, size: 64, elements: !11)
!11 = !{!12, !14}
!12 = !DIDerivedType(tag: DW_TAG_member, name: "a", scope: !10, file: !3, line: 2, baseType: !13, size: 32)
!13 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!14 = !DIDerivedType(tag: DW_TAG_member, name: "b", scope: !10, file: !3, line: 3, baseType: !13, size: 32, offset: 32)
!15 = !DIDerivedType(tag: DW_TAG_member, name: "value", scope: !6, file: !3, line: 7, baseType: !16, size: 64, offset: 64)
!16 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !17, size: 64)
!17 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!18 = !{i32 2, !"Dwarf Version", i32 4}
!19 = !{i32 2, !"Debug Info Version", i32 3}
!20 = !{i32 1, !"wchar_size", i32 4}
!21 = !{!"clang version 9.0.0 (trunk 364157) (llvm/trunk 364156)"}
