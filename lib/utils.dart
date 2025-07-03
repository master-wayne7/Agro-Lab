import 'package:flutter/material.dart';

/// Formats message text with support for bullet points, bold text, and nested lists
TextSpan formatMessageText(String text, {bool isUser = false}) {
  List<TextSpan> children = [];

  // Pre-process text to handle escaped asterisks
  text = text.replaceAll(r'\*\*', '**');

  List<String> lines = text.split('\n');
  Color textColor = isUser ? Colors.white : Colors.black;

  for (String line in lines) {
    if (line.trim().isEmpty) {
      children.add(TextSpan(text: '\n'));
      continue;
    }

    // Count leading spaces to determine nesting level
    int leadingSpaces = line.length - line.trimLeft().length;
    int nestingLevel = leadingSpaces ~/ 2; // Assuming 2 spaces per level

    // Handle bullet points
    if (line.trim().startsWith('* ') || line.trim().startsWith('• ')) {
      // Add newline before bullet points if not the first line
      if (children.isNotEmpty && children.last.text != null && !children.last.text!.endsWith('\n')) {
        children.add(TextSpan(text: '\n'));
      }

      String bulletText = line.trim().startsWith('* ') ? line.trim().substring(2) : line.trim().substring(2);
      String bullet = '•';

      // Handle nested bullet points
      if (nestingLevel > 0) {
        bullet = '  ' * (nestingLevel - 1) + '•';
      }

      // Check if the bullet point contains bold text
      if (bulletText.contains('**')) {
        List<String> parts = bulletText.split('**');
        children.add(TextSpan(
          text: bullet + ' ',
          style: TextStyle(fontSize: 16, color: textColor),
        ));

        for (int i = 0; i < parts.length; i++) {
          if (i.isEven) {
            children.add(TextSpan(
              text: parts[i],
              style: TextStyle(fontSize: 16, color: textColor),
            ));
          } else {
            children.add(TextSpan(
              text: parts[i],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ));
          }
        }
        children.add(TextSpan(text: '\n'));
      } else {
        children.add(TextSpan(
          text: bullet + ' ' + bulletText + '\n',
          style: TextStyle(fontSize: 16, color: textColor),
        ));
      }
      continue;
    }

    // Handle bold text
    if (line.contains('**')) {
      List<String> parts = line.split('**');
      for (int i = 0; i < parts.length; i++) {
        if (i.isEven) {
          children.add(TextSpan(
            text: parts[i],
            style: TextStyle(fontSize: 16, color: textColor),
          ));
        } else {
          children.add(TextSpan(
            text: parts[i],
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ));
        }
      }
      children.add(TextSpan(text: '\n'));
      continue;
    }

    // Regular text
    children.add(TextSpan(
      text: line + '\n',
      style: TextStyle(fontSize: 16, color: textColor),
    ));
  }

  return TextSpan(children: children);
}
