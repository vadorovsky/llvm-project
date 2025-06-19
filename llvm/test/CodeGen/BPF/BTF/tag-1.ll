; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s

; Source code:
;   #define __tag1 __attribute__((btf_decl_tag("tag1")))
;   #define __tag2 __attribute__((btf_decl_tag("tag2")))
;   struct t1 {
;     int a1;
;     int a2 __tag1 __tag2;
;   } __tag1 __tag2;
;   struct t1 g1 __tag1 __tag2;
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm t.c

%struct.t1 = type { i32, i32 }

@g1 = dso_local local_unnamed_addr global %struct.t1 zeroinitializer, align 4, !dbg !0

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!14, !15, !16, !17}
!llvm.ident = !{!18}

; CHECK-BTF:             [1] STRUCT 't1' size=8 vlen=2
; CHECK-BTF-NEXT:                'a1' type_id=4 bits_offset=0
; CHECK-BTF-NEXT:                'a2' type_id=4 bits_offset=32
; CHECK-BTF-NEXT:        [2] DECL_TAG 'tag1' type_id=1 component_idx=-1
; CHECK-BTF-NEXT:        [3] DECL_TAG 'tag2' type_id=1 component_idx=-1
; CHECK-BTF-NEXT:        [4] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [5] DECL_TAG 'tag1' type_id=1 component_idx=1
; CHECK-BTF-NEXT:        [6] DECL_TAG 'tag2' type_id=1 component_idx=1
; CHECK-BTF-NEXT:        [7] VAR 'g1' type_id=1, linkage=global
; CHECK-BTF-NEXT:        [8] DECL_TAG 'tag1' type_id=7 component_idx=-1
; CHECK-BTF-NEXT:        [9] DECL_TAG 'tag2' type_id=7 component_idx=-1
; CHECK-BTF-NEXT:        [10] DATASEC '.bss' size=0 vlen=1
; CHECK-BTF-NEXT:                type_id=7 offset=0 size=8

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "g1", scope: !2, file: !3, line: 7, type: !6, isLocal: false, isDefinition: true, annotations: !11)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 13.0.0 (https://github.com/llvm/llvm-project.git 825661b8e31d0b29d78178df1e518949dfec9f9a)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !5, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "t.c", directory: "/tmp/home/yhs/work/tests/llvm/btf_tag")
!4 = !{}
!5 = !{!0}
!6 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "t1", file: !3, line: 3, size: 64, elements: !7, annotations: !11)
!7 = !{!8, !10}
!8 = !DIDerivedType(tag: DW_TAG_member, name: "a1", scope: !6, file: !3, line: 4, baseType: !9, size: 32)
!9 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!10 = !DIDerivedType(tag: DW_TAG_member, name: "a2", scope: !6, file: !3, line: 5, baseType: !9, size: 32, offset: 32, annotations: !11)
!11 = !{!12, !13}
!12 = !{!"btf_decl_tag", !"tag1"}
!13 = !{!"btf_decl_tag", !"tag2"}
!14 = !{i32 7, !"Dwarf Version", i32 4}
!15 = !{i32 2, !"Debug Info Version", i32 3}
!16 = !{i32 1, !"wchar_size", i32 4}
!17 = !{i32 7, !"frame-pointer", i32 2}
!18 = !{!"clang version 13.0.0 (https://github.com/llvm/llvm-project.git 825661b8e31d0b29d78178df1e518949dfec9f9a)"}
