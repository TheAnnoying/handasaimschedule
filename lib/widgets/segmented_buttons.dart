import 'package:flutter/material.dart';

class SegmentedButtons<T> extends StatelessWidget {
  final List<SegmentItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;

  final double height;

  const SegmentedButtons({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    assert(items.isNotEmpty);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(items.length, (i) {
        final item = items[i];
        final selected = item.value == value;

        return Padding(
          padding: EdgeInsetsDirectional.only(
            start: i == 0 ? 0 : 4,
          ),
          child: _Segment(
            height: height,
            borderRadius: .horizontal(
              right: i == 0 || selected
                ? .circular(24)
                : .circular(8),
              left: i == items.length - 1 || selected
                ? .circular(24)
                : .circular(8)
            ),
            selected: selected,
            label: item.label,
            icon: item.icon,
            onTap: () {
              if (!selected) onChanged(item.value);
            },
          ),
        );
      }),
    );
  }
}

class SegmentItem<T> {
  final T value;
  final String label;
  final IconData? icon;

  const SegmentItem({
    required this.value,
    required this.label,
    this.icon,
  });
}

class _Segment extends StatelessWidget {
  final double height;
  final BorderRadius borderRadius;
  final bool selected;
  final String label;
  final IconData? icon;
  final VoidCallback onTap;

  const _Segment({
    required this.height,
    required this.borderRadius,
    required this.selected,
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? cs.onPrimary : cs.onSurface;

    return SizedBox(
      height: height,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutQuad,
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: borderRadius,
        ),
        child: Material(
          color: Colors.transparent,
          clipBehavior: .hardEdge,
          borderRadius: borderRadius,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onTap,
            child: Padding(
              padding: .symmetric(horizontal: 24),
              child: Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutQuad,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: fg,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: fg),
                        const SizedBox(width: 8),
                      ],
                      Text(label),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
