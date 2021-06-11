/**
 * @name Use of externally-controlled input to select classes or code ('unsafe reflection')
 * @description Use external input with reflection function to select the class or code to
 *              be used, which brings serious security risks.
 * @kind path-problem
 * @problem.severity error
 * @precision high
 * @id java/unsafe-reflection
 * @tags security
 *       external/cwe/cwe-470
 */

import java
import DataFlow
import UnsafeReflectionLib
import semmle.code.java.dataflow.DataFlow
import semmle.code.java.dataflow.FlowSources
import DataFlow::PathGraph

private class ContainsSanitizer extends DataFlow::BarrierGuard {
  ContainsSanitizer() { this.(MethodAccess).getMethod().hasName("contains") }

  override predicate checks(Expr e, boolean branch) {
    e = this.(MethodAccess).getArgument(0) and branch = true
  }
}

private class EqualsSanitizer extends DataFlow::BarrierGuard {
  EqualsSanitizer() { this.(MethodAccess).getMethod().hasName("equals") }

  override predicate checks(Expr e, boolean branch) {
    e = [this.(MethodAccess).getArgument(0), this.(MethodAccess).getQualifier()] and
    branch = true
  }
}

class UnsafeReflectionConfig extends TaintTracking::Configuration {
  UnsafeReflectionConfig() { this = "UnsafeReflectionConfig" }

  override predicate isSource(DataFlow::Node source) { source instanceof RemoteFlowSource }

  override predicate isSink(DataFlow::Node sink) { sink instanceof UnsafeReflectionSink }

  override predicate isAdditionalTaintStep(DataFlow::Node pred, DataFlow::Node succ) {
    exists(
      ReflectiveClassIdentifierMethodAccessCall rcimac,
      ReflectionCreationInstanceOrCallMethodConfig rciocmc, MethodAccess ma
    |
      (
        ma instanceof ReflectiveConstructorsAccess or
        ma instanceof ReflectiveMethodsAccess
      ) and
      rciocmc.hasFlow(DataFlow::exprNode(rcimac), DataFlow::exprNode(ma.getQualifier())) and
      rcimac.getArgument(0) = pred.asExpr() and
      ma = succ.asExpr()
    )
  }

  override predicate isSanitizerGuard(DataFlow::BarrierGuard guard) {
    guard instanceof ContainsSanitizer or guard instanceof EqualsSanitizer
  }
}

from DataFlow::PathNode source, DataFlow::PathNode sink, UnsafeReflectionConfig conf
where conf.hasFlowPath(source, sink)
select sink.getNode(), source, sink, "Unsafe reflection of $@.", source.getNode(), "user input"
