; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s

; Source code:
;   struct s { int i; } __attribute__((aligned(16)));
;   struct s a;          // .bss
;   struct s b = { 0 };  // .bss
;   struct s c = { 1 };  // .data
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm test.c

%struct.s = type { i32, [12 x i8] }

@a = dso_local local_unnamed_addr global %struct.s zeroinitializer, align 16, !dbg !11
@b = dso_local local_unnamed_addr global %struct.s { i32 0, [12 x i8] undef }, align 16, !dbg !0
@c = dso_local local_unnamed_addr global %struct.s { i32 1, [12 x i8] undef }, align 16, !dbg !5

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!13, !14, !15, !16}
!llvm.ident = !{!17}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "b", scope: !2, file: !3, line: 3, type: !7, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C11, file: !3, producer: "clang version 16.0.0 (https://github.com/llvm/llvm-project.git 3191e8e19f1a7007ddd0e55cee60a51a058c99f5)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, globals: !4, splitDebugInlining: false, nameTableKind: None)
!3 = !DIFile(filename: "test.c", directory: "/home/eddy/work/tmp", checksumkind: CSK_MD5, checksum: "b9d0621d30812c09bd3c6894f89ff5e4")
!4 = !{!0, !5, !11}
!5 = !DIGlobalVariableExpression(var: !6, expr: !DIExpression())
!6 = distinct !DIGlobalVariable(name: "c", scope: !2, file: !3, line: 4, type: !7, isLocal: false, isDefinition: true)
!7 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "s", file: !3, line: 1, size: 128, align: 128, elements: !8)
!8 = !{!9}
!9 = !DIDerivedType(tag: DW_TAG_member, name: "i", scope: !7, file: !3, line: 1, baseType: !10, size: 32)
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !DIGlobalVariableExpression(var: !12, expr: !DIExpression())
!12 = distinct !DIGlobalVariable(name: "a", scope: !2, file: !3, line: 2, type: !7, isLocal: false, isDefinition: true)
!13 = !{i32 7, !"Dwarf Version", i32 5}
!14 = !{i32 2, !"Debug Info Version", i32 3}
!15 = !{i32 1, !"wchar_size", i32 4}
!16 = !{i32 7, !"frame-pointer", i32 2}
!17 = !{!"clang version 16.0.0 (https://github.com/llvm/llvm-project.git 3191e8e19f1a7007ddd0e55cee60a51a058c99f5)"}

; CHECK-BTF:      [1] STRUCT 's' size=16 vlen=1
; CHECK-BTF-NEXT:         'i' type_id=2 bits_offset=0
; CHECK-BTF-NEXT: [2] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT: [3] VAR 'a' type_id=1, linkage=global
; CHECK-BTF-NEXT: [4] VAR 'b' type_id=1, linkage=global
; CHECK-BTF-NEXT: [5] VAR 'c' type_id=1, linkage=global
; CHECK-BTF-NEXT: [6] DATASEC '.bss' size=0 vlen=2
; CHECK-BTF-NEXT:         type_id=3 offset=0 size=16
; CHECK-BTF-NEXT:         type_id=4 offset=0 size=16
; CHECK-BTF-NEXT: [7] DATASEC '.data' size=0 vlen=1
; CHECK-BTF-NEXT:         type_id=5 offset=0 size=16
