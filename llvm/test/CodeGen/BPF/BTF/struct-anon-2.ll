; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
;
; Source:
;   struct s1 {
;     struct { int A1; } a1;
;     struct ptr b1;
;   };
;   int f1(struct s1 *s1) { return 0; }
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm t.c

%struct.s1 = type { %struct.anon, ptr }
%struct.anon = type { i32 }
%struct.anon.0 = type { i64 }

; Function Attrs: norecurse nounwind readnone
define dso_local i32 @f1(ptr nocapture readnone %s1) local_unnamed_addr #0 !dbg !7 {
entry:
  call void @llvm.dbg.value(metadata ptr %s1, metadata !25, metadata !DIExpression()), !dbg !26
  ret i32 0, !dbg !27
}

; CHECK-BTF:             [1] PTR '(anon)' type_id=2
; CHECK-BTF-NEXT:        [2] STRUCT 's1' size=16 vlen=2
; CHECK-BTF-NEXT:                'a1' type_id=3 bits_offset=0
; CHECK-BTF-NEXT:                'b1' type_id=5 bits_offset=64
; CHECK-BTF-NEXT:        [3] STRUCT '(anon)' size=4 vlen=1
; CHECK-BTF-NEXT:                'A1' type_id=4 bits_offset=0
; CHECK-BTF-NEXT:        [4] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [5] PTR '(anon)' type_id=6
; CHECK-BTF-NEXT:        [6] STRUCT '(anon)' size=8 vlen=1
; CHECK-BTF-NEXT:                'B1' type_id=7 bits_offset=0
; CHECK-BTF-NEXT:        [7] INT 'long int' size=8 bits_offset=0 nr_bits=64 encoding=SIGNED
; CHECK-BTF-NEXT:        [8] FUNC_PROTO '(anon)' ret_type_id=4 vlen=1
; CHECK-BTF-NEXT:                's1' type_id=1
; CHECK-BTF-NEXT:        [9] FUNC 'f1' type_id=8 linkage=global


; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #1

attributes #0 = { norecurse nounwind readnone "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5}
!llvm.ident = !{!6}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 11.0.0 (https://github.com/llvm/llvm-project.git ef36f5143d83897cc6f59ff918769d29ad5a0612)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "t.c", directory: "/tmp/home/yhs/btf/tmp")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{!"clang version 11.0.0 (https://github.com/llvm/llvm-project.git ef36f5143d83897cc6f59ff918769d29ad5a0612)"}
!7 = distinct !DISubprogram(name: "f1", scope: !1, file: !1, line: 5, type: !8, scopeLine: 5, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !24)
!8 = !DISubroutineType(types: !9)
!9 = !{!10, !11}
!10 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!11 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !12, size: 64)
!12 = distinct !DICompositeType(tag: DW_TAG_structure_type, name: "s1", file: !1, line: 1, size: 128, elements: !13)
!13 = !{!14, !18}
!14 = !DIDerivedType(tag: DW_TAG_member, name: "a1", scope: !12, file: !1, line: 2, baseType: !15, size: 32)
!15 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !12, file: !1, line: 2, size: 32, elements: !16)
!16 = !{!17}
!17 = !DIDerivedType(tag: DW_TAG_member, name: "A1", scope: !15, file: !1, line: 2, baseType: !10, size: 32)
!18 = !DIDerivedType(tag: DW_TAG_member, name: "b1", scope: !12, file: !1, line: 3, baseType: !19, size: 64, offset: 64)
!19 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !20, size: 64)
!20 = distinct !DICompositeType(tag: DW_TAG_structure_type, scope: !12, file: !1, line: 3, size: 64, elements: !21)
!21 = !{!22}
!22 = !DIDerivedType(tag: DW_TAG_member, name: "B1", scope: !20, file: !1, line: 3, baseType: !23, size: 64)
!23 = !DIBasicType(name: "long int", size: 64, encoding: DW_ATE_signed)
!24 = !{!25}
!25 = !DILocalVariable(name: "s1", arg: 1, scope: !7, file: !1, line: 5, type: !11)
!26 = !DILocation(line: 0, scope: !7)
!27 = !DILocation(line: 5, column: 25, scope: !7)
