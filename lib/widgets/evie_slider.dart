import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

import '../api/colours.dart';

///Cupertino switch widget
class EvieSlider extends StatelessWidget {
  final ValueChanged<double?> onChanged;
  final ValueChanged<double?>? onChangedEnd;
  final double value;
  final double max;
  final String label;
  final double min;


  const EvieSlider({
    Key? key,
    required this.onChanged,
    this.onChangedEnd,
    required this.value,
    required this.max,
    required this.label,
    required this.min,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterSlider(
      values: [value],
      max: max,
      min: min,
      onDragging: (handlerIndex, lowerValue, upperValue) {
        onChanged(lowerValue);
      },
      onDragCompleted: (handlerIndex, lowerValue, upperValue) {
        if (onChangedEnd != null) {
          onChangedEnd!(lowerValue);
        }
      },
      handler: FlutterSliderHandler(
        decoration: BoxDecoration(),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            decoration: BoxDecoration(
              color: EvieColors.thumbColorTrue,
              shape: BoxShape.circle,
            ),
            width: 21,
            height: 21,
          ),
        ),
      ),
      trackBar: FlutterSliderTrackBar(
        inactiveTrackBar: BoxDecoration(color: Color(0xffD4D4D4), borderRadius: BorderRadius.circular(8.0)),
        activeTrackBar: BoxDecoration(color: EvieColors.primaryColor, borderRadius: BorderRadius.circular(8.0)),
          activeTrackBarHeight : 5.5,
        inactiveTrackBarHeight: 5,
      ),
      tooltip: FlutterSliderTooltip(disabled: true), // Disable tooltips
    );
  }


}