import 'package:flutter/material.dart';

/*
  A function to build a custom styled text field.
  - label: is the label text to display above the text field.
  - onSaved: is the callback function to save the input value.
  - enabled: determines if the text field is enabled or disabled.
*/
Widget buildTextField({
  required String label,
  required ValueChanged<String?> onSaved,
  bool enabled = true,
}) {
  return TextFormField(
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF31231A)), // Label text style.
      // Border color when enabled.
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF31231A)), 
        borderRadius: BorderRadius.circular(30), 
      ),
      // Border color when focused.
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF31231A)), 
        borderRadius: BorderRadius.circular(30), 
      ),
      filled: true,
      fillColor: Colors.white,
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter a $label'; // Validation message.
      }
      return null;
    },
    onSaved: onSaved, // Save input value.
    enabled: enabled, // Determine if the field is enabled or disabled.
  );
}

/*
  A function to build a custom styled dropdown field.
  - label: is the label text to display above the dropdown field.
  - value: is the currently selected value.
  - items: is the list of items to display in the dropdown menu.
  - onChanged: is the callback function to handle value changes.
  - enabled: determines if the dropdown field is enabled or disabled.
*/
Widget buildDropdownField({
  required String label,
  required String value,
  required List<String> items,
  required ValueChanged<String?> onChanged,
  bool enabled = true,
}) {
  return DropdownButtonFormField<String>(
    value: value,
    items: items
        .map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            ))
        .toList(), // Convert list of items to DropdownMenuItem list.
    onChanged: enabled ? onChanged : null, // Handle value changes if enabled.
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF31231A)), // Label text style.
      // Border color when enabled.
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF31231A)), 
        borderRadius: BorderRadius.circular(30), 
      ),
      // Border color when focused.
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF31231A)), 
        borderRadius: BorderRadius.circular(30), 
      ),
      filled: true,
      fillColor: Colors.white, // Fill color of the dropdown field.
    ),
  );
}
