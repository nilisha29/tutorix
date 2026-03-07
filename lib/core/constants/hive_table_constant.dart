class HiveTableConstant {
  // Private constructor to prevent instantiation
  HiveTableConstant._();

  // Database name
  // static const String dbName = "tutorix_db";
    static const String dbName = "tutorix_hometutor";


  // Auth Table
  static const int authTypeId = 0;
  static const String authTable = "auth_table";

  // Session box for persisting current logged in user id
  static const String sessionBox = "session_box";
  static const String currentAuthKey = "current_auth_id";

  // Generic cache box for offline page data
  static const String cacheBox = "cache_box";

  // Cache keys
  static const String tutorsCacheKey = "cache_tutors";
  static const String categoriesCacheKey = "cache_categories";
  static const String bookingsCacheKey = "cache_bookings";

}
