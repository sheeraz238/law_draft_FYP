enum LineAlign { left, center, right, justify }

class DocLine {
  final String text;
  final bool bold;
  final bool underline;
  final LineAlign align;

  const DocLine(
    this.text, {
    this.bold = false,
    this.underline = false,
    this.align = LineAlign.left,
  });

  static const blank = DocLine('');
}
