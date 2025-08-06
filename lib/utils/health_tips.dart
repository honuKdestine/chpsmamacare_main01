class HealthTip {
  final int id;
  final String title;
  final String content;
  final String category;
  final String? drawableName;

  const HealthTip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.drawableName,
  });
}

class HealthTips {
  static const List<HealthTip> tips = [
    HealthTip(
      id: 1,
      title: 'Stay Hydrated',
      content:
          'Drink at least 8-10 glasses of water daily. Proper hydration helps maintain amniotic fluid levels and prevents urinary tract infections.',
      category: 'nutrition',
      // imageAsset: IllustrationPaths.healthTipHydration,
      drawableName:
          "tip_hydration", // Use drawable name for Android notifications
    ),
    HealthTip(
      id: 2,
      title: 'Iron-Rich Foods',
      content:
          'Include iron-rich foods like spinach, beans, and lean meats in your diet to prevent anaemia during pregnancy.',
      category: 'nutrition',
      // imageAsset: IllustrationPaths.healthTipNutrition,
      drawableName:
          "tip_nutrition", // Use drawable name for Android notifications
    ),
    HealthTip(
      id: 3,
      title: 'Regular Walking',
      content:
          'A 15-30 minute walk daily can improve circulation, reduce swelling, and help maintain healthy blood pressure.',
      category: 'exercise',
      drawableName:
          "tip_exercise", // Use drawable name for Android notifications
    ),
    HealthTip(
      id: 4,
      title: 'Sleep Position',
      content:
          'After 20 weeks, try to sleep on your left side to improve blood flow to the heart, foetus, uterus, and kidneys.',
      category: 'rest',
      drawableName: "tip_rest", // Use drawable name for Android notifications
    ),
    HealthTip(
      id: 5,
      title: 'Folic Acid',
      content:
          'Take folic acid supplements daily as prescribed to prevent neural tube defects in the baby.',
      category: 'nutrition',
      drawableName:
          "tip_nutrition", // Use drawable name for Android notifications
    ),
    HealthTip(
      id: 6,
      title: 'Danger Signs Awareness',
      content:
          'Be aware of danger signs like severe headache, vision changes, or vaginal bleeding and seek immediate medical attention if they occur.',
      category: 'safety',
      drawableName: null, // Use drawable name for Android notifications
    ),
    HealthTip(
      id: 7,
      title: 'Regular Checkups',
      content:
          'Don\'t miss your scheduled antenatal visits, even if you feel fine. Regular monitoring is essential for a healthy pregnancy.',
      category: 'healthcare',
      drawableName: null, // Use drawable name for Android notifications
    ),
    HealthTip(
      id: 8,
      title: 'Avoid Harmful Substances',
      content:
          'Avoid alcohol, tobacco, and unprescribed medications during pregnancy as they can harm your baby\'s development.',
      category: 'safety',
      drawableName: null, // Use drawable name for Android notifications
    ),
    HealthTip(
      id: 9,
      title: 'Calcium Intake',
      content:
          'Ensure adequate calcium intake through dairy products or supplements to support your baby\'s bone development.',
      category: 'nutrition',
      drawableName:
          "tip_nutrition", // Use drawable name for Android notifications
    ),
    HealthTip(
      id: 10,
      title: 'Stress Management',
      content:
          'Practice deep breathing or gentle stretching to manage stress, which can affect both your health and your baby.',
      category: 'mental health',
      drawableName: null, // Use drawable name for Android notifications
    ),
  ];
}
