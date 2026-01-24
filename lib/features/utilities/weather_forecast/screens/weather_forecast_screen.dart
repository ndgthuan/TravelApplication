import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:travel_app/features/utilities/weather_forecast/viewmodels/weather_forecast_view_model.dart';
import 'package:travel_app/shared/widgets/app_bar_widget.dart';
import '../widgets/search_section_widget.dart';
import '../widgets/current_weather_card_widget.dart';
import '../widgets/hourly_forecast_widget.dart';
import '../widgets/daily_forecast_widget.dart';

class WeatherForecastScreen extends StatefulWidget {
  const WeatherForecastScreen({super.key});

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  final _searchController = TextEditingController();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;

      // Đợi Flutter xử lý xong hết giao diện rồi mới chạy hàm bên trong
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<WeatherForecastViewModel>().initWeatherData();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WeatherForecastViewModel>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBarWidget(title: 'weather.title'.tr()),
      body: viewModel.isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFFAD35)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Section
                  SearchSectionWidget(
                    controller: _searchController,
                    onSearchChanged: viewModel.searchLocations,
                    searchResults: viewModel.searchResults,
                    isSearching: viewModel.isSearching,
                    onLocationSelected: (location) {
                      viewModel.selectLocation(location);
                      _searchController.clear();
                    },
                  ),
                  const SizedBox(height: 20),

                  // Current Weather Card
                  CurrentWeatherCardWidget(
                    location: viewModel.location,
                    country: viewModel.country,
                    temperature: viewModel.currentTemperature,
                    condition: viewModel.currentCondition(
                      context.locale.languageCode,
                    ),
                    humidity: viewModel.currentHumidity,
                    windSpeed: viewModel.currentWindSpeed,
                    uvIndex: viewModel.currentUvIndex,
                    iconUrl: viewModel.currentIconUrl,
                  ),
                  const SizedBox(height: 20),

                  // Hourly Forecast
                  HourlyForecastWidget(hourlyData: viewModel.getHourlyData()),
                  const SizedBox(height: 20),

                  // Daily Forecast
                  DailyForecastWidget(dailyData: viewModel.getDailyData()),
                ],
              ),
            ),
    );
  }
}
