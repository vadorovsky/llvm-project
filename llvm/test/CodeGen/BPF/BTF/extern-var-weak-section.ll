; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
;
; Source code:
;   extern int global_func(char c) __attribute__((weak, section("abc")));
;   extern char ch __attribute__((weak, section("abc")));
;   int test() {
;     return global_func(0) + ch;
;   }
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm test.c

@ch = extern_weak dso_local local_unnamed_addr global i8, section "abc", align 1, !dbg !0
; Function Attrs: nounwind
define dso_local i32 @test() local_unnamed_addr #0 !dbg !16 {
entry:
  %call = tail call i32 @global_func(i8 signext 0) #2, !dbg !19
  %0 = load i8, ptr @ch, align 1, !dbg !20, !tbaa !21
  %conv = sext i8 %0 to i32, !dbg !20
  %add = add nsw i32 %call, %conv, !dbg !24
  ret i32 %add, !dbg !25
}
declare !dbg !6 extern_weak dso_local i32 @global_func(i8 signext) local_unnamed_addr #1 section "abc"

; CHECK-BTF:             [1] FUNC_PROTO '(anon)' ret_type_id=2 vlen=0
; CHECK-BTF-NEXT:        [2] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [3] FUNC 'test' type_id=1 linkage=global
; CHECK-BTF-NEXT:        [4] FUNC_PROTO '(anon)' ret_type_id=2 vlen=1
; CHECK-BTF-NEXT:                '(anon)' type_id=5
; CHECK-BTF-NEXT:        [5] INT 'char' size=1 bits_offset=0 nr_bits=8 encoding=SIGNED
; CHECK-BTF-NEXT:        [6] FUNC 'global_func' type_id=4 linkage=extern
; CHECK-BTF-NEXT:        [7] VAR 'ch' type_id=5, linkage=extern
; CHECK-BTF-NEXT:        [8] DATASEC 'abc' size=0 vlen=2
; CHECK-BTF-NEXT:                type_id=6 offset=0 size=0
; CHECK-BTF-NEXT:                type_id=7 offset=0 size=1

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.dbg.cu = !{!2}
!llvm.module.flags = !{!12, !13, !14}
!llvm.ident = !{!15}

!0 = !DIGlobalVariableExpression(var: !1, expr: !DIExpression())
!1 = distinct !DIGlobalVariable(name: "ch", scope: !2, file: !3, line: 2, type: !10, isLocal: false, isDefinition: false)
!2 = distinct !DICompileUnit(language: DW_LANG_C99, file: !3, producer: "clang version 10.0.0 (https://github.com/llvm/llvm-project.git 71a9518c93fe1dce9611c24bc707e5baf1f39f0d)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !4, retainedTypes: !5, globals: !11, nameTableKind: None)
!3 = !DIFile(filename: "test.c", directory: "/tmp/home/yhs/work/tests/extern")
!4 = !{}
!5 = !{!6}
!6 = !DISubprogram(name: "global_func", scope: !3, file: !3, line: 1, type: !7, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !4)
!7 = !DISubroutineType(types: !8)
!8 = !{!9, !10}
!9 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!10 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!11 = !{!0}
!12 = !{i32 7, !"Dwarf Version", i32 4}
!13 = !{i32 2, !"Debug Info Version", i32 3}
!14 = !{i32 1, !"wchar_size", i32 4}
!15 = !{!"clang version 10.0.0 (https://github.com/llvm/llvm-project.git 71a9518c93fe1dce9611c24bc707e5baf1f39f0d)"}
!16 = distinct !DISubprogram(name: "test", scope: !3, file: !3, line: 3, type: !17, scopeLine: 3, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !2, retainedNodes: !4)
!17 = !DISubroutineType(types: !18)
!18 = !{!9}
!19 = !DILocation(line: 4, column: 10, scope: !16)
!20 = !DILocation(line: 4, column: 27, scope: !16)
!21 = !{!22, !22, i64 0}
!22 = !{!"omnipotent char", !23, i64 0}
!23 = !{!"Simple C/C++ TBAA"}
!24 = !DILocation(line: 4, column: 25, scope: !16)
!25 = !DILocation(line: 4, column: 3, scope: !16)
