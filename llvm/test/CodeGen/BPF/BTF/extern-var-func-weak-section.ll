; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
;
; Source code:
;   extern int global_func(char c) __attribute__((weak, section("abc")));
;   int test() {
;      return global_func(0);
;   }
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm test.c

; Function Attrs: nounwind
define dso_local i32 @test() local_unnamed_addr #0 !dbg !13 {
entry:
  %call = tail call i32 @global_func(i8 signext 0) #2, !dbg !16
  ret i32 %call, !dbg !17
}
declare !dbg !4 extern_weak dso_local i32 @global_func(i8 signext) local_unnamed_addr #1 section "abc"

; CHECK-BTF:             [1] FUNC_PROTO '(anon)' ret_type_id=2 vlen=0
; CHECK-BTF-NEXT:        [2] INT 'int' size=4 bits_offset=0 nr_bits=32 encoding=SIGNED
; CHECK-BTF-NEXT:        [3] FUNC 'test' type_id=1 linkage=global
; CHECK-BTF-NEXT:        [4] FUNC_PROTO '(anon)' ret_type_id=2 vlen=1
; CHECK-BTF-NEXT:                '(anon)' type_id=5
; CHECK-BTF-NEXT:        [5] INT 'char' size=1 bits_offset=0 nr_bits=8 encoding=SIGNED
; CHECK-BTF-NEXT:        [6] FUNC 'global_func' type_id=4 linkage=extern
; CHECK-BTF-NEXT:        [7] DATASEC 'abc' size=0 vlen=1
; CHECK-BTF-NEXT:                type_id=6 offset=0 size=0

attributes #0 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!9, !10, !11}
!llvm.ident = !{!12}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 10.0.0 (https://github.com/llvm/llvm-project.git 71a9518c93fe1dce9611c24bc707e5baf1f39f0d)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3, nameTableKind: None)
!1 = !DIFile(filename: "test.c", directory: "/tmp/home/yhs/work/tests/extern")
!2 = !{}
!3 = !{!4}
!4 = !DISubprogram(name: "global_func", scope: !1, file: !1, line: 1, type: !5, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !2)
!5 = !DISubroutineType(types: !6)
!6 = !{!7, !8}
!7 = !DIBasicType(name: "int", size: 32, encoding: DW_ATE_signed)
!8 = !DIBasicType(name: "char", size: 8, encoding: DW_ATE_signed_char)
!9 = !{i32 7, !"Dwarf Version", i32 4}
!10 = !{i32 2, !"Debug Info Version", i32 3}
!11 = !{i32 1, !"wchar_size", i32 4}
!12 = !{!"clang version 10.0.0 (https://github.com/llvm/llvm-project.git 71a9518c93fe1dce9611c24bc707e5baf1f39f0d)"}
!13 = distinct !DISubprogram(name: "test", scope: !1, file: !1, line: 2, type: !14, scopeLine: 2, flags: DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !2)
!14 = !DISubroutineType(types: !15)
!15 = !{!7}
!16 = !DILocation(line: 3, column: 11, scope: !13)
!17 = !DILocation(line: 3, column: 4, scope: !13)
