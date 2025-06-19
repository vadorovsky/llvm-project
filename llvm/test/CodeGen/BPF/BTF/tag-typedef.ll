; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s

; Source code:
;   #define __tag1 __attribute__((btf_decl_tag("tag1")))
;   typedef struct { int a; } __s __tag1;
;   typedef unsigned * __u __tag1;
;   __s a;
;   __u u;
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm t.c

%struct.__s = type { i32 }

@a = dso_local local_unnamed_addr global %struct.__s zeroinitializer, align 4, !dbg !0
@u = dso_local local_unnamed_addr global ptr null, align 8, !dbg !5

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!17, !18, !19, !20}
!llvm.ident = !{!21}

; CHECK-BTF:             [1] TYPEDEF '__s' type_id=3
; CHECK-BTF-NEXT:        [2] DECL_TAG 'tag1' type_id=1 component_idx=-1
; CHECK-BTF-NEXT:        [3] STRUCT '(anon)' size=4 vlen=1
; CHECK-BTF-NEXT:                'a' type_id=4 bits_offset=0
; CHECK-BTF-NEXT:        [4] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [5] VAR 'a' type_id=1, linkage=global
; CHECK-BTF-NEXT:        [6] TYPEDEF '__u' type_id=8
; CHECK-BTF-NEXT:        [7] DECL_TAG 'tag1' type_id=6 component_idx=-1
; CHECK-BTF-NEXT:        [8] PTR '(anon)' type_id=9
; CHECK-BTF-NEXT:        [9] INT 'unsigned int' size=4 bits_offset=0 nr_bits=32 encoding=(none)
; CHECK-BTF-NEXT:        [10] VAR 'u' type_id=6, linkage=global
; CHECK-BTF-NEXT:        [11] DATASEC '.bss' size=0 vlen=2
; CHECK-BTF-NEXT:                type_id=5 offset=0 size=4
; CHECK-BTF-NEXT:                type_id=10 offset=0 size=8

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "a", scope: !2, file: !3, line: 4, type: !12, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 14.0.0 (https://github.com/llvm/llvm-project.git 219b26fbcd70273ddfd4ead9387f7c69b7eb4570)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, globals: !4, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "t.c", directory: "/tmp/home/yhs/work/tests/llvm/btf_tag")
!4 = !{!0, !5}
!5 = !DIGlobalVariableExpression(var: !6, expr: !DIExpression())
!6 = distinct !DIGlobalVariable(name: "u", scope: !2, file: !3, line: 5, type: !7, isLocal: false, isDefinition: true)
!7 = !DIDerivedType(tag: DW_TAG_typedef, name: "__u", file: !3, line: 3, baseType: !8, annotations: !10)
!8 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !9, size: 64)
!9 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!10 = !{!11}
!11 = !{!"btf_decl_tag", !"tag1"}
!12 = !DIDerivedType(tag: DW_TAG_typedef, name: "__s", file: !3, line: 2, baseType: !13, annotations: !10)
!13 = distinct !DICompositeType(tag: DW_TAG_structure_type, file: !3, line: 2, size: 32, elements: !14)
!14 = !{!15}
!15 = !DIDerivedType(tag: DW_TAG_member, name: "a", scope: !13, file: !3, line: 2, baseType: !16, size: 32)
!16 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!17 = !{i32 7, !"Dwarf Version", i32 4}
!18 = !{i32 2, !"Debug Info Version", i32 3}
!19 = !{i32 1, !"wchar_size", i32 4}
!20 = !{i32 7, !"frame-pointer", i32 2}
!21 = !{!"clang version 14.0.0 (https://github.com/llvm/llvm-project.git 219b26fbcd70273ddfd4ead9387f7c69b7eb4570)"}
