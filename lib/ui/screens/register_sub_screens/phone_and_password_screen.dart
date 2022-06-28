import 'package:flutter/material.dart';
import 'package:joubknea/ui/widgets/bordered_text_field.dart';

class PhoneandPasswordScreen extends StatelessWidget {
  final Function(String) emailOnChanged;
  final Function(String) passwordOnChanged;

  PhoneandPasswordScreen(
      {@required this.emailOnChanged, @required this.passwordOnChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Phonenumber and',
          style: Theme.of(context).textTheme.headline3,
        ),
        Text(
          'Password is',
          style: Theme.of(context).textTheme.headline3,
        ),
        SizedBox(height: 25),
        BorderedTextField(
          labelText: 'Phonenumber',
          onChanged: emailOnChanged,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 5),
        BorderedTextField(
          labelText: 'Password',
          onChanged: passwordOnChanged,
          obscureText: true,
        ),
      ],
    );
  }
}
