import 'package:flutter/material.dart';

class WordInputField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              focusNode: wordFocusNode,
              textInputAction: TextInputAction.next,
              controller: wordController,
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
                FocusScope.of(context).requestFocus(meaningFocusNode);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              focusNode: meaningFocusNode,
              textInputAction: TextInputAction.next,
              controller: meaningController,
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
              onFieldSubmitted: (_) => onNextField(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
