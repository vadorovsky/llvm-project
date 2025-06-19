; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s

; Source code:
;   #define __tag(x) __attribute__((btf_decl_tag(x)))
;
;   extern void foo(int x __tag("x_tag"), int y __tag("y_tag")) __tag("foo_tag");
;
;   void root(void) {
;     foo(0, 0);
;   }
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm test.c


; Function Attrs: nounwind
define dso_local void @root() local_unnamed_addr #0 !dbg !7 {
entry:
  tail call void @foo(i32 noundef 0, i32 noundef 0) #2, !dbg !12
  ret void, !dbg !13
}

declare !dbg !14 dso_local void @foo(i32 noundef, i32 noundef) local_unnamed_addr #1

attributes #0 = { nounwind "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #1 = { "frame-pointer"="all" "no-trapping-math"="true" "stack-protector-buffer-size"="8" }
attributes #2 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5}
!llvm.ident = !{!6}

; CHECK-BTF:             [1] FUNC_PROTO '(anon)' ret_type_id=0 vlen=0
; CHECK-BTF-NEXT:        [2] FUNC 'root' type_id=1 linkage=global
; CHECK-BTF-NEXT:        [3] FUNC_PROTO '(anon)' ret_type_id=0 vlen=2
; CHECK-BTF-NEXT:                '(anon)' type_id=4
; CHECK-BTF-NEXT:                '(anon)' type_id=4
; CHECK-BTF-NEXT:        [4] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [5] FUNC 'foo' type_id=3 linkage=extern
; CHECK-BTF-NEXT:        [6] DECL_TAG 'x_tag' type_id=5 component_idx=0
; CHECK-BTF-NEXT:        [7] DECL_TAG 'y_tag' type_id=5 component_idx=1
; CHECK-BTF-NEXT:        [8] DECL_TAG 'foo_tag' type_id=5 component_idx=-1

!0 = distinct !DICompileUnit(language: DW_LANG_C11, file: !1, producer: "clang version 16.0.0 (https://github.com/llvm/llvm-project.git 603e8490729e477680f0bc8284e136ceeb66e7f4)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "fake-file-name.c", directory: "fake-directory", checksumkind: CSK_MD5, checksum: "00000000000000000000000000000000")
!2 = !{i32 7, !"Dwarf Version", i32 5}
!3 = !{i32 2, !"Debug Info Version", i32 3}
!4 = !{i32 1, !"wchar_size", i32 4}
!5 = !{i32 7, !"frame-pointer", i32 2}
!6 = !{!"clang version 16.0.0 (https://github.com/llvm/llvm-project.git 603e8490729e477680f0bc8284e136ceeb66e7f4)"}
!7 = distinct !DISubprogram(name: "root", scope: !8, file: !8, line: 5, type: !9, scopeLine: 5, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !11)
!8 = !DIFile(filename: "fake-file-name.c", directory: "fake-directory", checksumkind: CSK_MD5, checksum: "00000000000000000000000000000000")
!9 = !DISubroutineType(types: !10)
!10 = !{null}
!11 = !{}
!12 = !DILocation(line: 6, column: 3, scope: !7)
!13 = !DILocation(line: 7, column: 1, scope: !7)
!14 = !DISubprogram(name: "foo", scope: !8, file: !8, line: 3, type: !15, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !18, annotations: !25)
!15 = !DISubroutineType(types: !16)
!16 = !{null, !17, !17}
!17 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!18 = !{!19, !22}
!19 = !DILocalVariable(name: "x", arg: 1, scope: !14, file: !8, line: 3, type: !17, annotations: !20)
!20 = !{!21}
!21 = !{!"btf_decl_tag", !"x_tag"}
!22 = !DILocalVariable(name: "y", arg: 2, scope: !14, file: !8, line: 3, type: !17, annotations: !23)
!23 = !{!24}
!24 = !{!"btf_decl_tag", !"y_tag"}
!25 = !{!26}
!26 = !{!"btf_decl_tag", !"foo_tag"}
