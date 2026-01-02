import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repository/CategoryRepository.dart';
import 'category_events.dart';
import 'category_states.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryBloc(this.categoryRepository) : super(CategoryInitialState()) {
    /// ✅ Charger les catégories
    on<LoadCategoriesEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        final categories = await categoryRepository.getCategories();
        emit(CategoryListSuccessState(categories));
      } catch (e) {
        emit(CategoryErrorState("Erreur : $e"));
      }
    });

    /// ✅ Créer une catégorie personnalisée
    on<CreateCustomCategoryEvent>((event, emit) async {
      emit(CategoryLoadingState());
      try {
        final category = await categoryRepository.createCustomCategory(
          event.name,
          event.description,
          event.customLabel,
          event.imageName,
        );
        if (category != null) {
          emit(CategorySuccessState(category));
        } else {
          emit(CategoryErrorState("Échec de la création de la catégorie"));
        }
      } catch (e) {
        emit(CategoryErrorState("Erreur : $e"));
      }
    });
  }
}
