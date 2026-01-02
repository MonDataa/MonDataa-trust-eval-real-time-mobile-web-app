import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/// ✅ Événement pour charger les catégories
class LoadCategoriesEvent extends CategoryEvent {}

/// ✅ Événement pour créer une catégorie personnalisée
class CreateCustomCategoryEvent extends CategoryEvent {
  final String name;
  final String description;
  final String customLabel;
  final String imageName;

  CreateCustomCategoryEvent(
      this.name, this.description, this.customLabel, this.imageName);

  @override
  List<Object> get props => [name, description, customLabel, imageName];
}
