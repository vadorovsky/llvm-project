; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; Source:
;   struct tt;
;   struct s1 { const struct tt *mp; };
;   int test1(struct s1 *arg)
;   {
;     return  0;
;   }
;
;   struct tt { int m1; int m2; };
;   struct s2 { const struct tt m3; };
;   int test2(struct s2 *arg)
;   {
;     return arg->m3.m1;
;   }
; Compilation flags:
;   clang -target bpf -O2 -g -S -emit-llvm t.c

%struct.s1 = type { ptr }
%struct.tt = type { i32, i32 }
%struct.s2 = type { %struct.tt }

; Function Attrs: norecurse nounwind readnone
define dso_local i32 @test1(ptr nocapture readnone %arg) local_unnamed_addr #0 !dbg !7 {
entry:
  call void @llvm.dbg.value(metadata ptr %arg, metadata !22, metadata !DIExpression()), !dbg !23
  ret i32 0, !dbg !24
}

; Function Attrs: norecurse nounwind readonly
define dso_local i32 @test2(ptr nocapture readonly %arg) local_unnamed_addr #1 !dbg !25 {
entry:
  call void @llvm.dbg.value(metadata ptr %arg, metadata !33, metadata !DIExpression()), !dbg !34
  %0 = load i32, ptr %arg, align 4, !dbg !35, !tbaa !36
  ret i32 %0, !dbg !42
}

; CHECK-BTF:             [1] PTR '(anon)' type_id=2
; CHECK-BTF-NEXT:        [2] STRUCT 's1' size=8 vlen=1
; CHECK-BTF-NEXT:                'mp' type_id=3 bits_offset=0
; CHECK-BTF-NEXT:        [3] PTR '(anon)' type_id=4
; CHECK-BTF-NEXT:        [4] CONST '(anon)' type_id=10
; CHECK-BTF-NEXT:        [5] FUNC_PROTO '(anon)' ret_type_id=6 vlen=1
; CHECK-BTF-NEXT:                'arg' type_id=1
; CHECK-BTF-NEXT:        [6] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [7] FUNC 'test1' type_id=5 linkage=global
; CHECK-BTF-NEXT:        [8] PTR '(anon)' type_id=9
; CHECK-BTF-NEXT:        [9] STRUCT 's2' size=8 vlen=1
; CHECK-BTF-NEXT:                'm3' type_id=4 bits_offset=0
; CHECK-BTF-NEXT:        [10] STRUCT 'tt' size=8 vlen=2
; CHECK-BTF-NEXT:                'm1' type_id=6 bits_offset=0
; CHECK-BTF-NEXT:                'm2' type_id=6 bits_offset=32
; CHECK-BTF-NEXT:        [11] FUNC_PROTO '(anon)' ret_type_id=6 vlen=1
; CHECK-BTF-NEXT:                'arg' type_id=8
; CHECK-BTF-NEXT:        [12] FUNC 'test2' type_id=11 linkage=global

; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

attributes #0 = { norecurse nounwind readnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { norecurse nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 11.0.0 (https://github.com/llvm/llvm-project.git 7cfd267c518aba226b34b7fbfe8db70000b22053)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "t.c", directory: "/tmp/home/yhs/work/tests/btf")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 11.0.0 (https://github.com/llvm/llvm-project.git 7cfd267c518aba226b34b7fbfe8db70000b22053)"}
!7 = distinct !DISubprogram(name: "test1", scope: !1, file: !1, line: 3, type: !8, scopeLine: 4, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !21)
!8 = !DISubroutineType(types: !9)
!9 = !{!10, !11}
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !12, size: 64)
!12 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "s1", file: !1, line: 2, size: 64, elements: !13)
!13 = !{!14}
!14 = !DIDerivedType(tag: DW_TAG_member, name: "mp", scope: !12, file: !1, line: 2, baseType: !15, size: 64)
!15 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !16, size: 64)
!16 = !DIDerivedType(tag: DW_TAG_const_type, baseType: !17)
!17 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "tt", file: !1, line: 8, size: 64, elements: !18)
!18 = !{!19, !20}
!19 = !DIDerivedType(tag: DW_TAG_member, name: "m1", scope: !17, file: !1, line: 8, baseType: !10, size: 32)
!20 = !DIDerivedType(tag: DW_TAG_member, name: "m2", scope: !17, file: !1, line: 8, baseType: !10, size: 32, offset: 32)
!21 = !{!22}
!22 = !DILocalVariable(name: "arg", arg: 1, scope: !7, file: !1, line: 3, type: !11)
!23 = !DILocation(line: 0, scope: !7)
!24 = !DILocation(line: 5, column: 3, scope: !7)
!25 = distinct !DISubprogram(name: "test2", scope: !1, file: !1, line: 10, type: !26, scopeLine: 11, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !32)
!26 = !DISubroutineType(types: !27)
!27 = !{!10, !28}
!28 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !29, size: 64)
!29 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "s2", file: !1, line: 9, size: 64, elements: !30)
!30 = !{!31}
!31 = !DIDerivedType(tag: DW_TAG_member, name: "m3", scope: !29, file: !1, line: 9, baseType: !16, size: 64)
!32 = !{!33}
!33 = !DILocalVariable(name: "arg", arg: 1, scope: !25, file: !1, line: 10, type: !28)
!34 = !DILocation(line: 0, scope: !25)
!35 = !DILocation(line: 12, column: 18, scope: !25)
!36 = !{!37, !39, i64 0}
!37 = !{!"s2", !38, i64 0}
!38 = !{!"tt", !39, i64 0, !39, i64 4}
!39 = !{!"int", !40, i64 0}
!40 = !{!"omnipotent char", !41, i64 0}
!41 = !{!"Simple C/C++ TBAA"}
!42 = !DILocation(line: 12, column: 3, scope: !25)
