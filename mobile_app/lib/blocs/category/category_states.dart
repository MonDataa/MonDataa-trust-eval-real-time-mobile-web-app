import 'package:equatable/equatable.dart';
import '../../models/CategoryModel.dart';

abstract class CategoryState extends Equatable {
  @override
  List<Object> get props => [];
}

/// ✅ État initial
class CategoryInitialState extends CategoryState {}

/// ✅ État de chargement
class CategoryLoadingState extends CategoryState {}

/// ✅ État lorsqu'une seule catégorie est créée avec succès
class CategorySuccessState extends CategoryState {
  final CategoryModel category;
  CategorySuccessState(this.category);

  @override
  List<Object> get props => [category];
}

/// ✅ État lorsqu'on récupère la liste des catégories avec succès
class CategoryListSuccessState extends CategoryState {
  final List<CategoryModel> categories;
  CategoryListSuccessState(this.categories);

  @override
  List<Object> get props => [categories];
}

/// ✅ État en cas d'erreur
class CategoryErrorState extends CategoryState {
  final String message;
  CategoryErrorState(this.message);

  @override
  List<Object> get props => [message];
}
