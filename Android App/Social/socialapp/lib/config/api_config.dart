class ApiConfig {
  // Use the correct IP address for your device
  // For Android devices connecting to your computer's localhost, use your computer's IP address on your local network
  static const String baseUrl = 'http://172.25.170.121:4000'; // Replace with your actual computer's IP address

  // Alternatives (commented out):
  // static const String baseUrl = 'http://10.0.2.2:4000'; // For Android emulator connecting to localhost
  // static const String baseUrl = 'http://localhost:4000'; // For iOS simulator

  // Updated endpoints with /api prefix to match server routes
  static const String authEndpoint = '/api/auth';
  static const String userEndpoint = '/api/user';
  static const String postEndpoint = '/api/post';
  static const String uploadEndpoint = '/api/upload';
  static const String engagementEndpoint = '/api/engagement';
}