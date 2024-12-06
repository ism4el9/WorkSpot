
import 'package:astro_office/config/officeApi/office_all.dart';
import 'package:astro_office/screens/office_details.dart';
import 'package:astro_office/widgets/mini_office_card.dart';
import 'package:astro_office/widgets/search_bar_no_shadow.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  final bool isUserLoggedIn;
  const FavoritesPage({super.key, required this.isUserLoggedIn});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {

  bool isSharedSelected = false;
  bool isPrivateSelected = false;


  // Método para filtrar las oficinas según el tipo seleccionado
  List<Map<String, String>> get filteredOffices {
    return OfficeAll().allOffices.where((office) {
      if(isSharedSelected) return office['type'] == 'Compartido';
      if(isPrivateSelected) return office['type'] == 'Privado';
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Guardados'),
        titleSpacing: 0,
        
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only( bottom: 10, left: 10, right: 10),
            child: SearchBarNoShadow(),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredOffices.length,
              itemBuilder: (context, index) {
                final office = filteredOffices[index];
                return GestureDetector(
                  onTap: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => OfficeDetailScreen(isUserLoggedIn: widget.isUserLoggedIn,)),
                      );

                      if (result == true) {
                        // Navegar de regreso a HomePage con el resultado `true`
                        if (context.mounted) {
                          Navigator.of(context).pop(true);
                        }
                      }
                    },
                  child: OfficeCardMini(
                    imageUrl: office['imageUrl']!,
                    title: office['title']!,
                    description: office['description']!,
                    price: office['price']!,
                    type: office['type']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

