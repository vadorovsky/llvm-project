; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
;
; Source:
;   #define __tag1 __attribute__((btf_type_tag("tag1")))
;   #define __tag2 __attribute__((btf_type_tag("tag2")))
;   int __tag1 * __tag1 __tag2 *g;
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm test.c

@g = dso_local local_unnamed_addr global ptr null, align 8, !dbg !0

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!12, !13, !14, !15}
!llvm.ident = !{!16}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "g", scope: !2, file: !3, line: 3, type: !5, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 14.0.0 (https://github.com/llvm/llvm-project.git 077b2e0cf1e97c4d97ca5ceab3ec0192ed11c66e)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, globals: !4, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "test.c", directory: "/tmp/home/yhs/work/tests/llvm/btf_tag_type")
!4 = !{!0}
!5 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !6, size: 64, annotations: !10)
!6 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !7, size: 64, annotations: !8)
!7 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!8 = !{!9}
!9 = !{!"btf_type_tag", !"tag1"}
!10 = !{!9, !11}
!11 = !{!"btf_type_tag", !"tag2"}

; CHECK-BTF:             [1] TYPE_TAG 'tag1' type_id=5
; CHECK-BTF-NEXT:        [2] TYPE_TAG 'tag2' type_id=1
; CHECK-BTF-NEXT:        [3] PTR '(anon)' type_id=2
; CHECK-BTF-NEXT:        [4] TYPE_TAG 'tag1' type_id=6
; CHECK-BTF-NEXT:        [5] PTR '(anon)' type_id=4
; CHECK-BTF-NEXT:        [6] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [7] VAR 'g' type_id=3, linkage=global
; CHECK-BTF-NEXT:        [8] DATASEC '.bss' size=0 vlen=1
; CHECK-BTF-NEXT:                type_id=7 offset=0 size=8

!12 = !{i32 7, !"Dwarf Version", i32 4}
!13 = !{i32 2, !"Debug Info Version", i32 3}
!14 = !{i32 1, !"wchar_size", i32 4}
!15 = !{i32 7, !"frame-pointer", i32 2}
!16 = !{!"clang version 14.0.0 (https://github.com/llvm/llvm-project.git 077b2e0cf1e97c4d97ca5ceab3ec0192ed11c66e)"}
