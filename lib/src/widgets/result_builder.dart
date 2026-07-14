import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vm_result/vm_result.dart';

/// A reactive builder widget for rendering asynchronous [Result] states.
///
/// Wraps a standard [ValueListenableBuilder] to automatically rebuild whenever
/// the [listenable] notifies its listeners of a state transition.
class ResultBuilder<T> extends StatelessWidget {
  /// Creates a [ResultBuilder] widget.
  const ResultBuilder({
    required this.listenable,
    required this.builder,
    this.child,
    super.key,
  });

  /// The [ValueListenable] that holds the current [Result] state.
  final ValueListenable<Result<T>> listenable;

  /// Builder callback that builds a widget based on the active [Result] state.
  final Widget Function(BuildContext context, Result<T> state, Widget? child) builder;

  /// Optional static child widget that is passed back to the builder for build optimization.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Result<T>>(
      valueListenable: listenable,
      builder: builder,
      child: child,
    );
  }
}
