; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s

; Source code:
;   enum t1 { A , B };
;   struct t2 { enum t1 m:2; enum t1 n; } a;
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm t.c

%struct.t2 = type { i8, i32 }

@a = common dso_local local_unnamed_addr global %struct.t2 zeroinitializer, align 4, !dbg !0

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!15, !16, !17}
!llvm.ident = !{!18}

; CHECK-BTF:             [1] STRUCT 't2' size=8 vlen=2
; CHECK-BTF-NEXT:                'm' type_id=2 bits_offset=0 bitfield_size=2
; CHECK-BTF-NEXT:                'n' type_id=2 bits_offset=32 bitfield_size=0
; CHECK-BTF-NEXT:        [2] ENUM 't1' encoding=UNSIGNED size=4 vlen=2
; CHECK-BTF-NEXT:                'A' val=0
; CHECK-BTF-NEXT:                'B' val=1

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "a", scope: !2, file: !3, line: 2, type: !11, isLocal: false, isDefinition: true)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 8.0.0 (trunk 344789) (llvm/trunk 344782)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, globals: !10, nameTableKind: None)
!3 = !DIFile(filename: "t.c", directory: "/home/yhs/tmp")
!4 = !{!5}
!5 = !DICompositeType(tag: DW_TAG_enumeration_type, name: "t1", file: !3, line: 1, baseType: !6, size: 32, elements: !7)
!6 = !DIBasicType(name: "unsigned int", size: 32, encoding: DW_ATE_unsigned)
!7 = !{!8, !9}
!8 = !DIEnumerator(name: "A", value: 0, isUnsigned: true)
!9 = !DIEnumerator(name: "B", value: 1, isUnsigned: true)
!10 = !{!0}
!11 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "t2", file: !3, line: 2, size: 64, elements: !12)
!12 = !{!13, !14}
!13 = !DIDerivedType(tag: DW_TAG_member, name: "m", scope: !11, file: !3, line: 2, baseType: !5, size: 2, flags: DIFlagBitField, extraData: i64 0)
!14 = !DIDerivedType(tag: DW_TAG_member, name: "n", scope: !11, file: !3, line: 2, baseType: !5, size: 32, offset: 32)
!15 = !{i32 2, !"Dwarf Version", i32 4}
!16 = !{i32 2, !"Debug Info Version", i32 3}
!17 = !{i32 1, !"wchar_size", i32 4}
!18 = !{!"clang version 8.0.0 (trunk 344789) (llvm/trunk 344782)"}
