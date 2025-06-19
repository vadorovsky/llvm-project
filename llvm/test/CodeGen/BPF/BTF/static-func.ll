; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
;
; Source code:
;   extern int foo(void);
;   static __attribute__((noinline)) int test1() { return foo(); }
;   int test2() { return test1(); }
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm test.c

; Function Attrs: nounwind
define dso_local i32 @test2() local_unnamed_addr #0 !dbg !12 {
entry:
  %call = tail call fastcc i32 @test1(), !dbg !13
  ret i32 %call, !dbg !14
}
; Function Attrs: noinline nounwind
define internal fastcc i32 @test1() unnamed_addr #1 !dbg !15 {
entry:
  %call = tail call i32 @foo() #3, !dbg !16
  ret i32 %call, !dbg !17
}
declare !dbg !4 dso_local i32 @foo() local_unnamed_addr #2

; CHECK-BTF:             [1] FUNC_PROTO '(anon)' ret_type_id=2 vlen=0
; CHECK-BTF-NEXT:        [2] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [3] FUNC 'test2' type_id=1 linkage=global
; CHECK-BTF-NEXT:        [4] FUNC_PROTO '(anon)' ret_type_id=2 vlen=0
; CHECK-BTF-NEXT:        [5] FUNC 'test1' type_id=4 linkage=static
; CHECK-BTF-NEXT:        [6] FUNC_PROTO '(anon)' ret_type_id=2 vlen=0
; CHECK-BTF-NEXT:        [7] FUNC 'foo' type_id=6 linkage=extern

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { noinline nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!8, !9, !10}
!llvm.ident = !{!11}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 10.0.0 (https://github.com/llvm/llvm-project.git 000f95c4157aee07bd4ffc3f59ffdb6c7ecae4af)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "test.c", directory: "/tmp/home/yhs/work/tests/bugs")
!2 = !{}
!3 = !{!4}
!4 = !DISubprogram(name: "foo", scope: !1, file: !1, line: 1, type: !5, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !2)
!5 = !DISubroutineType(types: !6)
!6 = !{!7}
!7 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!8 = !{i32 7, !"Dwarf Version", i32 4}
!9 = !{i32 2, !"Debug Info Version", i32 3}
!10 = !{i32 1, !"wchar_size", i32 4}
!11 = !{!"clang version 10.0.0 (https://github.com/llvm/llvm-project.git 000f95c4157aee07bd4ffc3f59ffdb6c7ecae4af)"}
!12 = distinct !DISubprogram(name: "test2", scope: !1, file: !1, line: 3, type: !5, scopeLine: 3, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !2)
!13 = !DILocation(line: 3, column: 22, scope: !12)
!14 = !DILocation(line: 3, column: 15, scope: !12)
!15 = distinct !DISubprogram(name: "test1", scope: !1, file: !1, line: 2, type: !5, scopeLine: 2, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagLocalToUnit | DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !2)
!16 = !DILocation(line: 2, column: 55, scope: !15)
!17 = !DILocation(line: 2, column: 48, scope: !15)
