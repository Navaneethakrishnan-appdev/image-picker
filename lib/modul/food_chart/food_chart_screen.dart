import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodChartScreen extends StatefulWidget {
  const FoodChartScreen({super.key});

  @override
  State<FoodChartScreen> createState() => _FoodChartScreenState();
}

class _FoodChartScreenState extends State<FoodChartScreen> {
  String selectedGoal = 'Weight Loss';

  final Map<String, List<Map<String, dynamic>>> mealPlans = {
    'Weight Loss': [
      {
        'meal': 'Breakfast (7:00 AM - 8:00 AM)',
        'description': 'Start your day with a protein-rich breakfast',
        'foods': [
          {'name': 'Greek Yogurt with Berries', 'calories': '150 kcal', 'protein': '15g', 'portion': '1 cup yogurt + 1/2 cup berries'},
          {'name': 'Oatmeal with Almonds', 'calories': '200 kcal', 'protein': '8g', 'portion': '1/2 cup oats + 10 almonds'},
          {'name': 'Egg White Omelet', 'calories': '120 kcal', 'protein': '20g', 'portion': '3 egg whites + vegetables'},
        ],
      },
      {
        'meal': 'Morning Snack (10:00 AM - 11:00 AM)',
        'description': 'Light snack to maintain energy levels',
        'foods': [
          {'name': 'Apple with Almond Butter', 'calories': '150 kcal', 'protein': '4g', 'portion': '1 medium apple + 1 tbsp almond butter'},
          {'name': 'Protein Shake', 'calories': '120 kcal', 'protein': '20g', 'portion': '1 scoop protein powder + water'},
        ],
      },
      {
        'meal': 'Lunch (1:00 PM - 2:00 PM)',
        'description': 'Balanced meal with lean protein and vegetables',
        'foods': [
          {'name': 'Grilled Chicken Salad', 'calories': '300 kcal', 'protein': '35g', 'portion': '4 oz chicken + mixed greens'},
          {'name': 'Quinoa Bowl', 'calories': '350 kcal', 'protein': '15g', 'portion': '1/2 cup quinoa + vegetables'},
        ],
      },
      {
        'meal': 'Afternoon Snack (4:00 PM - 5:00 PM)',
        'description': 'Pre-workout energy boost',
        'foods': [
          {'name': 'Greek Yogurt with Honey', 'calories': '130 kcal', 'protein': '12g', 'portion': '1/2 cup yogurt + 1 tsp honey'},
          {'name': 'Protein Bar', 'calories': '200 kcal', 'protein': '20g', 'portion': '1 bar'},
        ],
      },
      {
        'meal': 'Dinner (7:00 PM - 8:00 PM)',
        'description': 'Light dinner with protein and vegetables',
        'foods': [
          {'name': 'Baked Fish with Vegetables', 'calories': '250 kcal', 'protein': '30g', 'portion': '4 oz fish + 2 cups vegetables'},
          {'name': 'Turkey Stir-Fry', 'calories': '300 kcal', 'protein': '25g', 'portion': '4 oz turkey + vegetables'},
        ],
      },
    ],
    'Muscle Gain': [
      {
        'meal': 'Breakfast (7:00 AM - 8:00 AM)',
        'description': 'High-protein breakfast to start muscle building',
        'foods': [
          {'name': 'Protein Pancakes', 'calories': '400 kcal', 'protein': '30g', 'portion': '3 pancakes + 1 scoop protein'},
          {'name': 'Eggs with Toast', 'calories': '450 kcal', 'protein': '25g', 'portion': '4 whole eggs + 2 slices whole grain toast'},
        ],
      },
      {
        'meal': 'Morning Snack (10:00 AM - 11:00 AM)',
        'description': 'Protein-rich snack',
        'foods': [
          {'name': 'Protein Shake with Banana', 'calories': '300 kcal', 'protein': '25g', 'portion': '1 scoop protein + 1 banana'},
          {'name': 'Cottage Cheese with Nuts', 'calories': '250 kcal', 'protein': '20g', 'portion': '1 cup cottage cheese + 1/4 cup nuts'},
        ],
      },
      {
        'meal': 'Lunch (1:00 PM - 2:00 PM)',
        'description': 'High-calorie, protein-rich meal',
        'foods': [
          {'name': 'Chicken Rice Bowl', 'calories': '600 kcal', 'protein': '40g', 'portion': '6 oz chicken + 1 cup rice'},
          {'name': 'Steak with Sweet Potato', 'calories': '550 kcal', 'protein': '35g', 'portion': '6 oz steak + 1 medium sweet potato'},
        ],
      },
      {
        'meal': 'Pre-Workout (4:00 PM - 5:00 PM)',
        'description': 'Energy-boosting pre-workout meal',
        'foods': [
          {'name': 'Protein Smoothie', 'calories': '350 kcal', 'protein': '30g', 'portion': '1 scoop protein + fruits + milk'},
          {'name': 'Peanut Butter Sandwich', 'calories': '400 kcal', 'protein': '15g', 'portion': '2 slices bread + 2 tbsp peanut butter'},
        ],
      },
      {
        'meal': 'Dinner (7:00 PM - 8:00 PM)',
        'description': 'High-protein dinner for muscle recovery',
        'foods': [
          {'name': 'Salmon with Quinoa', 'calories': '500 kcal', 'protein': '35g', 'portion': '6 oz salmon + 1 cup quinoa'},
          {'name': 'Beef Stir-Fry', 'calories': '550 kcal', 'protein': '40g', 'portion': '6 oz beef + vegetables + rice'},
        ],
      },
      {
        'meal': 'Evening Snack (9:00 PM - 10:00 PM)',
        'description': 'Casein protein for overnight recovery',
        'foods': [
          {'name': 'Casein Protein Shake', 'calories': '200 kcal', 'protein': '25g', 'portion': '1 scoop casein protein'},
          {'name': 'Greek Yogurt with Nuts', 'calories': '250 kcal', 'protein': '20g', 'portion': '1 cup yogurt + 1/4 cup nuts'},
        ],
      },
    ],
    'Maintenance': [
      {
        'meal': 'Breakfast (7:00 AM - 8:00 AM)',
        'description': 'Balanced breakfast to start the day',
        'foods': [
          {'name': 'Avocado Toast with Eggs', 'calories': '350 kcal', 'protein': '15g', 'portion': '2 slices toast + 1/2 avocado + 2 eggs'},
          {'name': 'Overnight Oats', 'calories': '300 kcal', 'protein': '12g', 'portion': '1/2 cup oats + milk + fruits'},
        ],
      },
      {
        'meal': 'Morning Snack (10:00 AM - 11:00 AM)',
        'description': 'Healthy mid-morning snack',
        'foods': [
          {'name': 'Fruit with Nuts', 'calories': '200 kcal', 'protein': '5g', 'portion': '1 apple + 1/4 cup mixed nuts'},
          {'name': 'Yogurt Parfait', 'calories': '250 kcal', 'protein': '10g', 'portion': '1 cup yogurt + granola + berries'},
        ],
      },
      {
        'meal': 'Lunch (1:00 PM - 2:00 PM)',
        'description': 'Balanced lunch with protein and carbs',
        'foods': [
          {'name': 'Mediterranean Bowl', 'calories': '450 kcal', 'protein': '20g', 'portion': '4 oz chicken + vegetables + hummus'},
          {'name': 'Whole Grain Wrap', 'calories': '400 kcal', 'protein': '18g', 'portion': '1 wrap + turkey + vegetables'},
        ],
      },
      {
        'meal': 'Afternoon Snack (4:00 PM - 5:00 PM)',
        'description': 'Energy-boosting snack',
        'foods': [
          {'name': 'Smoothie Bowl', 'calories': '300 kcal', 'protein': '8g', 'portion': '1 cup smoothie + toppings'},
          {'name': 'Trail Mix', 'calories': '250 kcal', 'protein': '6g', 'portion': '1/4 cup mix'},
        ],
      },
      {
        'meal': 'Dinner (7:00 PM - 8:00 PM)',
        'description': 'Balanced dinner',
        'foods': [
          {'name': 'Grilled Fish with Vegetables', 'calories': '400 kcal', 'protein': '25g', 'portion': '5 oz fish + 2 cups vegetables'},
          {'name': 'Vegetable Stir-Fry with Tofu', 'calories': '350 kcal', 'protein': '20g', 'portion': '4 oz tofu + vegetables + rice'},
        ],
      },
    ],
    'Yoga Diet': [
      {
        'meal': 'Early Morning (6:00 AM - 7:00 AM)',
        'description': 'Light, energizing breakfast before morning yoga',
        'foods': [
          {'name': 'Warm Lemon Water', 'calories': '5 kcal', 'protein': '0g', 'portion': '1 glass with 1/2 lemon'},
          {'name': 'Banana with Almonds', 'calories': '150 kcal', 'protein': '4g', 'portion': '1 banana + 10 almonds'},
          {'name': 'Overnight Chia Pudding', 'calories': '180 kcal', 'protein': '6g', 'portion': '2 tbsp chia seeds + almond milk'},
        ],
      },
      {
        'meal': 'Post-Yoga Breakfast (8:30 AM - 9:30 AM)',
        'description': 'Nourishing meal after yoga practice',
        'foods': [
          {'name': 'Fruit Smoothie Bowl', 'calories': '250 kcal', 'protein': '8g', 'portion': 'Mixed fruits + yogurt + granola'},
          {'name': 'Avocado Toast', 'calories': '220 kcal', 'protein': '6g', 'portion': 'Whole grain toast + 1/2 avocado'},
          {'name': 'Quinoa Porridge', 'calories': '200 kcal', 'protein': '7g', 'portion': '1/2 cup quinoa + fruits + nuts'},
        ],
      },
      {
        'meal': 'Mid-Morning Snack (11:00 AM - 12:00 PM)',
        'description': 'Light, energizing snack',
        'foods': [
          {'name': 'Fresh Fruit Salad', 'calories': '120 kcal', 'protein': '2g', 'portion': 'Mixed seasonal fruits'},
          {'name': 'Coconut Water', 'calories': '45 kcal', 'protein': '0g', 'portion': '1 glass'},
        ],
      },
      {
        'meal': 'Lunch (1:00 PM - 2:00 PM)',
        'description': 'Balanced, sattvic meal',
        'foods': [
          {'name': 'Vegetable Khichdi', 'calories': '300 kcal', 'protein': '10g', 'portion': 'Rice + lentils + vegetables'},
          {'name': 'Mediterranean Bowl', 'calories': '350 kcal', 'protein': '12g', 'portion': 'Quinoa + vegetables + hummus'},
        ],
      },
      {
        'meal': 'Afternoon Snack (4:00 PM - 5:00 PM)',
        'description': 'Pre-evening yoga snack',
        'foods': [
          {'name': 'Herbal Tea with Dates', 'calories': '100 kcal', 'protein': '1g', 'portion': '1 cup tea + 2 dates'},
          {'name': 'Sprouted Mung Beans', 'calories': '80 kcal', 'protein': '6g', 'portion': '1/2 cup sprouts'},
        ],
      },
      {
        'meal': 'Dinner (7:00 PM - 8:00 PM)',
        'description': 'Light, early dinner',
        'foods': [
          {'name': 'Vegetable Soup', 'calories': '200 kcal', 'protein': '8g', 'portion': '2 cups soup with vegetables'},
          {'name': 'Steamed Vegetables with Tofu', 'calories': '250 kcal', 'protein': '15g', 'portion': 'Mixed vegetables + 4 oz tofu'},
        ],
      },
    ],
  };

