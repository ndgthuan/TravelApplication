// Interface cho Weather Config: icon URL, mô tả theo weather code
abstract class IWeatherConfigService {
  bool get isLoaded;

  Future<void> loadConfigs();

  String getWeatherIconUrl(int code, bool isDay);

  String getWeatherText(int code, String langCode);
}
