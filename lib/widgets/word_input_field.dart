import 'package:flutter/material.dart';
import 'package:memo_words/services/datamuse_service.dart';
import 'dart:async';

class WordInputField extends StatefulWidget {
  final TextEditingController wordController;
  final TextEditingController meaningController;
  final FocusNode wordFocusNode;
  final FocusNode meaningFocusNode;
  final VoidCallback onRemove;
  final VoidCallback onNextField;

  const WordInputField({
    Key? key,
    required this.wordController,
    required this.meaningController,
    required this.wordFocusNode,
    required this.meaningFocusNode,
    required this.onRemove,
    required this.onNextField,
  }) : super(key: key);

  @override
  _WordInputFieldState createState() => _WordInputFieldState();
}

class _WordInputFieldState extends State<WordInputField> {
  final DatamuseService _datamuseService = DatamuseService();
  List<String> _suggestions = [];
  Timer? _debounce;
  bool _isInternalChange = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.wordController.addListener(_onWordChanged);
  }

  @override
  void dispose() {
    widget.wordController.removeListener(_onWordChanged);
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onWordChanged() {
    if (_isInternalChange) return;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (widget.wordController.text.isNotEmpty) {
        _getSuggestions(widget.wordController.text);
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    });
  }

  void _getSuggestions(String query) async {
    try {
      final suggestions = await _datamuseService.getSuggestions(query);
      setState(() {
        _suggestions = suggestions;
      });
    } catch (e) {}
  }

  void _selectSuggestion(String suggestion) {
    _isInternalChange = true;
    widget.wordController.text = suggestion;
    setState(() {
      _suggestions = [];
    });
    _isInternalChange = false;
    FocusScope.of(context).requestFocus(widget.meaningFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  focusNode: widget.wordFocusNode,
                  textInputAction: TextInputAction.next,
                  controller: widget.wordController,
                  decoration: const InputDecoration(
                    labelText: '単語',
                    labelStyle: TextStyle(fontSize: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '単語を入力してください';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    FocusScope.of(context)
                        .requestFocus(widget.meaningFocusNode);
                  },
                ),
                if (_suggestions.isNotEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(_suggestions[index]),
                            selected: false,
                            onSelected: (_) =>
                                _selectSuggestion(_suggestions[index]),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              focusNode: widget.meaningFocusNode,
              textInputAction: TextInputAction.next,
              controller: widget.meaningController,
              decoration: const InputDecoration(
                labelText: '意味',
                labelStyle: TextStyle(fontSize: 12),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '意味を入力してください';
                }
                return null;
              },
              onFieldSubmitted: (_) => widget.onNextField(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: widget.onRemove,
          ),
        ],
      ),
    );
  }
}
