import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/github_dark.dart';
import 'package:share_plus/share_plus.dart';

class CodeEditor extends StatefulWidget {
  final String code;
  final String language;
  final bool isEditable;

  const CodeEditor({
    super.key,
    required this.code,
    required this.language,
    this.isEditable = false,
  });

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  late TextEditingController _controller;
  late String _currentCode;

  @override
  void initState() {
    super.initState();
    _currentCode = widget.code;
    _controller = TextEditingController(text: widget.code);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _copyToClipboard() async {
    await Share.share(_currentCode);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isDark ? Colors.grey[900] : Colors.grey[100],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.language,
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: _copyToClipboard,
                  tooltip: 'Copy code',
                ),
              ],
            ),
          ),
          if (widget.isEditable)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
                onChanged: (value) {
                  setState(() {
                    _currentCode = value;
                  });
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HighlightView(
                _currentCode,
                language: widget.language,
                theme: isDark ? githubDarkTheme : githubTheme,
                padding: const EdgeInsets.all(8),
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