  static IconData getFoodIcon(String foodName) {
    foodName = foodName.toLowerCase();
    if (foodName.contains('yogurt') || foodName.contains('cheese')) {
      return Icons.egg_alt;
    } else if (foodName.contains('shake') || foodName.contains('smoothie')) {
      return Icons.local_drink;
    } else if (foodName.contains('chicken') || foodName.contains('turkey') || 
               foodName.contains('beef') || foodName.contains('fish') || 
               foodName.contains('salmon') || foodName.contains('tuna')) {
      return Icons.set_meal;
    } else if (foodName.contains('egg')) {
      return Icons.egg;
    } else if (foodName.contains('toast') || foodName.contains('bread') || 
               foodName.contains('oats') || foodName.contains('rice') || 
               foodName.contains('quinoa')) {
      return Icons.grain;
    } else if (foodName.contains('salad') || foodName.contains('vegetable') || 
               foodName.contains('broccoli') || foodName.contains('spinach')) {
      return Icons.eco;
    } else if (foodName.contains('fruit') || foodName.contains('apple') || 
               foodName.contains('banana') || foodName.contains('berry')) {
      return Icons.apple;
    } else if (foodName.contains('nut') || foodName.contains('almond') || 
               foodName.contains('peanut')) {
      return Icons.catching_pokemon;
    } else if (foodName.contains('avocado')) {
      return Icons.spa;
    } else if (foodName.contains('protein')) {
      return Icons.fitness_center;
    } else {
      return Icons.restaurant;
    }
  }

