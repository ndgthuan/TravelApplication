// Interface cho Speech-to-Text và Text-to-Speech
abstract class ISpeechTtsService {
  Future<bool> initialize();

  void listen({
    required void Function(String) onResult,
    required String localeId,
  });

  void stopListening();

  Future<void> speak(String text, String languageCode);

  void copyToClipboard(String text);
}
