import 'package:flutter/material.dart';
import 'package:test_notifi/features/paints.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Tool _selectedTool = Tool.pen;
  Color _selectedColor = Colors.black;
  double _strokeWidth = 4.0;
  final GlobalKey _canvasKey = GlobalKey();

  List<Shape> _shapes = [];

  // Temporary during drawing
  FreehandShape? _currentFreehand;
  CircleShape? _currentCircle;

  final List<Color> _palette = [
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.brown,
  ];

  void _startPan(Offset pos) {
    if (_selectedTool == Tool.pen) {
      _currentFreehand = FreehandShape(
        points: [pos],
        color: _selectedColor,
        strokeWidth: _strokeWidth,
      );
      setState(() {
        _shapes.add(_currentFreehand!);
      });
    } else if (_selectedTool == Tool.circle) {
      _currentCircle = CircleShape(
        center: pos,
        radius: 0,
        color: _selectedColor,
        strokeWidth: _strokeWidth,
      );
      setState(() {
        _shapes.add(_currentCircle!);
      });
    }
  }

  void _updatePan(Offset pos) {
    if (_selectedTool == Tool.pen && _currentFreehand != null) {
      setState(() {
        _currentFreehand!.points.add(pos);
      });
    } else if (_selectedTool == Tool.circle && _currentCircle != null) {
      setState(() {
        _currentCircle!.radius = (pos - _currentCircle!.center).distance;
      });
    }
  }

  void _endPan() {
    _currentFreehand = null;
    _currentCircle = null;
  }

  void _clearCanvas() {
    setState(() {
      _shapes.clear();
    });
  }

  void _undo() {
    if (_shapes.isNotEmpty) {
      setState(() {
        _shapes.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Paint'),
        actions: [
          IconButton(
            tooltip: 'Undo',
            icon: const Icon(Icons.undo),
            onPressed: _undo,
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete),
            onPressed: _clearCanvas,
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return Column(
              children: [_buildBoard, _buildOptions],
            );
          }
          return Row(
            children: [
              _buildBoard,
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width * 0.3,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade200),
                padding: const EdgeInsets.all(12) + EdgeInsets.only(top: 8),
                // child: _buildOptions,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Color',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      GridView(
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4),
                        children: List.generate(_palette.length, (index) {
                          final item = _palette[index];
                          bool selected = item == _selectedColor;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = item;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: selected ? 40 : 34,
                              height: selected ? 40 : 34,
                              decoration: BoxDecoration(
                                color: item,
                                shape: BoxShape.circle,
                                border: selected
                                    ? Border.all(color: Colors.black, width: 2)
                                    : null,
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Brush Size',
                          ),
                          Text('${_strokeWidth.toInt()} px'),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Slider(
                        min: 1,
                        max: 40,
                        value: _strokeWidth,
                        onChanged: (v) {
                          setState(() {
                            _strokeWidth = v;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: _buildToggleButtons(),
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget get _buildBoard {
    return Expanded(
      child: Container(
        key: _canvasKey,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),

        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            _startPan(_clamp(details.localPosition));
          },
          onPanUpdate: (details) {
            _updatePan(_clamp(details.localPosition));
          },
          onPanEnd: (details) => _endPan(),
          child: CustomPaint(
            painter: Sketcher(shapes: _shapes),
            child: Container(),
          ),
        ),
      ),
    );
  }

  Widget get _buildOptions {
    return Container(
      color: Colors.grey[100],
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _buildToggleButtons(),
              const Spacer(),
              const Text('Size:'),
              const SizedBox(width: 8),
              SizedBox(
                width: 120,
                child: Slider(
                  min: 1,
                  max: 40,
                  value: _strokeWidth,
                  onChanged: (v) {
                    setState(() {
                      _strokeWidth = v;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(_strokeWidth.toInt().toString()),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _palette.map((c) {
              bool selected = c == _selectedColor;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = c;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: selected ? 40 : 34,
                  height: selected ? 40 : 34,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: Colors.black, width: 2)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButtons(){
    return ToggleButtons(
      isSelected: [
        _selectedTool == Tool.pen,
        _selectedTool == Tool.circle
      ],
      onPressed: (i) {
        setState(() {
          _selectedTool = (i == 0) ? Tool.pen : Tool.circle;
        });
      },
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Icon(Icons.brush),
            SizedBox(width: 6),
            Text('Pen')
          ]),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(children: [
            Icon(Icons.circle),
            SizedBox(width: 6),
            Text('Circle')
          ]),
        ),
      ],
    );
  }

  Offset _clamp(Offset pos) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return pos;

    final size = box.size;

    return Offset(
      pos.dx.clamp(0, size.width),
      pos.dy.clamp(0, size.height),
    );
  }
}
