import 'package:flutter/material.dart';

/// Lista de skeletons pulsantes para estados de loading — substitui
/// `CircularProgressIndicator` em toda página de lista (ver erro herdado
/// ERR do SIGAU: skeleton dá noção do layout que está chegando).
class SkeletonList extends StatefulWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.padding = const EdgeInsets.all(16),
  });

  final int itemCount;
  final EdgeInsets padding;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _fade = Tween<double>(begin: 0.35, end: 0.8).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ListView.separated(
        padding: widget.padding,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => const _SkeletonCardRow(),
      ),
    );
  }
}

class _SkeletonCardRow extends StatelessWidget {
  const _SkeletonCardRow();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            _Box(width: 48, height: 48, radius: 10),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Box(width: double.infinity, height: 13),
                  const SizedBox(height: 8),
                  _Box(width: 160, height: 11),
                  const SizedBox(height: 8),
                  _Box(width: 90, height: 11),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _Box(width: 20, height: 20, radius: 4),
          ],
        ),
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.width, required this.height, this.radius = 4});

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
