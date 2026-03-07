import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/meal_model.dart';
import '../controllers/edit_recipe_controller.dart';

class EditRecipePage extends StatefulWidget {
  final MealSummary meal;
  const EditRecipePage({super.key, required this.meal});

  @override
  State<EditRecipePage> createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  late final EditRecipeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EditRecipeController(meal: widget.meal);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final success = await _controller.submit();
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Updated successfully! ✅'),
          backgroundColor: Color(0xFFFF6B35),
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Edit Recipe',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D2D2D),
            elevation: 0,
            actions: [
              TextButton(
                onPressed: _controller.isLoading || _controller.isLoadingDetail
                    ? null
                    : _handleSubmit,
                child: _controller.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFFF6B35),
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: Color(0xFFFF6B35),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
          body: _controller.isLoadingDetail
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
                )
              : Form(
                  key: _controller.formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---- Meal Name ----
                        _buildLabel('Meal Name *'),
                        _buildTextField(
                          controller: _controller.mealNameCtrl,
                          hint: 'e.g. Pad Thai',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),

                        // ---- Category & Area ----
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Category *'),
                                  DropdownButtonFormField<String>(
                                    value: _controller.availableCategories
                                            .contains(
                                              _controller.selectedCategory,
                                            )
                                        ? _controller.selectedCategory
                                        : null,
                                    hint: Text(
                                      'Select category',
                                      style: TextStyle(
                                          color: Colors.grey.shade400),
                                    ),
                                    decoration: _dropdownDecoration(),
                                    items: _controller.availableCategories
                                        .map((cat) => DropdownMenuItem(
                                              value: cat,
                                              child: Text(cat),
                                            ))
                                        .toList(),
                                    onChanged: _controller.selectCategory,
                                    validator: (v) =>
                                        v == null ? 'Required' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Area'),
                                  _buildTextField(
                                    controller: _controller.areaCtrl,
                                    hint: 'e.g. Thai',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // ---- Image ----
                        _buildLabel('Recipe Image'),
                        GestureDetector(
                          onTap: _controller.pickImage,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: _controller.selectedImageBytes != null ||
                                    _controller.selectedImagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: kIsWeb
                                        ? Image.memory(
                                            _controller.selectedImageBytes!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          )
                                        : Image.file(
                                            File(_controller.selectedImagePath!),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                  )
                                : _controller.thumbnailCtrl.text.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Image.network(
                                          _controller.thumbnailCtrl.text,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (_, __, ___) =>
                                              _imagePlaceholder(),
                                        ),
                                      )
                                    : _imagePlaceholder(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ---- YouTube ----
                        _buildLabel('YouTube URL (optional)'),
                        _buildTextField(
                          controller: _controller.youtubeCtrl,
                          hint: 'https://youtube.com/...',
                        ),
                        const SizedBox(height: 16),

                        // ---- Instructions ----
                        _buildLabel('Instructions *'),
                        TextFormField(
                          controller: _controller.instructionsCtrl,
                          maxLines: 6,
                          decoration: InputDecoration(
                            hintText: 'Step by step cooking instructions...',
                            hintStyle:
                                TextStyle(color: Colors.grey.shade400),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade200),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFFFF6B35)),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 24),

                        // ---- Ingredients ----
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ingredients',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _controller.addIngredient,
                              icon: const Icon(Icons.add,
                                  color: Color(0xFFFF6B35)),
                              label: const Text(
                                'Add',
                                style: TextStyle(color: Color(0xFFFF6B35)),
                              ),
                            ),
                          ],
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _controller.ingredients.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _buildTextField(
                                      controller: _controller
                                          .ingredients[index]['name']!,
                                      hint: 'Ingredient',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 2,
                                    child: _buildTextField(
                                      controller: _controller
                                          .ingredients[index]['measure']!,
                                      hint: 'Amount',
                                    ),
                                  ),
                                  IconButton(
                                    onPressed:
                                        _controller.ingredients.length > 1
                                            ? () => _controller
                                                .removeIngredient(index)
                                            : null,
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color:
                                          _controller.ingredients.length > 1
                                              ? Colors.red.shade300
                                              : Colors.grey.shade300,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  // ─── Helper Widgets ───────────────────────────────────────────
  Widget _imagePlaceholder() => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate_outlined,
              size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text('Tap to change image',
              style: TextStyle(color: Colors.grey.shade400)),
        ],
      );

  Widget _buildLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D),
          ),
        ),
      );

  InputDecoration _dropdownDecoration() => InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B35)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      );

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B35)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      validator: validator,
    );
  }
}