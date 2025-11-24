import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/child.dart';
import '../models/article.dart';
import 'child_screen.dart';
import 'article_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Child> children = [];
  final TextEditingController nameController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageYearsController = TextEditingController();
  final TextEditingController ageMonthsController = TextEditingController();
  bool showMonthsField = false;
  
  final List<Article> articles = [
    Article(
      title: "Важная информация при повышении температуры",
      content: "• Подъём температуры во время ОРВИ - это обычное течение инфекции. Это необходимо для того чтобы организм боролся с её возбудителем. Цель при применении жаропонижающих препаратов заключается в том чтобы снизить высокую температуру, которая может угрожать жизни и здоровью ребёнка и снять дискомфорт, который, к слову, может возникать и при не слишком высоких значениях. Для каждого возраста есть своя условная верхняя граница температуры, при пересечении которой стоит дать лекарство, обратиться к педиатру или вызвать скорую помощь.\n\n• Для детей до 12 лет есть лишь два безопасных препарата - Ибупрофен и Парацетамол. Форма лекарства зависит от симптомов, предпочтений и возраста. Малышам обычно дают в форме сиропа.\n\n• Все расчёты любых лекарств для ребёнка идут на килограмм массы тела. В 3 года малыш может весить 11 кг, а может 30 кг. Естественно, необходимая доза будет разной.\n\n• Жаропонижающее можно давать через 6 и 8 часов, а температура может повышаться каждые 3 часа. Поэтому, чтобы не допустить передозировки лекарств, их необходимо чередовать.\n\n• Ребёнок не должен быть укрыт тремя одеялами. Одеяло служит для сохранения тепла, так же как и одежда. Просто по законам физики температура может уходить только в окружающую среду. Форма одежды больного ребёнка с повышенной температурой: майка с открытыми рукавами, хлопчатобумажные трусики без подгузника. Если ножки холодные, то можно надеть шерстяные носки без резинки, чем более колючие, тем лучше.\n\n• Удовлетворительным эффектом от приёма жаропонижающего средства считается снижение на 0,5 градуса за 1,5 часа. Более того, не следует снижать температуру до нормальных цифр. Любое заболевание имеет своё течение. В большинстве случаев оптимальной температурой считается +/- 38,0.\n\n• Однако, температура выше 38,0 у ребёнка младше 3-х месяцев - повод для срочного обращения к педиатру. ОРВИ у детей этого возраста - показание для госпитализации. Лечение дома только на свой страх и риск.\n\n• Подъём температуры тела выше 38,5 более 3-х дней и общая продолжительность лихорадки дольше 5-ти дней (выше 37,5) это повод для обращения к педиатру на предмет исключения возможных бактериальных осложнений вирусной инфекции.\n\n• Значительные перепады температуры тела многократно в течение суток (37,0-40,5- 37,0) — повод для обращения к педиатру.\n\n• Появление сыпи: пузырьки, красные пятна, волдыри (пятна, возвышающиеся над уровнем здоровой кожи) - повод для обращения к педиатру.\n\n• Кровоизлияния в кожу, появление синяков без травмы, ярко красная сыпь, которая при надавливании не исчезает («проба стаканом» - нажимаем на кожу стеклянным прозрачным стаканом, если сыпь не изменилась, проба положительная) - повод для вызова Скорой помощи.\n\n• Боль в ухе - повод для обращения к педиатру, лучше к ЛОРу.\n\n• Боль в ухе и выделения из слухового хода - немедленное прекращение любых капель в уши и повод для обращения к педиатру, лучше к ЛОРу.\n\n• Отсутствие эффекта от последовательного приёма двух жаропонижающих. Дали Парацетамол, через 1,5 часа снижение меньше чем 0,5 градуса. Даём Ибупрофен. Если через 1,5 часа снова нет эффекта —повод для вызова Скорой помощи.\n\n• Изменение сознания: спит и не просыпается, резкая слабость вплоть до отсутствия возможности перемещаться. На обращённую речь реагирует с ощутимой задержкой. Не узнаёт окружающих. Бред, галлюцинации. Особенно, если нет связи с высокими цифрами температуры - повод для вызова Скорой помощи.\n\n• Неадекватно повышенная чувствительность к раздражителям: свет, звук, прикосновение - повод для вызова Скорой помощи.\n\n• Головная боль, не купирующаяся (не проходящая) приёмом жаропонижающих (НПВС) - повод для вызова Скорой помощи.\n\nДля маленьких детей монотонный крик с запрокидыванием головы назад - повод для вызова Скорой помощи.\n\n• Судороги и иные состояния, сопровождающиеся потерей сознания - повод для вызова Скорой помощи.\n\n• Боль в пояснице, мутная моча, красная моча, отсутствие мочи больше 8 часов - повод для вызова Скорой помощи.\n\n• Одышка - повод для вызова Скорой помощи.\n\n• Многократная рвота, жидкий стул - повод для вызова Скорой помощи.\n\n• При необходимости применения жаропонижающего на фоне рвоты и жидкого стула - повод для вызова Скорой помощи.",
    ),
    Article(
      title: "Первая помощь, если у ребенка судороги",
      content: "Как отличить озноб от фебрильных судорог?\n\n• При ознобе сознание сохраняется\n\n• При фебрильных судорогах ребенок теряет сознание\n\nЕсли начались судороги, то:\n\nОбеспечить безопасность чтобы не упал и не получил травму во время приступа. Маленького взять на руки.\nНельзя засовывать предметы в рот: пальцы, ложки. Даже если прикушен язык и изо рта идёт красная пена.\nПоложение тела любое, кроме лежа на спине.\nСразу вызвать Скорую. Больше до её приезда ничего нельзя предпринимать.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? childrenJson = prefs.getString('children');
    
    if (childrenJson != null) {
      final List<dynamic> childrenList = json.decode(childrenJson);
      setState(() {
        children = childrenList.map((json) => Child.fromJson(json)).toList();
      });
    }
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String childrenJson = json.encode(
      children.map((child) => child.toJson()).toList(),
    );
    await prefs.setString('children', childrenJson);
  }

  void createChild() {
    final String name = nameController.text.trim();
    final String weightText = weightController.text.trim().replaceAll(',', '.');
    final String ageYearsText = ageYearsController.text.trim();
    final String ageMonthsText = ageMonthsController.text.trim();
    
    if (name.isEmpty || weightText.isEmpty || ageYearsText.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка'),
          content: Text('Заполните все поля'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    
    if (showMonthsField && ageMonthsText.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка'),
          content: Text('Укажите возраст в месяцах'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final double? weight = double.tryParse(weightText);
    final int? ageYears = int.tryParse(ageYearsText);
    final int? ageMonths = showMonthsField ? int.tryParse(ageMonthsText) : null;
    
    if (weight == null || weight <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка'),
          content: Text('Введите корректный вес'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    
    if (ageYears == null || ageYears < 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка'),
          content: Text('Введите корректный возраст'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    
    if (showMonthsField && (ageMonths == null || ageMonths < 0 || ageMonths > 11)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Ошибка'),
          content: Text('Возраст в месяцах должен быть от 0 до 11'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final int totalAge = showMonthsField ? ageMonths! : ageYears;

    // Проверка веса для детей до 11 месяцев
    if (showMonthsField && ageMonths! <= 11) {
      double minWeight = 0;
      double maxWeight = 0;
      
      switch (ageMonths!) {
        case 1: minWeight = 2; maxWeight = 5; break;
        case 2: minWeight = 3; maxWeight = 6; break;
        case 3: minWeight = 4; maxWeight = 7; break;
        case 4: minWeight = 5; maxWeight = 8; break;
        case 5: minWeight = 5; maxWeight = 9; break;
        case 6: minWeight = 6; maxWeight = 10; break;
        case 7: minWeight = 6; maxWeight = 11; break;
        case 8: minWeight = 6; maxWeight = 11; break;
        case 9: minWeight = 7; maxWeight = 11; break;
        case 10: minWeight = 7; maxWeight = 12; break;
        case 11: minWeight = 7; maxWeight = 12; break;
        default: return; // Нет проверки для 0 месяцев
      }
      
      if (weight < minWeight || weight > maxWeight) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('⚠️ Внимание!', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            content: Text('Указанный вес ребёнка значительно отличается от средних возрастных показателей. Внимательно проверьте правильность введённых данных.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    children.add(Child(name: name, weight: weight, age: totalAge));
                  });
                  _completeChildCreation(name);
                },
                child: Text('Всё равно создать'),
              ),
            ],
          ),
        );
        return;
      }
    }
    
    // Проверка веса для детей от 1 до 5 лет
    if (!showMonthsField && ageYears >= 1 && ageYears <= 5) {
      double minWeight = 0;
      double maxWeight = 0;
      
      switch (ageYears) {
        case 1: minWeight = 8; maxWeight = 13; break;
        case 2: minWeight = 10; maxWeight = 15; break;
        case 3: minWeight = 11; maxWeight = 18; break;
        case 4: minWeight = 13; maxWeight = 20; break;
        case 5: minWeight = 14; maxWeight = 24; break;
      }
      
      if (weight < minWeight || weight > maxWeight) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('⚠️ Внимание!', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            content: Text('Указанный вес ребёнка значительно отличается от средних возрастных показателей. Внимательно проверьте правильность введённых данных.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    children.add(Child(name: name, weight: weight, age: totalAge));
                  });
                  _completeChildCreation(name);
                },
                child: Text('Всё равно создать'),
              ),
            ],
          ),
        );
        return;
      }
    }
    
    // Проверка веса для детей от 6 до 17 лет
    if (!showMonthsField && ageYears >= 6 && ageYears <= 17) {
      double minWeight = 0;
      double maxWeight = 0;
      
      switch (ageYears) {
        case 6: minWeight = 16; maxWeight = 27; break;
        case 7: minWeight = 17; maxWeight = 32; break;
        case 8: minWeight = 20; maxWeight = 36; break;
        case 9: minWeight = 21; maxWeight = 41; break;
        case 10: minWeight = 22; maxWeight = 47; break;
        case 11: minWeight = 24; maxWeight = 55; break;
        case 12: minWeight = 27; maxWeight = 63; break;
        case 13: minWeight = 32; maxWeight = 69; break;
        case 14: minWeight = 37; maxWeight = 72; break;
        case 15: minWeight = 42; maxWeight = 78; break;
        case 16: minWeight = 45; maxWeight = 84; break;
        case 17: minWeight = 46; maxWeight = 90; break;
      }
      
      if (weight < minWeight || weight > maxWeight) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('⚠️ Внимание!', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            content: Text('Указанный вес ребёнка значительно отличается от средних возрастных показателей. Внимательно проверьте правильность введённых данных.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    children.add(Child(name: name, weight: weight, age: totalAge));
                  });
                  _completeChildCreation(name);
                },
                child: Text('Всё равно создать'),
              ),
            ],
          ),
        );
        return;
      }
    }

    setState(() {
      children.add(Child(name: name, weight: weight, age: totalAge));
    });
    _completeChildCreation(name);
  }

  void _completeChildCreation(String name) {
    nameController.clear();
    weightController.clear();
    ageYearsController.clear();
    ageMonthsController.clear();
    setState(() {
      showMonthsField = false;
    });
    saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Карточка $name создана!'),
        backgroundColor: Color(0xFF4A90A4),
      ),
    );
  }

  void editChild(Child child) {
    final nameController = TextEditingController(text: child.name);
    final weightController = TextEditingController(text: child.weight.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Редактировать данные'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Имя ребенка',
                prefixIcon: Icon(Icons.child_care),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: weightController,
              decoration: InputDecoration(
                labelText: 'Вес (кг)',
                prefixIcon: Icon(Icons.monitor_weight),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final weightText = weightController.text.trim().replaceAll(',', '.');
              final weight = double.tryParse(weightText);
              
              if (name.isNotEmpty && weight != null && weight > 0) {
                setState(() {
                  child.name = name;
                  child.weight = weight;
                });
                saveData();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Данные обновлены!'),
                    backgroundColor: Color(0xFF4A90A4),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Введите корректные данные'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void deleteChild(Child child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Удалить карточку?'),
        content: Text('Удалить карточку ${child.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                children.remove(child);
              });
              saveData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Карточка ${child.name} удалена'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🌡️ Калькулятор жаропонижающих 💊'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Форма создания ребенка
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '👨👩👧👦 Добавить члена семьи',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F4F4F),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Имя',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: ageYearsController,
                          decoration: InputDecoration(
                            labelText: 'Возраст (полных лет)',
                            prefixIcon: Icon(Icons.cake),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              showMonthsField = value == '0';
                              if (!showMonthsField) {
                                ageMonthsController.clear();
                              }
                            });
                          },
                        ),
                        SizedBox(height: 4),
                        Padding(
                          padding: EdgeInsets.only(left: 12),
                          child: Text(
                            'Если ребёнок младше года, введите 0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (showMonthsField) ...[
                      SizedBox(height: 12),
                      TextField(
                        controller: ageMonthsController,
                        decoration: InputDecoration(
                          labelText: 'Возраст (месяцев)',
                          prefixIcon: Icon(Icons.calendar_month),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                    SizedBox(height: 12),
                    TextField(
                      controller: weightController,
                      decoration: InputDecoration(
                        labelText: 'Вес (кг)',
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: createChild,
                      child: Text('⭐ Создать карточку'),
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 20),
            

            
            // Список детей
            Text(
              '👨‍👩‍👧‍👦 Моя семья:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A90A4),
              ),
            ),
            
            SizedBox(height: 12),
            
            Container(
              height: children.isEmpty ? 200 : children.length * 80.0,
              child: children.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.child_friendly,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Нет добавленных членов семьи',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: children.length,
                      itemBuilder: (context, index) {
                        final child = children[index];
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(0xFF4A90A4),
                              child: Text(
                                child.name[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              child.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2F4F4F),
                              ),
                            ),
                            subtitle: null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Color(0xFF4A90A4)),
                                  onPressed: () => editChild(child),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () => deleteChild(child),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChildScreen(child: child),
                                ),
                              ).then((_) => saveData());
                            },
                          ),
                        );
                      },
                    ),
            ),
            
            SizedBox(height: 20),
            
            // Полезные статьи
            Text(
              '📚 Полезные статьи:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A90A4),
              ),
            ),
            
            SizedBox(height: 12),
            
            ...articles.map((article) => Card(
              margin: EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.article, color: Color(0xFF4A90A4)),
                title: Text(
                  article.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F4F4F),
                  ),
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleScreen(article: article),
                    ),
                  );
                },
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}