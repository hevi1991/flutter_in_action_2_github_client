import 'package:flutter/material.dart';

class PullRefreshIndicator extends StatefulWidget {
  const PullRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
  }) : super(key: key);

  final RefreshCallback onRefresh;
  final Widget child;

  @override
  _PullRefreshIndicatorState createState() => _PullRefreshIndicatorState();
}

class _PullRefreshIndicatorState extends State<PullRefreshIndicator> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      displacement: 44,
      child: widget.child,
      onRefresh: widget.onRefresh,
    );
  }
}
