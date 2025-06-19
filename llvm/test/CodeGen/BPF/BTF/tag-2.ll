; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s

; Source code:
;   #define __tag1 __attribute__((btf_decl_tag("tag1")))
;   #define __tag2 __attribute__((btf_decl_tag("tag2")))
;   extern int bar(int a1, int a2) __tag1 __tag2;
;   int __tag1 foo(int arg1, int *arg2 __tag1) {
; ;   return arg1 + *arg2 + bar(arg1, arg1 + 1);
;   }
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm t.c

; Function Attrs: nounwind
define dso_local i32 @foo(i32 %arg1, ptr nocapture readonly %arg2) local_unnamed_addr #0 !dbg !8 {
entry:
  call void @llvm.dbg.value(metadata i32 %arg1, metadata !14, metadata !DIExpression()), !dbg !18
  call void @llvm.dbg.value(metadata ptr %arg2, metadata !15, metadata !DIExpression()), !dbg !18
  %0 = load i32, ptr %arg2, align 4, !dbg !19, !tbaa !20
  %add = add nsw i32 %0, %arg1, !dbg !24
  %add1 = add nsw i32 %arg1, 1, !dbg !25
  %call = tail call i32 @bar(i32 %arg1, i32 %add1) #3, !dbg !26
  %add2 = add nsw i32 %add, %call, !dbg !27
  ret i32 %add2, !dbg !28
}

declare !dbg !29 dso_local i32 @bar(i32, i32) local_unnamed_addr #1

; Function Attrs: nofree nosync nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

attributes #0 = { nounwind "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #2 = { nofree nosync nounwind readnone speculatable willreturn }
attributes #3 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!3, !4, !5, !6}
!llvm.ident = !{!7}

; CHECK-BTF:             [1] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [2] PTR '(anon)' type_id=1
; CHECK-BTF-NEXT:        [3] FUNC_PROTO '(anon)' ret_type_id=1 vlen=2
; CHECK-BTF-NEXT:                'arg1' type_id=1
; CHECK-BTF-NEXT:                'arg2' type_id=2
; CHECK-BTF-NEXT:        [4] FUNC 'foo' type_id=3 linkage=global
; CHECK-BTF-NEXT:        [5] DECL_TAG 'tag1' type_id=4 component_idx=1
; CHECK-BTF-NEXT:        [6] DECL_TAG 'tag1' type_id=4 component_idx=-1
; CHECK-BTF-NEXT:        [7] FUNC_PROTO '(anon)' ret_type_id=1 vlen=2
; CHECK-BTF-NEXT:                '(anon)' type_id=1
; CHECK-BTF-NEXT:                '(anon)' type_id=1
; CHECK-BTF-NEXT:        [8] FUNC 'bar' type_id=7 linkage=extern
; CHECK-BTF-NEXT:        [9] DECL_TAG 'tag1' type_id=8 component_idx=-1
; CHECK-BTF-NEXT:        [10] DECL_TAG 'tag2' type_id=8 component_idx=-1

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 14.0.0 (https://github.com/llvm/llvm-project.git 4be11596b26383c6666f471f07463a3f79e11964)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "t.c", directory: "/tmp/home/yhs/work/tests/llvm/btf_tag")
!2 = !{}
!3 = !{i32 7, !"Dwarf Version", i32 4}
!4 = !{i32 2, !"Debug Info Version", i32 3}
!5 = !{i32 1, !"wchar_size", i32 4}
!6 = !{i32 7, !"frame-pointer", i32 2}
!7 = !{!"clang version 14.0.0 (https://github.com/llvm/llvm-project.git 4be11596b26383c6666f471f07463a3f79e11964)"}
!8 = distinct !DISubprogram(name: "foo", scope: !1, file: !1, line: 4, type: !9, scopeLine: 4, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !13, annotations: !16)
!9 = !DISubroutineType(types: !10)
!10 = !{!11, !11, !12}
!11 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!12 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: !11, size: 64)
!13 = !{!14, !15}
!14 = !DILocalVariable(name: "arg1", arg: 1, scope: !8, file: !1, line: 4, type: !11)
!15 = !DILocalVariable(name: "arg2", arg: 2, scope: !8, file: !1, line: 4, type: !12, annotations: !16)
!16 = !{!17}
!17 = !{!"btf_decl_tag", !"tag1"}
!18 = !DILocation(line: 0, scope: !8)
!19 = !DILocation(line: 5, column: 17, scope: !8)
!20 = !{!21, !21, i64 0}
!21 = !{!"int", !22, i64 0}
!22 = !{!"omnipotent char", !23, i64 0}
!23 = !{!"Simple C/C++ TBAA"}
!24 = !DILocation(line: 5, column: 15, scope: !8)
!25 = !DILocation(line: 5, column: 40, scope: !8)
!26 = !DILocation(line: 5, column: 25, scope: !8)
!27 = !DILocation(line: 5, column: 23, scope: !8)
!28 = !DILocation(line: 5, column: 3, scope: !8)
!29 = !DISubprogram(name: "bar", scope: !1, file: !1, line: 3, type: !30, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !2, annotations: !32)
!30 = !DISubroutineType(types: !31)
!31 = !{!11, !11, !11}
!32 = !{!17, !33}
!33 = !{!"btf_decl_tag", !"tag2"}
