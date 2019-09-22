import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin<HomePage> {
  int _selectedIndex;

  Offset _postion;

  Size _size;

  ScrollController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Column(
        verticalDirection: VerticalDirection.up,
        children: <Widget>[
          _buildSelectedItem(),
          Container(
            margin: EdgeInsets.only(top: 12),
            child: Divider(
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              controller: _controller,
              padding: EdgeInsets.only(left: 12, right: 12, bottom: 12),
              itemBuilder: (context, index) {
                return _buildItem(index);
              },
              itemCount: 20,
            ),
          ),
        ].reversed.toList(),
      ),
    );
  }

  Widget _buildItem(int index) {
    return ListItem(
      index: index,
      height: 50,
      onTap: (context) {
        final RenderBox renderObject = context.findRenderObject();
        final positionRed = renderObject.localToGlobal(Offset.zero);
        final sizeRed = renderObject.size;

        setState(() {
          _selectedIndex = index;
          _postion = positionRed;
          _size = sizeRed;
        });
      },
    );
  }

  _buildSelectedItem() {
    Widget w;
    if (_selectedIndex != null) {
      w = HighlightItem(
        sourcePosition: _postion,
        sourceSize: _size,
        index: _selectedIndex,
      );
    } else {
      w = Container();
    }
    return AnimatedSize(
      vsync: this,
      duration: Duration(milliseconds: 200),
      child: w,
    );
  }
}

class HighlightItem extends StatefulWidget {
  final Offset sourcePosition;
  final Size sourceSize;
  final int index;

  const HighlightItem(
      {Key key, this.sourcePosition, this.sourceSize, this.index})
      : super(key: key);

  @override
  _HighlightItemState createState() => _HighlightItemState();
}

class _HighlightItemState extends State<HighlightItem>
    with
        AfterLayoutMixin<HighlightItem>,
        SingleTickerProviderStateMixin<HighlightItem> {
  Offset _destPosition;
  Size _destSize;

  Offset _localSourcePosition;
  AnimationController _controller;

  Tween<Offset> _offsetTween;
  Tween<double> _heightTween;
  Tween<double> _widthTween;

  @override
  void initState() {
    _initController();
    super.initState();
  }

  void _initController() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _determineSizeAndPosition(context);
    _startAnimating();
  }

  @override
  void didUpdateWidget(HighlightItem oldWidget) {
    if (oldWidget.index != widget.index) {
      _determineSizeAndPosition(context);
      _startAnimating();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _determineSizeAndPosition(BuildContext context) {
    final RenderBox renderObject = context.findRenderObject();
    _destPosition = renderObject.localToGlobal(Offset.zero);
    _destSize = renderObject.size;
    print("HIGHLIGHT POSITION: $_destPosition, SIZE: $_destSize");
    print(
        "SOURCE POSITION: ${widget.sourcePosition}, SIZE: ${widget.sourceSize}");
  }

  void _startAnimating() {
    RenderBox renderBox = context.findRenderObject();
    _localSourcePosition = renderBox.globalToLocal(widget.sourcePosition);
    print('LOCAL SOURCE POSITION: $_localSourcePosition');
    _offsetTween = Tween(begin:_localSourcePosition, end: Offset.zero);

    _heightTween =
        Tween<double>(begin: _destSize.height, end: _destSize.height);
    _widthTween =
        Tween<double>(begin: widget.sourceSize.width, end: _destSize.width);

    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isAnimating) {
      print('${_offsetTween.evaluate(
          CurvedAnimation(parent:_controller , curve: Curves.easeIn))}');
      return Transform.translate(
        offset: _offsetTween.evaluate(
            CurvedAnimation(parent:_controller , curve: Curves.easeIn)),
//      offset: Offset(-31.7,450),
        child: Container(
          height: _heightTween.evaluate(
              CurvedAnimation(parent: _controller, curve: Curves.easeIn)),
          width: _widthTween.evaluate(
              CurvedAnimation(parent: _controller, curve: Curves.easeIn)),
          child: _buildChild(),
        ),
      );
    } else {
      return Opacity(
        opacity: _destPosition != null ? 1.0 : 0.0,
        child: _buildChild(),
      );
    }
  }

  Widget _buildChild() {
    return ListItem(
      height: 100,
      width: 300,
      fontSize: 24,
      index: widget.index,
    );
  }
}

class ListItem extends StatelessWidget {
  final int index;
  final double width;
  final double height;
  final Function(BuildContext) onTap;
  final double fontSize;
  final Color color;

  const ListItem(
      {Key key,
      this.index,
      this.width,
      this.height,
      this.onTap,
      this.fontSize,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tag = "Item$index";
    return Card(
      margin: EdgeInsets.all(12).subtract(
        EdgeInsets.only(bottom: 12),
      ),
      elevation: 4,
      color: color,
      child: InkWell(
        onTap: () {
          onTap(context);
        },
        child: Container(
          height: height,
          width: width,
          child: Text(
            tag,
            style: TextStyle(fontSize: fontSize),
          ),
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
