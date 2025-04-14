class ApiConfig {
  static const String baseUrl = 'https://wellstaserver.onrender.com'; // Replace with your actual server URL

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