import 'package:flutter/material.dart';
import 'package:joubknea/ui/widgets/bordered_text_field.dart';

class verification extends StatelessWidget {
  final Function(String) onChanged;

  verification({@required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          child: Column(
            children: [
              Text(
                'Verification Codes',
                style: Theme.of(context).textTheme.headline3,
              ),
              
            ],
          ),
        ),
        SizedBox(height: 25),
        Expanded(
          child: BorderedTextField(
            labelText: 'codes',
            onChanged: onChanged,
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }
}
