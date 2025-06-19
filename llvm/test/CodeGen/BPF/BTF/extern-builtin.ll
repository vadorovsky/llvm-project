; RUN: llc -mtriple=bpfel -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; RUN: llc -mtriple=bpfeb -filetype=obj -o %t1 %s
; RUN: llvm-objcopy --dump-section='.BTF'=%t2 %t1
; RUN: %python %p/print_btf.py %t2 | FileCheck -check-prefixes=CHECK-BTF %s
; Source code:
;   unsigned long long load_byte(ptr skb,
;       unsigned long long off) asm("llvm.bpf.load.byte");
;   unsigned long long test(ptr skb) {
;     return load_byte(skb, 10);
;   }
; Compilation flag:
;   clang -target bpf -O2 -g -S -emit-llvm test.c

; Function Attrs: nounwind readonly
define dso_local i64 @test(ptr readonly %skb) local_unnamed_addr #0 !dbg !13 {
entry:
  call void @llvm.dbg.value(metadata ptr %skb, metadata !17, metadata !DIExpression()), !dbg !18
  %call = tail call i64 @llvm.bpf.load.byte(ptr %skb, i64 10), !dbg !19
  ret i64 %call, !dbg !20
}

; CHECK-BTF:             [1] PTR '(anon)' type_id=0
; CHECK-BTF-NEXT:        [2] FUNC_PROTO '(anon)' ret_type_id=3 vlen=1
; CHECK-BTF-NEXT:                'skb' type_id=1
; CHECK-BTF-NEXT:        [3] INT 'long long unsigned int' size=8 bits_offset=0 nr_bits=64 encoding=(none)
; CHECK-BTF-NEXT:        [4] FUNC 'test' type_id=2 linkage=global

; Function Attrs: nounwind readonly
declare !dbg !4 i64 @llvm.bpf.load.byte(ptr, i64) #1
; Function Attrs: nounwind readnone speculatable willreturn
declare void @llvm.dbg.value(metadata, metadata, metadata) #2

attributes #0 = { nounwind readonly "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind readonly }
attributes #2 = { nounwind readnone speculatable willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!9, !10, !11}
!llvm.ident = !{!12}

!0 = distinct !DICompileUnit(language: DW_LANG_C99, file: !1, producer: "clang version 10.0.0 (https://github.com/llvm/llvm-project.git 907019d835895443b198afcd992c42c9d3478fdf)", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug, enums: !2, retainedTypes: !3, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "test.c", directory: "/tmp/home/yhs/work/tests/extern")
!2 = !{}
!3 = !{!4}
!4 = !DISubprogram(name: "load_byte", linkageName: "llvm.bpf.load.byte", scope: !1, file: !1, line: 1, type: !5, flags: DIFlagPrototyped, spFlags: DISPFlagOptimized, retainedNodes: !2)
!5 = !DISubroutineType(types: !6)
!6 = !{!7, !8, !7}
!7 = !DIBasicType(name: "long long unsigned int", size: 64, encoding: DW_ATE_unsigned)
!8 = !DIDerivedType(tag: DW_TAG_pointer_type, baseType: null, size: 64)
!9 = !{i32 7, !"Dwarf Version", i32 4}
!10 = !{i32 2, !"Debug Info Version", i32 3}
!11 = !{i32 1, !"wchar_size", i32 4}
!12 = !{!"clang version 10.0.0 (https://github.com/llvm/llvm-project.git 907019d835895443b198afcd992c42c9d3478fdf)"}
!13 = distinct !DISubprogram(name: "test", scope: !1, file: !1, line: 3, type: !14, scopeLine: 3, flags: DIFlagPrototyped | DIFlagAllCallsDescribed, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !16)
!14 = !DISubroutineType(types: !15)
!15 = !{!7, !8}
!16 = !{!17}
!17 = !DILocalVariable(name: "skb", arg: 1, scope: !13, file: !1, line: 3, type: !8)
!18 = !DILocation(line: 0, scope: !13)
!19 = !DILocation(line: 4, column: 10, scope: !13)
!20 = !DILocation(line: 4, column: 3, scope: !13)