  static IconData getGoalIcon(String goal) {
    switch (goal) {
      case 'Weight Loss':
        return Icons.trending_down;
      case 'Muscle Gain':
        return Icons.fitness_center;
      case 'Maintenance':
        return Icons.balance;
      case 'Yoga Diet':
        return Icons.self_improvement;
      default:
        return Icons.fitness_center;
    }
  }

  static String getGoalDescription(String goal) {
    switch (goal) {
      case 'Weight Loss':
        return 'Focus on calorie deficit and healthy eating';
      case 'Muscle Gain':
        return 'High protein diet for muscle building';
      case 'Maintenance':
        return 'Balanced diet for weight maintenance';
      case 'Yoga Diet':
        return 'Sattvic diet for yoga practitioners';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffC1E2A4),
        title: Text(
          'Meal Plan Schedule',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.navigate_before, size: 35, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Theme(
                data: Theme.of(context).copyWith(
                  popupMenuTheme: PopupMenuThemeData(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    color: Colors.white,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedGoal,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Select Your Goal',
                    labelStyle: GoogleFonts.outfit(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xffC1E2A4)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xffC1E2A4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xffC1E2A4), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xffC1E2A4).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Color(0xffC1E2A4),
                      ),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xffC1E2A4).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_drop_down,
                      color: Color(0xffC1E2A4),
                    ),
                  ),
                  selectedItemBuilder: (BuildContext context) {
                    return ['Weight Loss', 'Muscle Gain', 'Maintenance', 'Yoga Diet'].map((String value) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          value,
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },
                  items: ['Weight Loss', 'Muscle Gain', 'Maintenance', 'Yoga Diet']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xffC1E2A4).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                getGoalIcon(value),
                                color: const Color(0xffC1E2A4),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                value,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: selectedGoal == value
                                    ? const Color(0xffC1E2A4).withOpacity(0.2)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: selectedGoal == value
                                    ? const Color(0xffC1E2A4)
                                    : Colors.transparent,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedGoal = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: mealPlans[selectedGoal]?.length ?? 0,
                itemBuilder: (context, index) {
                  final meal = mealPlans[selectedGoal]?[index];
                  if (meal == null) return const SizedBox.shrink();
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Color(0xffC1E2A4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xffC1E2A4).withOpacity(0.2),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                meal['meal'] ?? '',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xffC1E2A4),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                meal['description'] ?? '',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: meal['foods']?.length ?? 0,
                          itemBuilder: (context, foodIndex) {
                            final food = meal['foods']?[foodIndex];
                            if (food == null) return const SizedBox.shrink();
                            
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xffC1E2A4).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  getFoodIcon(food['name'] ?? ''),
                                  color: const Color(0xffC1E2A4),
                                  size: 24,
                                ),
                              ),
                              title: Text(
                                food['name'] ?? '',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${food['calories'] ?? ''} • Protein: ${food['protein'] ?? ''}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    'Portion: ${food['portion'] ?? ''}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
} 