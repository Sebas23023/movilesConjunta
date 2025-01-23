import 'package:flutter/material.dart';
import '../models/vegetal_model.dart';

class VegetalForm extends StatefulWidget {
  final Vegetal? vegetal;

  VegetalForm({this.vegetal});

  @override
  _VegetalFormState createState() => _VegetalFormState();
}

class _VegetalFormState extends State<VegetalForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;

  @override
  void initState() {
    super.initState();
    _descripcionController = TextEditingController(
      text: widget.vegetal?.descripcion ?? '',
    );
    _precioController = TextEditingController(
      text: widget.vegetal?.precio.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final vegetal = Vegetal(
        codigo: widget.vegetal?.codigo ?? DateTime.now().millisecondsSinceEpoch,
        descripcion: _descripcionController.text,
        precio: double.tryParse(_precioController.text) ?? 0.0,
      );
      Navigator.of(context).pop(vegetal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.vegetal == null ? 'Añadir Vegetal' : 'Editar Vegetal'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _descripcionController,
              decoration: InputDecoration(labelText: 'Descripción'),
              validator: (value) =>
              value == null || value.isEmpty ? 'Campo requerido' : null,
            ),
            TextFormField(
              controller: _precioController,
              decoration: InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final price = double.tryParse(value ?? '');
                if (price == null || price <= 0) {
                  return 'Introduce un precio válido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: Text('Guardar'),
        ),
      ],
    );
  }
}
