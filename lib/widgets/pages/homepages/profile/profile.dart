import 'package:flutter/material.dart';
import 'package:gymvision/widgets/components/stateless/button.dart';
import 'package:gymvision/widgets/forms/fields/custom_dropdown.dart';
import 'package:gymvision/widgets/forms/fields/custom_form_field.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final TextEditingController _usernameController = TextEditingController(text: 'John Doe');
  final TextEditingController _emailController = TextEditingController(text: 'john.doe@example.com');
  final TextEditingController _weightController = TextEditingController(text: '70 kg');
  final TextEditingController _heightController = TextEditingController(text: '175 cm');
  String _gender = 'Male';

  void reload() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage("assets/images/logo.png"),
          ),
          const SizedBox(height: 20),
          CustomFormField.string(
            controller: _usernameController,
            label: 'Username',
            prefixIcon: Icons.person_rounded,
          ),
          CustomFormField.string(
            controller: _emailController,
            label: 'Email',
            prefixIcon: Icons.email_rounded,
          ),
          CustomFormField.double(
            controller: _heightController,
            label: 'Height',
            prefixIcon: Icons.height_rounded,
          ),
          CustomDropdown(
            label: 'Gender',
            values: ['Male', 'Female', 'Other'],
            onChange: (value) {
              setState(() {
                _gender = value!;
              });
            },
          ),
          Button.elevated(
            icon: Icons.save_rounded,
            text: 'Save Profile',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile saved!')),
              );
            },
          ),
        ],
      ),
    );
  }
}
