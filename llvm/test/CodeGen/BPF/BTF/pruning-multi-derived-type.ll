; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; Source:
;   struct t1 {
;     int a;
;   };
;   struct t2 {
;     const struct t1 * const a;
;   };
;   int foo(struct t2 *arg) { return 0; }
;   int bar(const struct t1 * const arg) { return 0; }
; Compilation flags:
;   clang -target bpf -O2 -g -S -emit-llvm t.c

%struct.t2 = type { ptr }
%struct.t1 = type { i32 }

; Function Attrs: mustprogress nofree norecurse nosync nounwind readnone willreturn
define dso_local i32 @foo(ptr nocapture noundef readnone %arg) local_unnamed_addr #0 !dbg !7 {
entry:
  call void @llvm.dbg.value(metadata ptr %arg, metadata !22, metadata !DIExpression()), !dbg !23
  ret i32 0, !dbg !24
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind readnone willreturn
define dso_local i32 @bar(ptr nocapture noundef readnone %arg) local_unnamed_addr #0 !dbg !25 {
entry:
  call void @llvm.dbg.value(metadata ptr %arg, metadata !29, metadata !DIExpression()), !dbg !30
  ret i32 0, !dbg !31
}

; CHECK-BTF:             [1] PTR '(anon)' type_id=2
; CHECK-BTF-NEXT:        [2] STRUCT 't2' size=8 vlen=1
; CHECK-BTF-NEXT:                'a' type_id=3 bits_offset=0
; CHECK-BTF-NEXT:        [3] CONST '(anon)' type_id=4
; CHECK-BTF-NEXT:        [4] PTR '(anon)' type_id=5
; CHECK-BTF-NEXT:        [5] CONST '(anon)' type_id=9
; CHECK-BTF-NEXT:        [6] FUNC_PROTO '(anon)' ret_type_id=7 vlen=1
; CHECK-BTF-NEXT:                'arg' type_id=1
; CHECK-BTF-NEXT:        [7] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [8] FUNC 'foo' type_id=6 linkage=global
; CHECK-BTF-NEXT:        [9] STRUCT 't1' size=4 vlen=1
; CHECK-BTF-NEXT:                'a' type_id=7 bits_offset=0
; CHECK-BTF-NEXT:        [10] FUNC_PROTO '(anon)' ret_type_id=7 vlen=1
; CHECK-BTF-NEXT:                'arg' type_id=3
; CHECK-BTF-NEXT:        [11] FUNC 'bar' type_id=10 linkage=global

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #1

attributes #0 = { mustprogress nofree norecurse nosync nounwind readnone willreturn "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { nofree nosync nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 15.0.0 (https://github.com/llvm/llvm-project.git c34c8afcb85ae9142d0f783bb899c464e8bd2356)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "test.c", directory: "/tmp/home/yhs/work/tests/llvm/btf_ptr", checksumkind: CSK_MD5, checksum: "d43a0541e830263021772349589e47a5")
!2 = !{i32 7, !"Dwarf Version", i32 5}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{i32 7, !"frame-pointer", i32 2}
!6 = !{!"clang version 15.0.0 (https://github.com/llvm/llvm-project.git c34c8afcb85ae9142d0f783bb899c464e8bd2356)"}
!7 = distinct !DISubprogram(name: "foo", scope: !1, file: !1, line: 7, type: !8, scopeLine: 7, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !21)
!8 = !DISubroutineType(types: !9)
!9 = !{!10, !11}
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !12, size: 64)
!12 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "t2", file: !1, line: 4, size: 64, elements: !13)
!13 = !{!14}
!14 = !DIDerivedType(tag: DW_TAG_member, name: "a", scope: !12, file: !1, line: 5, baseType: !15, size: 64)
!15 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !16)
!16 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !17, size: 64)
!17 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !18)
!18 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "t1", file: !1, line: 1, size: 32, elements: !19)
!19 = !{!20}
!20 = !DIDerivedType(tag: DW_TAG_member, name: "a", scope: !18, file: !1, line: 2, baseType: !10, size: 32)
!21 = !{!22}
!22 = !DILocalVariable(name: "arg", arg: 1, scope: !7, file: !1, line: 7, type: !11)
!23 = !DILocation(line: 0, scope: !7)
!24 = !DILocation(line: 7, column: 27, scope: !7)
!25 = distinct !DISubprogram(name: "bar", scope: !1, file: !1, line: 8, type: !26, scopeLine: 8, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !28)
!26 = !DISubroutineType(types: !27)
!27 = !{!10, !15}
!28 = !{!29}
!29 = !DILocalVariable(name: "arg", arg: 1, scope: !25, file: !1, line: 8, type: !15)
!30 = !DILocation(line: 0, scope: !25)
!31 = !DILocation(line: 8, column: 40, scope: !25)
