String resolveBaseUrl() {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) return override;

  // On web, use localhost when backend runs locally
  return 'http://localhost:3000/api';
}
