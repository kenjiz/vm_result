import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vm_result/vm_result.dart';

class ResultBuilder<T> extends StatelessWidget {
  const ResultBuilder({
    required this.listenable,
    required this.builder,
    this.child,
    super.key,
  });

  final ValueListenable<Result<T>> listenable;

  final Widget Function(BuildContext, Result<T>, Widget?) builder;

  /// Optional child widget that can be passed to the builder for optimization.
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
