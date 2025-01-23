import 'package:flutter/material.dart';
import '../controller/github_controller.dart';
import '../models/vegetal_model.dart';

class HomePage extends StatefulWidget {
  final GitHubController controller;

  const HomePage({Key? key, required this.controller}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Vegetal>> vegetales;

  @override
  void initState() {
    super.initState();
    vegetales = widget.controller.fetchVegetales().then((data) =>
        data.map((item) => Vegetal.fromJson(item)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        title: const Text('Vegetales CRUD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                vegetales = widget.controller.fetchVegetales().then((data) =>
                    data.map((item) => Vegetal.fromJson(item)).toList());
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Vegetal>>(
        future: vegetales,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final data = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
                childAspectRatio: 1.2, // Reduce the height of each item
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final vegetal = data[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.green[600]!, width: 1),
                  ),
                  elevation: 5,
                  color: Colors.grey[850],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.local_florist, color: Colors.green[500], size: 32),
                        SizedBox(height: 10),
                        Text(
                          vegetal.descripcion,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24, // Increased font size
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Código: ${vegetal.codigo} | Precio: \$${vegetal.precio}',
                          style: TextStyle(
                            color: Colors.green[300],
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () async {
                                final updatedVegetal = await _showEditDialog(context, vegetal);
                                if (updatedVegetal != null) {
                                  setState(() {
                                    data[index] = updatedVegetal;
                                  });
                                  await _updateGitHub(data);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                setState(() {
                                  data.removeAt(index);
                                });
                                await _updateGitHub(data);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[700],
        child: const Icon(Icons.add),
        onPressed: () async {
          final newVegetal = await _showAddDialog(context);
          if (newVegetal != null) {
            setState(() {
              vegetales = widget.controller.fetchVegetales().then((data) =>
                  data.map((item) => Vegetal.fromJson(item)).toList());
            });
            final updatedData = await vegetales;
            updatedData.add(newVegetal);
            await _updateGitHub(updatedData);
          }
        },
      ),
    );
  }

  Future<Vegetal?> _showEditDialog(BuildContext context, Vegetal vegetal) async {
    final TextEditingController descripcionController = TextEditingController(text: vegetal.descripcion);
    final TextEditingController precioController = TextEditingController(text: vegetal.precio.toString());

    return showDialog<Vegetal>(context: context, builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Editar Vegetal', style: TextStyle(color: Colors.white)),
        content: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción', labelStyle: TextStyle(color: Colors.white)),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: precioController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Precio', labelStyle: TextStyle(color: Colors.white)),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  if (double.tryParse(value) == null || double.tryParse(value)! < 0) {
                    return 'Ingrese un precio válido y mayor o igual a cero';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              if (descripcionController.text.isNotEmpty &&
                  precioController.text.isNotEmpty &&
                  double.tryParse(precioController.text)! >= 0) {
                final updatedVegetal = Vegetal(
                  codigo: vegetal.codigo,
                  descripcion: descripcionController.text,
                  precio: double.tryParse(precioController.text) ?? vegetal.precio,
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Vegetal actualizado exitosamente'),
                  backgroundColor: Colors.green,
                ));
                Navigator.pop(context, updatedVegetal);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Por favor, complete todos los campos correctamente.'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text('Actualizar', style: TextStyle(color: Colors.green)),
          ),
        ],
      );
    });
  }

  Future<Vegetal?> _showAddDialog(BuildContext context) async {
    final TextEditingController codigoController = TextEditingController();
    final TextEditingController descripcionController = TextEditingController();
    final TextEditingController precioController = TextEditingController();

    return showDialog<Vegetal>(context: context, builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.grey[850],
        title: const Text('Agregar Vegetal', style: TextStyle(color: Colors.white)),
        content: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: codigoController,
                decoration: const InputDecoration(labelText: 'Código', labelStyle: TextStyle(color: Colors.white)),
                style: const TextStyle(color: Colors.white),
              ),
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción', labelStyle: TextStyle(color: Colors.white)),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: precioController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Precio', labelStyle: TextStyle(color: Colors.white)),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  if (double.tryParse(value) == null || double.tryParse(value)! < 0) {
                    return 'Ingrese un precio válido y mayor o igual a cero';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              if (codigoController.text.isNotEmpty &&
                  descripcionController.text.isNotEmpty &&
                  precioController.text.isNotEmpty &&
                  double.tryParse(precioController.text)! >= 0) {

                final existingVegetales = await vegetales;
                final existingCodes = existingVegetales.map((v) => v.codigo).toList();

                int newCodigo = int.tryParse(codigoController.text) ?? DateTime.now().millisecondsSinceEpoch;

                if (existingCodes.contains(newCodigo)) {
                  // Si el código ya existe, mostrar un mensaje de error
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('El código ya existe. Por favor, ingrese un código único.'),
                    backgroundColor: Colors.red,
                  ));
                } else {
                  final newVegetal = Vegetal(
                    codigo: newCodigo,
                    descripcion: descripcionController.text,
                    precio: double.tryParse(precioController.text) ?? 0.0,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Vegetal agregado exitosamente'),
                    backgroundColor: Colors.green,
                  ));
                  Navigator.pop(context, newVegetal);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Por favor, complete todos los campos correctamente.'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text('Agregar', style: TextStyle(color: Colors.green)),
          ),
        ],
      );
    });
  }

  Future<void> _updateGitHub(List<Vegetal> data) async {
    await widget.controller.updateVegetales(
      data.map((v) => v.toJson()).toList(),
    );
  }
}
