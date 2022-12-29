library modal_widget;

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

mixin ModalWidget<T extends StatefulWidget> on State<T> {
  bool _isWaiting = false;

  /// Returns whether the procedure of waiting has started or not
  bool get isWaiting => _isWaiting;

  // Async control object that is signaled when the widget is hidden
  late Completer<bool> _completer;

  // on Hide Callback for the current overlay and the default onHide callback
  VoidCallback? _onHide;
  VoidCallback? _defaultOnHide;

  Future<bool> showModalWidgetDuring(Duration period, {VoidCallback? onHide}) {
    return showModalWidgetWhile(() async => await Future.delayed(period),
        onHide: onHide);
  }

  /// Function that executes a [callback] and waits for its execution. It is possible to set
  ///   a [timeout] for the callback, and if the time exceeds, the execution will be aborted
  ///   and the callback [onTimeout] will be executed (if provided).
  ///
  /// This function starts the internal procedure of waiting, so that if using the function
  ///   [buildWithWaitNotice] is used, it will return a waiting notices over the content.
  ///
  /// It returns [true] if the function started; false otherwise.
  Future<bool> showModalWidgetWhile(Function callback,
      {Duration? timeout,
      VoidCallback? onTimeout,
      VoidCallback? onHide}) async {
    if (_isWaiting) {
      return false;
    }

    var completer = showModalWidget(onHide: onHide);
    if (timeout == null) {
      callback().then((value) {
        hideModalWidget();
      });
    } else {
      callback().timeout(timeout, onTimeout: () async {
        if (onTimeout != null) {
          onTimeout();
        }
        // Make sure that it stops waiting
        hideModalWidget();
      }).then((value) {
        hideModalWidget();
      });
    }

    return completer;
  }

  /// Starts the procedure of waiting, so that if using the function [buildWithWaitNotice] it returns the
  ///   overlay content. If setting [force] to true, the state will be forced even if it was already waiting.
  Future<bool> showModalWidget(
      {bool force = false, VoidCallback? onHide}) async {
    // Do not set state multiple times
    if (_isWaiting && !force) {
      return false;
    }

    setState(() {
      _completer = Completer();
      _onHide = onHide;
      _isWaiting = true;
    });

    return _completer.future;
  }

  /// Ends the procedure of waiting, so that if using the function [buildWithWaitNotice] it does not return
  ///   the overlay content. If setting [force] to true, the state will be forced even if it was not waiting.
  void hideModalWidget([bool force = false]) {
    // Do not set state multiple times
    if (!_isWaiting && !force) {
      _completer.complete(false);
      return;
    }

    VoidCallback? onHide = _onHide ?? _defaultOnHide;

    setState(() {
      _onHide = null;
      _isWaiting = false;
    });

    if (onHide != null) {
      onHide.call();
    }

    _completer.complete(true);
  }

  /// Build the widget so that if the waiting procedure has started, the [modalWidget] is overlayed over the
  ///   [child] content. If no [modalWidget] is provided, the [child] will not receive any pointer event, but
  ///   nothing will be overlayed (it will be blurred if [blurContent] is set to true and changed its [opacity]).
  ///
  /// If [onHide] is provided, it will be called whenever the [modalWidget] is hidden, unless it is overridden
  ///   on a a [show*] call.
  ///
  /// The idea is to include this call in the [build] method; e.g.
  ///   return buildWithModalWidget(context, child: content, waitNotice: SpinKit...)
  Widget buildWithModalWidget(
      {required Widget child,
      Widget? modalWidget,
      bool blurContent = false,
      double opacity = 0.8,
      VoidCallback? onHide}) {
    _defaultOnHide = onHide;

    if (_isWaiting) {
      if (opacity != 1.0) {
        child = Opacity(opacity: 0.5, child: child);
      }
      if (blurContent) {
        child = ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: child,
        );
      }
      if (modalWidget != null) {
        child = Stack(
          children: [
            IgnorePointer(
              child: child,
            ),
            modalWidget,
          ],
        );
      } else {
        child = IgnorePointer(child: child);
      }
    }
    return child;
  }
}
