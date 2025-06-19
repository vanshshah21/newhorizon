import 'package:flutter/material.dart';
import '../models/company.dart';
import '../models/location.dart';

class CompanyLocationForm extends StatelessWidget {
  final List<Company> companies;
  final List<Location> locations;
  final Company? selectedCompany;
  final Location? selectedLocation;
  final ValueChanged<Company?> onCompanyChanged;
  final ValueChanged<Location?> onLocationChanged;
  final VoidCallback onLogin;

  const CompanyLocationForm({
    super.key,
    required this.companies,
    required this.locations,
    required this.selectedCompany,
    required this.selectedLocation,
    required this.onCompanyChanged,
    required this.onLocationChanged,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<Company>(
          value: selectedCompany,
          items:
              companies
                  .map(
                    (company) => DropdownMenuItem<Company>(
                      value: company,
                      child: Text(company.name),
                    ),
                  )
                  .toList(),
          onChanged: onCompanyChanged,
          decoration: const InputDecoration(
            labelText: 'Select Company',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<Location>(
          value: selectedLocation,
          items:
              locations
                  .map(
                    (location) => DropdownMenuItem<Location>(
                      value: location,
                      child: Text(location.name),
                    ),
                  )
                  .toList(),
          onChanged: onLocationChanged,
          decoration: const InputDecoration(
            labelText: 'Select Location',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: onLogin, child: const Text('Login')),
      ],
    );
  }
}
