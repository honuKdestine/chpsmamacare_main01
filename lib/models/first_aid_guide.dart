class FirstAidGuide {
  final String id;
  final String title;
  final String description;
  final List<FirstAidStep> steps;
  final String imageAsset;
  final String category;

  const FirstAidGuide({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
    required this.imageAsset,
    required this.category,
  });
}

class FirstAidStep {
  final String instruction;
  final String? imageAsset;

  const FirstAidStep({required this.instruction, this.imageAsset});
}

class FirstAidGuides {
  static const List<FirstAidGuide> guides = [
    FirstAidGuide(
      id: 'bleeding',
      title: 'Severe Bleeding',
      description: 'How to manage severe bleeding during pregnancy',
      imageAsset: 'assets/first_aid_guides/bleeding.png',
      category: 'emergency',
      steps: [
        FirstAidStep(
          instruction:
              'Help the mother lie down flat with legs elevated slightly',
          imageAsset: 'assets/first_aid_guides/bleeding_step1.png',
        ),
        FirstAidStep(
          instruction:
              'Apply firm pressure directly to the bleeding site using clean cloth or gauze',
          imageAsset: 'assets/first_aid_guides/bleeding_step2.png',
        ),
        FirstAidStep(
          instruction: 'If available, start IV fluids to prevent shock',
          imageAsset: 'assets/first_aid_guides/bleeding_step3.png',
        ),
        FirstAidStep(
          instruction:
              'Monitor vital signs (pulse, breathing, blood pressure if possible)',
          imageAsset: null,
        ),
        FirstAidStep(
          instruction: 'Arrange immediate transport to the nearest hospital',
          imageAsset: null,
        ),
      ],
    ),
    FirstAidGuide(
      id: 'seizure',
      title: 'Seizures/Convulsions',
      description: 'How to manage seizures or convulsions during pregnancy',
      imageAsset: 'assets/first_aid_guides/seizure.png',
      category: 'emergency',
      steps: [
        FirstAidStep(
          instruction:
              'Help the mother lie on her left side to improve blood flow',
          imageAsset: 'assets/first_aid_guides/seizure_step1.png',
        ),
        FirstAidStep(
          instruction: 'Clear the area of any objects that could cause injury',
          imageAsset: 'assets/first_aid_guides/seizure_step2.png',
        ),
        FirstAidStep(
          instruction:
              'Do not restrain the person or put anything in their mouth',
          imageAsset: 'assets/first_aid_guides/seizure_step3.png',
        ),
        FirstAidStep(
          instruction:
              'Time the seizure - if it lasts more than 5 minutes, it\'s an emergency',
          imageAsset: null,
        ),
        FirstAidStep(
          instruction:
              'After the seizure, keep the mother on her left side and arrange transport',
          imageAsset: null,
        ),
      ],
    ),
    FirstAidGuide(
      id: 'delivery',
      title: 'Emergency Delivery',
      description:
          'What to do in case of imminent delivery without medical help',
      imageAsset: 'assets/first_aid_guides/delivery.png',
      category: 'emergency',
      steps: [
        FirstAidStep(
          instruction:
              'Help the mother into a comfortable position, preferably lying down with knees bent',
          imageAsset: 'assets/first_aid_guides/delivery_step1.png',
        ),
        FirstAidStep(
          instruction:
              'Wash your hands thoroughly with soap and water if possible',
          imageAsset: 'assets/first_aid_guides/delivery_step2.png',
        ),
        FirstAidStep(
          instruction:
              'Place clean cloths or towels under the mother\'s buttocks',
          imageAsset: 'assets/first_aid_guides/delivery_step3.png',
        ),
        FirstAidStep(
          instruction:
              'As the baby delivers, support the head and body, never pull',
          imageAsset: 'assets/first_aid_guides/delivery_step4.png',
        ),
        FirstAidStep(
          instruction:
              'Wipe the baby\'s mouth and nose, and ensure they are breathing',
          imageAsset: 'assets/first_aid_guides/delivery_step5.png',
        ),
        FirstAidStep(
          instruction:
              'Place the baby skin-to-skin on mother\'s chest and cover both with dry cloth',
          imageAsset: null,
        ),
      ],
    ),
  ];
}
