import 'package:flutter/material.dart';
import 'package:travel_app/domain/repositories/i_home_repository.dart';
import 'package:travel_app/features/home/models/destination_model.dart';

class HomeViewModel extends ChangeNotifier {
  //==========================================================================//
  //                        DEPENDENCIES                                      //
  //==========================================================================//
  final IHomeRepository _homeRepo;

  HomeViewModel(this._homeRepo);

  //==========================================================================//
  //                        STATE VARIABLES                                   //
  //==========================================================================//
  List<Destination> _popularDestinations = [];
  List<RecommendDestination> _recommendDestinations = [];
  bool _isLoading = true;

  //==========================================================================//
  //                        GETTERS                                           //
  //==========================================================================//
  List<Destination> get popularDestinations => _popularDestinations;
  List<RecommendDestination> get recommendDestinations =>
      _recommendDestinations;
  bool get isLoading => _isLoading;

  //==========================================================================//
  //                        ACTION METHODS                                    //
  //==========================================================================//
  // Load data khi khởi tạo
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _popularDestinations = await _homeRepo.getPopularDestinations();
    _recommendDestinations = await _homeRepo.getRecommendDestinations();

    _isLoading = false;
    notifyListeners();
  }
}
