import 'dart:collection';

import 'package:flutter/material.dart';

class StreamListBuilder<T> extends StreamBuilderBase<T, AsyncSnapshot<T>> {
  StreamListBuilder({
    this.maxData = 10,
    super.key,
    this.initialData,
    super.stream,
    required this.builder,
    this.isAnimated = true,
  });

  /// The build strategy currently used by this builder.
  ///
  /// This builder must only return a widget and should not have any side
  /// effects as it may be called multiple times.
  final AsyncWidgetBuilder<T> builder;

  /// The data that will be used to create the initial snapshot.
  ///
  /// Providing this value (presumably obtained synchronously somehow when the
  /// [Stream] was created) ensures that the first frame will show useful data.
  /// Otherwise, the first frame will be built with the value null, regardless
  /// of whether a value is available on the stream: since streams are
  /// asynchronous, no events from the stream can be obtained before the initial
  /// build.
  final T? initialData;

  final int maxData;

  final bool isAnimated;

  Queue<Widget> recentData = Queue();

  @override
  AsyncSnapshot<T> initial() => initialData == null
      ? AsyncSnapshot<T>.nothing()
      : AsyncSnapshot<T>.withData(ConnectionState.none, initialData as T);

  @override
  AsyncSnapshot<T> afterConnected(AsyncSnapshot<T> current) =>
      current.inState(ConnectionState.waiting);

  @override
  AsyncSnapshot<T> afterData(AsyncSnapshot<T> current, T data) {
    return AsyncSnapshot<T>.withData(ConnectionState.active, data);
  }

  @override
  AsyncSnapshot<T> afterError(
      AsyncSnapshot<T> current, Object error, StackTrace stackTrace) {
    return AsyncSnapshot<T>.withError(
        ConnectionState.active, error, stackTrace);
  }

  @override
  AsyncSnapshot<T> afterDone(AsyncSnapshot<T> current) =>
      current.inState(ConnectionState.done);

  @override
  AsyncSnapshot<T> afterDisconnected(AsyncSnapshot<T> current) =>
      current.inState(ConnectionState.none);

  @override
  Widget build(BuildContext context, AsyncSnapshot<T> currentSummary) {
    recentData.addFirst(builder(context, currentSummary));
    if (recentData.length > maxData) {
      recentData.removeLast();
    }
    if (isAnimated) {
      List<Widget> children = recentData.toList();

      return ListView.builder(
        itemCount: children.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          if (index < maxData - 1) {
            return children[index];
          } else {
            return AnimatedContainer(
              duration: const Duration(seconds: 1),
              width: 10,
              child: children.last,
            );
          }
        },
      );
    } else {
      //no fade animation
      return ListView(
        shrinkWrap: true,
        children: recentData.toList(),
      );
    }
  }
}
