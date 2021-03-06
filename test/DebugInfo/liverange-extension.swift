// RUN: %target-swift-frontend %s -g -emit-ir -o - | %FileCheck %s

func use<T>(_ x: T) {}

func getInt32() -> Int32 { return -1 }

public func rangeExtension(_ b: Bool) {
  // CHECK: define {{.*}}rangeExtension
  let i = getInt32()
  // CHECK: llvm.dbg.value(metadata i32 [[I:.*]], i64 0, metadata
  use(i)
  if b {
    let j = getInt32()
    // CHECK: llvm.dbg.value(metadata i32 [[I]], i64 0, metadata
    // CHECK: llvm.dbg.value(metadata i32 [[J:.*]], i64 0, metadata
    use(j)
    // CHECK-DAG: {{(asm sideeffect "", "r".*)|(zext i32)}} [[J]]
    // CHECK-DAG: asm sideeffect "", "r"
  }
  let z = getInt32()
  use(z)
  // CHECK-NOT: llvm.dbg.value(metadata i32 [[J]], i64 0, metadata
  // CHECK-DAG: llvm.dbg.value(metadata i32 [[I]], i64 0, metadata
  // CHECK-DAG: llvm.dbg.value(metadata i32 [[Z:.*]], i64 0, metadata
  // CHECK-DAG: {{(asm sideeffect "", "r".*)|(zext i32)}} [[I]]
  // CHECK-DAG: asm sideeffect "", "r"
}
