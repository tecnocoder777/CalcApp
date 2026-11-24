import 'package:flutter/material.dart';

void main() => runApp(const CalcApp());

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const CalcPage(),
    );
  }
}

class CalcPage extends StatefulWidget {
  const CalcPage({super.key});

  @override
  State<CalcPage> createState() => _CalcPageState();
}

class _CalcPageState extends State<CalcPage> {
  String _expr = '';
  String _result = '0';

  static const _buttons = [
    ['C', '⌫', '%', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['0', '.', '='],
  ];

  bool _isOp(String s) => ['+', '-', '×', '÷', '%'].contains(s);

  void _onPress(String b) {
    setState(() {
      if (b == 'C') {
        _expr = '';
        _result = '0';
      } else if (b == '⌫') {
        if (_expr.isNotEmpty) _expr = _expr.substring(0, _expr.length - 1);
        _live();
      } else if (b == '=') {
        final r = _eval(_expr);
        if (r != null) {
          _expr = r;
          _result = r;
        } else {
          _result = 'Error';
        }
      } else {
        if (_isOp(b)) {
          if (_expr.isEmpty && b != '-') return;
          if (_expr.isNotEmpty && _isOp(_expr[_expr.length - 1])) {
            _expr = _expr.substring(0, _expr.length - 1);
          }
        }
        _expr += b;
        _live();
      }
    });
  }

  void _live() {
    final r = _eval(_expr);
    _result = r ?? (_expr.isEmpty ? '0' : _result);
  }

  // Simple evaluator: handles + - × ÷ % with correct precedence.
  String? _eval(String e) {
    if (e.isEmpty) return null;
    try {
      final tokens = <String>[];
      var num = '';
      for (var i = 0; i < e.length; i++) {
        final c = e[i];
        if (_isOp(c) && !(c == '-' && (i == 0 || _isOp(e[i - 1])))) {
          if (num.isEmpty) return null;
          tokens.add(num);
          tokens.add(c);
          num = '';
        } else {
          num += c;
        }
      }
      if (num.isEmpty) return null;
      tokens.add(num);

      // First pass: × ÷ %
      final stage = <String>[tokens[0]];
      for (var i = 1; i < tokens.length; i += 2) {
        final op = tokens[i];
        final b = double.parse(tokens[i + 1]);
        if (op == '×' || op == '÷' || op == '%') {
          final a = double.parse(stage.removeLast());
          double r;
          if (op == '×') {
            r = a * b;
          } else if (op == '÷') {
            if (b == 0) return null;
            r = a / b;
          } else {
            if (b == 0) return null;
            r = a % b;
          }
          stage.add(r.toString());
        } else {
          stage.add(op);
          stage.add(tokens[i + 1]);
        }
      }
      // Second pass: + -
      var total = double.parse(stage[0]);
      for (var i = 1; i < stage.length; i += 2) {
        final b = double.parse(stage[i + 1]);
        total = stage[i] == '+' ? total + b : total - b;
      }
      return _fmt(total);
    } catch (_) {
      return null;
    }
  }

  String _fmt(double v) {
    if (v == v.roundToDouble() && v.abs() < 1e15) return v.toInt().toString();
    var s = v.toStringAsFixed(8);
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    return s;
  }

  Color _color(String b) {
    if (b == '=') return Colors.orange;
    if (_isOp(b)) return Colors.orange.shade800;
    if (b == 'C' || b == '⌫') return Colors.grey.shade700;
    return Colors.grey.shade900;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                alignment: Alignment.bottomRight,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_expr,
                        style: const TextStyle(fontSize: 28, color: Colors.white54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    FittedBox(
                      child: Text(_result,
                          style: const TextStyle(
                              fontSize: 56, fontWeight: FontWeight.w300)),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: _buttons.map((row) {
                    return Expanded(
                      child: Row(
                        children: row.map((b) {
                          return Expanded(
                            flex: b == '0' ? 2 : 1,
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _color(b),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                ),
                                onPressed: () => _onPress(b),
                                child: Text(b,
                                    style: const TextStyle(fontSize: 26)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
