library animated_card_switcher;

import 'dart:math';

import 'package:flutter/widgets.dart';

enum CardSwitcherState { showFirst, showSecond }

class AnimatedCardSwitcher extends StatefulWidget {
  AnimatedCardSwitcher({
    Key key,
    @required this.firstChild,
    @required this.secondChild,
    @required this.state,
    this.duration = const Duration(seconds: 1),
    this.rotationAlignment = Alignment.topRight,
    this.curveIn = Curves.easeIn,
    this.curveOut = Curves.easeInBack,
  })  : assert(firstChild != null),
        assert(secondChild != null),
        assert(state != null),
        assert(duration != null),
        super(key: key);

  final Widget firstChild;
  final Widget secondChild;
  final CardSwitcherState state;
  final Duration duration;
  final Alignment rotationAlignment;
  final Curve curveIn;
  final Curve curveOut;

  @override
  State<AnimatedCardSwitcher> createState() => _AnimatedCardSwitcherState();
}

class _AnimatedCardSwitcherState extends State<AnimatedCardSwitcher> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _rotationAnim;
  Animation<double> _rotationBackAnim;
  Animation<double> _moveAnimation;
  Animation<double> _moveBackAnimation;
  CardSwitcherState _actualState;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _controller.addListener(() {
      setState(() {
        _actualState = _controller.value < 0.5 ? CardSwitcherState.showFirst : CardSwitcherState.showSecond;
      });
    });
    _controller.addStatusListener((AnimationStatus status) {
      setState(() {});
    });

    _rotationAnim = _buildRotationInAnimation(widget.curveIn);
    _rotationBackAnim = _buildRotationOutAnimation(widget.curveOut);

    _moveAnimation = Tween(begin: 0.0, end: 10.0).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5),
      ),
    );
    _moveBackAnimation = Tween(begin: 10.0, end: 0.0).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1),
      ),
    );
    _controller.value = 0;
  }

  Animation<double> _buildRotationOutAnimation(Curve curve) {
    return Tween(begin: -pi / 2.0, end: 0.0).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1, curve: curve),
      ),
    );
  }

  Animation<double> _buildRotationInAnimation(Curve curve) {
    return Tween(begin: 0.0, end: -pi / 2.0).animate(
      new CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: curve),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedCardSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) _controller.duration = widget.duration;
    if (widget.curveIn != oldWidget.curveIn) _rotationAnim = _buildRotationInAnimation(widget.curveIn);
    if (widget.curveOut != oldWidget.curveOut) _rotationBackAnim = _buildRotationOutAnimation(widget.curveOut);

    if (widget.state != oldWidget.state) {
      switch (widget.state) {
        case CardSwitcherState.showFirst:
          _controller.reverse();
          break;
        case CardSwitcherState.showSecond:
          _controller.forward();
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _actualState == CardSwitcherState.showFirst ? _secondWidget() : _firstWidget(),
      _actualState == CardSwitcherState.showFirst ? _firstWidget() : _secondWidget(),
    ]);
  }

  Widget _firstWidget() {
    double rotationAngle = _actualState == CardSwitcherState.showFirst ? _rotationAnim.value : _rotationBackAnim.value;
    double padding = _actualState == CardSwitcherState.showFirst ? _moveAnimation.value : _moveBackAnimation.value;

    return Transform.translate(
      offset: Offset(padding, 0),
      key: ValueKey<CardSwitcherState>(CardSwitcherState.showFirst),
      child: Transform.rotate(
        angle: rotationAngle,
        alignment: widget.rotationAlignment,
        child: widget.firstChild,
      ),
    );
  }

  Widget _secondWidget() {
    return KeyedSubtree(
      key: ValueKey<CardSwitcherState>(CardSwitcherState.showSecond),
      child: widget.secondChild,
    );
  }
}
