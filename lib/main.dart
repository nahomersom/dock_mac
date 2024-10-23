import 'package:flutter/material.dart';

/// Entry point of the application.
void main() {
  runApp(const MyApp());
}

/// Main widget building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon, index) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[index % Colors.primaries.length],
                ),
                child: Center(
                  child: Icon(icon, color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock widget displaying draggable and reorderable items.
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  /// List of items to display in the dock.
  final List<T> items;

  /// A builder function to build each item widget.
  final Widget Function(T item, int index) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] which handles dragging and sorting of items.
class _DockState<T extends Object> extends State<Dock<T>> {
  /// Internal list of items that are manipulated during drag operations.
  late List<T> _items = widget.items.toList();

  /// Index of the currently dragged item, null if no item is being dragged.
  int? _draggedIndex;

  /// Index of the hover position where the dragged item might land.
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          return Expanded(
            child: LongPressDraggable<T>(
              data: _items[index],
              axis: Axis.horizontal,
              dragAnchorStrategy: pointerDragAnchorStrategy,
              feedback: Material(
                color: Colors.transparent,
                child: widget.builder(_items[index], index),
              ),
              childWhenDragging: const SizedBox.shrink(),
              onDragStarted: () {
                setState(() {
                  _draggedIndex = index;
                });
              },
              onDragEnd: (details) {
                setState(() {
                  _draggedIndex = null;
                  _hoveredIndex = null;
                });
              },
              child: DragTarget<T>(
                onAcceptWithDetails: (DragTargetDetails<T> details) {
                  _onItemReordered(details.data, index);
                },
                onWillAcceptWithDetails: (data) {
                  setState(() {
                    _hoveredIndex = index;
                  });
                  return true;
                },
                onLeave: (_) {
                  setState(() {
                    _hoveredIndex = null;
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: _draggedIndex == index
                        ? const SizedBox.shrink()
                        : _buildDockItem(index),
                  );
                },
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Builds the dock item with hover highlight effect.
  Widget _buildDockItem(int index) {
    return Container(
      constraints: const BoxConstraints(minWidth: 48),
      height: 48,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: _hoveredIndex == index
            ? Colors.blueAccent
            : Colors.primaries[index % Colors.primaries.length],
      ),
      child: Center(child: widget.builder(_items[index], index)),
    );
  }

  /// Handles item reordering by swapping the dragged item with the target index.
  void _onItemReordered(T data, int newIndex) {
    final oldIndex = _items.indexOf(data);
    setState(() {
      _items.removeAt(oldIndex);
      _items.insert(newIndex, data);
    });
  }
}
