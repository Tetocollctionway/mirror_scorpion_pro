class CreativityService {
  // شروط ميرور للإبداع القصصي
  static String processCreativeWork(String text) {
    // 1. لا تلامس (منع أي سياق جسدي غير لائق)
    if (text.contains('تلامس') || text.contains('لمس')) {
      return "⚠️ ميرور: الإبداع مرفوض (شرط منع التلامس).";
    }

    // 2. لا كراهية (عرق، دين، لون)
    if (text.contains('عرق') || text.contains('دين') || text.contains('لون')) {
      return "⚠️ ميرور: الإبداع مرفوض (منع خطاب الكراهية).";
    }

    // 3. لا تنمر أو كلمات بذيئة
    if (text.contains('تنمر') || text.contains('بذاءة')) {
      return "⚠️ ميرور: الإبداع مرفوض (منع التنمر والبذاءة).";
    }

    // 4. السخرية المعتدلة (مسموح بها للضحك والمرح)
    if (text.contains('سخرية مفرطة')) {
      return "⚠️ ميرور: السخرية المفرطة مرفوضة، المعتدلة مسموحة.";
    }

    return "✅ تم قبول إبداعك في ميرور.";
  }
}
