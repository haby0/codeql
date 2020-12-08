import semmle.code.cpp.models.interfaces.DataFlow
import semmle.code.cpp.models.interfaces.Taint

/**
 * The standard function `swap`. A use of `swap` looks like this:
 * ```
 * std::swap(obj1, obj2)
 * ```
 */
private class Swap extends DataFlowFunction {
  Swap() { this.hasQualifiedName("std", "swap") }

  override predicate hasDataFlow(FunctionInput input, FunctionOutput output) {
    input.isParameterDeref(0) and
    output.isParameterDeref(1)
    or
    input.isParameterDeref(1) and
    output.isParameterDeref(0)
  }
}

/**
 * A `swap` member function that is used as follows:
 * ```
 * obj1.swap(obj2)
 * ```
 */
private class MemberSwap extends TaintFunction, MemberFunction {
  MemberSwap() {
    this.hasName("swap") and
    this.getNumberOfParameters() = 1 and
    this.getParameter(0).getType() instanceof ReferenceType and
    this.getParameter(0).getType().(ReferenceType).getBaseType().getUnspecifiedType() =
      getDeclaringType()
  }

  override predicate hasTaintFlow(FunctionInput input, FunctionOutput output) {
    input.isQualifierObject() and
    output.isParameterDeref(0)
    or
    input.isParameterDeref(0) and
    output.isQualifierObject()
  }
}
