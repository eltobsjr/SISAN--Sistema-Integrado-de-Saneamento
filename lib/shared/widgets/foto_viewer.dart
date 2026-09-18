import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Viewer fullscreen de fotos com zoom, aberto ao tocar numa foto de rede
/// numa lista/carrossel — mesmo padrão do `_FotoViewerDialog` do SIGAU.
void showFotoViewer(BuildContext context, List<String> urls, int initialIndex) {
  showDialog<void>(
    context: context,
    useSafeArea: false,
    builder: (_) => _FotoViewer(urls: urls, initialIndex: initialIndex),
  );
}

class _FotoViewer extends StatefulWidget {
  const _FotoViewer({required this.urls, required this.initialIndex});
  final List<String> urls;
  final int initialIndex;

  @override
  State<_FotoViewer> createState() => _FotoViewerState();
}

class _FotoViewerState extends State<_FotoViewer> {
  late int _current = widget.initialIndex;
  late final _ctrl = PageController(initialPage: widget.initialIndex);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          leading: const CloseButton(),
          title: widget.urls.length > 1
              ? Text('${_current + 1} / ${widget.urls.length}')
              : null,
        ),
        body: PageView.builder(
          controller: _ctrl,
          itemCount: widget.urls.length,
          onPageChanged: (i) => setState(() => _current = i),
          itemBuilder: (_, i) => InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: widget.urls[i],
              fit: BoxFit.contain,
              placeholder: (_, _) =>
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
              errorWidget: (_, _, _) => const Center(
                child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
