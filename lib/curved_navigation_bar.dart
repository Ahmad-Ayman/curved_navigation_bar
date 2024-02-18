// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:meta/meta.dart';
import 'src/nav_button.dart';
import 'src/nav_custom_painter.dart';

typedef _LetIndexPage = bool Function(int value);

class CurvedITem {
  Widget icon;
  String title;
  CurvedITem({
    required this.icon,
    required this.title,
  });
}

class CurvedNavigationBar extends StatefulWidget {
  final List<CurvedITem> items;

  final int index;
  final Color color;
  final Color? buttonBackgroundColor;
  final Color backgroundColor;
  final ValueChanged<int>? onTap;
  final _LetIndexPage letIndexChange;
  final Curve animationCurve;
  final Duration animationDuration;
  final double height;

  CurvedNavigationBar({
    Key? key,
    required this.items,
    this.index = 0,
    this.color = Colors.white,
    this.buttonBackgroundColor,
    this.backgroundColor = Colors.blueAccent,
    this.onTap,
    _LetIndexPage? letIndexChange,
    this.animationCurve = Curves.easeOut,
    this.animationDuration = const Duration(milliseconds: 600),
    this.height = 75.0,
  })  : letIndexChange = letIndexChange ?? ((_) => true),
        assert(items != null),
        assert(items.length >= 1),
        assert(0 <= index && index < items.length),
        super(key: key);

  @override
  CurvedNavigationBarState createState() => CurvedNavigationBarState();
}

class CurvedNavigationBarState extends State<CurvedNavigationBar>
    with SingleTickerProviderStateMixin {
  late double _startingPos;
  int _endingIndex = 0;
  late double _pos;
  double _buttonHide = 0;
  late Widget _icon;
  late AnimationController _animationController;
  late int _length;

  @override
  void initState() {
    super.initState();
    _icon = widget.items[widget.index].icon;
    _length = widget.items.length;
    _pos = widget.index / _length;
    _startingPos = widget.index / _length;
    _animationController = AnimationController(vsync: this, value: _pos);
    _animationController.addListener(() {
      setState(() {
        _pos = _animationController.value;
        final endingPos = _endingIndex / widget.items.length;
        final middle = (endingPos + _startingPos) / 2;
        if ((endingPos - _pos).abs() < (_startingPos - _pos).abs()) {
          _icon = widget.items[_endingIndex].icon;
        }
        _buttonHide =
            (1 - ((middle - _pos) / (_startingPos - middle)).abs()).abs();
      });
    });
  }

  @override
  void didUpdateWidget(CurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final newPosition = widget.index / _length;
      _startingPos = _pos;
      _endingIndex = widget.index;
      _animationController.animateTo(newPosition,
          duration: widget.animationDuration, curve: widget.animationCurve);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      color: widget.backgroundColor,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned(
            // top: widget.height * 0.45,
            left: Directionality.of(context) == TextDirection.rtl
                ? null
                : _pos * size.width,
            right: Directionality.of(context) == TextDirection.rtl
                ? _pos * size.width
                : null,
            width: size.width / _length,
            height: widget.height,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Transform.translate(
                  offset: Offset(
                    0,
                    -(1 - _buttonHide) * widget.height / 2.5,
                  ),
                  child: Material(
                    color: widget.buttonBackgroundColor ?? widget.color,
                    type: MaterialType.circle,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        widget.color, // Use the parent widget's color
                        BlendMode.srcIn,
                      ),
                      child: SizedBox(
                        height: widget.height * 0.8,
                        width: widget.height * 0.8,
                        child: Padding(
                          padding: EdgeInsets.all(4),
                          child: _icon,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomPaint(
              painter: NavCustomPainter(
                  _pos, _length, widget.color, Directionality.of(context)),
              child: Container(
                height: widget.height,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SizedBox(
                height: widget.height * 1.25,
                child: Row(
                    children: widget.items.map((item) {
                  return Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: EdgeInsets.only(top: 20),
                            child: NavButton(
                              onTap: _buttonTap,
                              position: _pos,
                              length: _length,
                              index: widget.items.indexOf(item),
                              child: Center(child: item.icon),
                            ),
                          ),
                        ),
                        Expanded(child: Text(item.title)),
                      ],
                    ),
                  );
                }).toList())),
          ),
        ],
      ),
    );
  }

  void setPage(int index) {
    _buttonTap(index);
  }

  void _buttonTap(int index) {
    if (!widget.letIndexChange(index)) {
      return;
    }
    if (widget.onTap != null) {
      widget.onTap!(index);
    }
    final newPosition = index / _length;
    setState(() {
      _startingPos = _pos;
      _endingIndex = index;
      _animationController.animateTo(newPosition,
          duration: widget.animationDuration, curve: widget.animationCurve);
    });
  }
}
