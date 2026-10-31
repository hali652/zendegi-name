import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZendegiNamehApp());
}

class ZendegiNamehApp extends StatelessWidget {
  const ZendegiNamehApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF17233D);
    const teal = Color(0xFF168C83);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'زندگی‌نامه',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: teal,
          primary: teal,
          secondary: const Color(0xFFE6A94A),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FA),
          foregroundColor: ink,
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE8ECF2)),
          ),
        ),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: LifeScreen(),
      ),
    );
  }
}

class LifeEvent {
  final String title;
  final String description;
  final List<EventChoice> choices;

  const LifeEvent(this.title, this.description, this.choices);
}

class EventChoice {
  final String label;
  final String result;
  final int health;
  final int happiness;
  final int intelligence;
  final int money;

  const EventChoice({
    required this.label,
    required this.result,
    this.health = 0,
    this.happiness = 0,
    this.intelligence = 0,
    this.money = 0,
  });
}

class LifeScreen extends StatefulWidget {
  const LifeScreen({super.key});

  @override
  State<LifeScreen> createState() => _LifeScreenState();
}

class _LifeScreenState extends State<LifeScreen> {
  int age = 0;
  int health = 100;
  int happiness = 75;
  int intelligence = 50;
  int money = 0;
  String name = 'آرمان';
  String city = 'تهران';
  String occupation = 'دانش‌آموز';
  bool started = false;
  bool gameOver = false;
  String? lastResult;
  LifeEvent? currentEvent;
  final List<String> history = [];
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final raw = prefs.getString('life_save_v1');
    if (raw == null) return;
    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        age = data['age'] ?? 0;
        health = data['health'] ?? 100;
        happiness = data['happiness'] ?? 75;
        intelligence = data['intelligence'] ?? 50;
        money = data['money'] ?? 0;
        name = data['name'] ?? 'آرمان';
        city = data['city'] ?? 'تهران';
        occupation = data['occupation'] ?? 'دانش‌آموز';
        started = data['started'] ?? false;
        gameOver = data['gameOver'] ?? false;
        history.addAll(List<String>.from(data['history'] ?? []));
      });
    } catch (_) {
      await prefs.remove('life_save_v1');
    }
  }

  Future<void> _saveGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('life_save_v1', jsonEncode({
      'age': age,
      'health': health,
      'happiness': happiness,
      'intelligence': intelligence,
      'money': money,
      'name': name,
      'city': city,
      'occupation': occupation,
      'started': started,
      'gameOver': gameOver,
      'history': history.take(30).toList(),
    }));
  }

  void _startLife() {
    setState(() {
      started = true;
      age = 0;
      health = 100;
      happiness = 75;
      intelligence = 50;
      money = 0;
      occupation = 'نوزاد';
      gameOver = false;
      currentEvent = null;
      lastResult = 'زندگی $name در $city آغاز شد.';
      history.clear();
      history.insert(0, 'تولد در $city');
    });
    _saveGame();
  }

  LifeEvent _eventForAge(int nextAge) {
    if (nextAge == 1) {
      return const LifeEvent('اولین قدم‌ها', 'کم‌کم دنیا را می‌شناسی و اولین قدم‌هایت را برمی‌داری.', [
        EventChoice(label: 'با کمک خانواده تمرین کن', result: 'با تشویق خانواده راه افتادی.', happiness: 8, health: 2),
        EventChoice(label: 'با کنجکاوی همه‌جا را بگرد', result: 'کنجکاوی‌ات بیشتر شد؛ یک زمین‌خوردن کوچک هم داشتی.', intelligence: 3, health: -3),
      ]);
    }
    if (nextAge == 6) {
      return const LifeEvent('شروع مدرسه', 'وقت رفتن به مدرسه رسیده است. روز اول چه‌طور می‌گذرد؟', [
        EventChoice(label: 'با اشتیاق دوست پیدا کن', result: 'دوستان تازه‌ای پیدا کردی.', happiness: 10),
        EventChoice(label: 'روی درس‌ها تمرکز کن', result: 'از همان ابتدا دانش‌آموز منظمی شدی.', intelligence: 10, happiness: -2),
      ]);
    }
    if (nextAge == 12) {
      return const LifeEvent('یک علاقه تازه', 'در آستانه نوجوانی هستی. دوست داری وقتت را چطور بگذرانی؟', [
        EventChoice(label: 'ورزش و فعالیت گروهی', result: 'ورزش حال و سلامتت را بهتر کرد.', health: 8, happiness: 5),
        EventChoice(label: 'کتاب و یادگیری', result: 'دانشت بیشتر شد.', intelligence: 10, happiness: 2),
        EventChoice(label: 'هنر و موسیقی', result: 'استعداد هنری‌ات را کشف کردی.', happiness: 10, intelligence: 3),
      ]);
    }
    if (nextAge == 18) {
      return const LifeEvent('انتخاب مسیر آینده', 'دوران مدرسه تمام شده. برای ادامه زندگی چه تصمیمی می‌گیری؟', [
        EventChoice(label: 'دانشگاه', result: 'وارد دانشگاه شدی و مسیر تحصیلی را انتخاب کردی.', intelligence: 12, money: -5),
        EventChoice(label: 'یادگیری یک مهارت', result: 'یک مهارت کاربردی یاد گرفتی و آماده کار شدی.', intelligence: 6, money: 5),
        EventChoice(label: 'ورود مستقیم به بازار کار', result: 'اولین تجربه شغلی‌ات را شروع کردی.', money: 15, happiness: 2),
      ]);
    }
    if (nextAge == 20) {
      return const LifeEvent('سربازی یا ادامه تحصیل', 'به یک دوراهی مهم رسیده‌ای. فعلاً کدام مسیر را انتخاب می‌کنی؟', [
        EventChoice(label: 'انجام خدمت سربازی', result: 'یک دوره تازه از مسئولیت‌پذیری را تجربه کردی.', happiness: -3, intelligence: 2),
        EventChoice(label: 'ادامه تحصیل یا تخصص', result: 'برای آینده حرفه‌ای‌ات سرمایه‌گذاری کردی.', intelligence: 8, money: -8),
      ]);
    }
    if (nextAge == 25) {
      return const LifeEvent('فرصت شغلی', 'یک فرصت تازه برای پیشرفت شغلی پیدا کرده‌ای.', [
        EventChoice(label: 'فرصت را قبول کن', result: 'مسئولیت بیشتری گرفتی و درآمدت بالا رفت.', money: 35, happiness: 5),
        EventChoice(label: 'فعلاً دنبال تجربه بیشتر باش', result: 'با آرامش مهارت‌هایت را تقویت کردی.', intelligence: 6, happiness: 3),
      ]);
    }
    final pool = <LifeEvent>[
      const LifeEvent('دعوت دوستان', 'دوستانت برای یک دورهمی دعوتت کرده‌اند.', [
        EventChoice(label: 'به دورهمی برو', result: 'شب خوبی در کنار دوستانت داشتی.', happiness: 9, money: -4),
        EventChoice(label: 'در خانه بمان و استراحت کن', result: 'استراحت خوبی داشتی.', health: 4, happiness: 2),
      ]),
      const LifeEvent('فرصت یادگیری', 'یک دوره آموزشی جالب توجهت را جلب کرده است.', [
        EventChoice(label: 'ثبت‌نام کن', result: 'چیزهای تازه‌ای یاد گرفتی.', intelligence: 7, money: -6),
        EventChoice(label: 'فعلاً نه', result: 'پولت را برای زمان دیگری نگه داشتی.', money: 2),
      ]),
      const LifeEvent('یک هفته پرتنش', 'کارها و مسئولیت‌ها کمی خسته‌ات کرده‌اند.', [
        EventChoice(label: 'به خودت استراحت بده', result: 'با کمی استراحت انرژی گرفتی.', health: 6, happiness: 4, money: -2),
        EventChoice(label: 'بیشتر کار کن', result: 'درآمد بیشتری به دست آوردی اما خسته شدی.', money: 12, health: -5, happiness: -4),
      ]),
      const LifeEvent('کمک به خانواده', 'یکی از اعضای خانواده به کمک تو نیاز دارد.', [
        EventChoice(label: 'کمک کن', result: 'از اینکه کنار خانواده بودی احساس خوبی داری.', happiness: 8, money: -5),
        EventChoice(label: 'فعلاً نمی‌توانی', result: 'روی مسئولیت‌های خودت تمرکز کردی.', happiness: -2),
      ]),
    ];
    return pool[random.nextInt(pool.length)];
  }

  void _ageUp() {
    if (gameOver || !started) return;
    setState(() {
      age += 1;
      currentEvent = _eventForAge(age);
      lastResult = null;
      health = (health - (age > 65 ? 3 : 1)).clamp(0, 100);
      if (age == 7) occupation = 'دانش‌آموز';
      if (age == 22 && occupation == 'دانش‌آموز') occupation = 'فارغ‌التحصیل';
      if (age >= 85 || health <= 0) {
        gameOver = true;
        currentEvent = null;
        lastResult = 'این فصل از زندگی به پایان رسید. می‌توانی زندگی تازه‌ای را شروع کنی.';
        history.insert(0, 'پایان زندگی در $age سالگی');
      } else {
        history.insert(0, 'ورود به $age سالگی');
      }
    });
    _saveGame();
  }

  void _choose(EventChoice choice) {
    setState(() {
      health = (health + choice.health).clamp(0, 100);
      happiness = (happiness + choice.happiness).clamp(0, 100);
      intelligence = (intelligence + choice.intelligence).clamp(0, 100);
      money = max(0, money + choice.money);
      lastResult = choice.result;
      history.insert(0, choice.result);
      currentEvent = null;
      if (choice.label == 'دانشگاه') occupation = 'دانشجو';
      if (choice.label == 'ورود مستقیم به بازار کار') occupation = 'کارمند تازه‌کار';
      if (choice.label == 'انجام خدمت سربازی') occupation = 'در حال خدمت';
    });
    _saveGame();
  }

  Future<void> _reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('life_save_v1');
    if (!mounted) return;
    setState(() {
      started = false;
      gameOver = false;
      currentEvent = null;
      history.clear();
      lastResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('زندگی‌نامه', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 21)),
            Text('هر انتخاب، یک مسیر تازه', style: TextStyle(fontSize: 11, color: Color(0xFF7A8496))),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'شروع زندگی تازه',
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: !started ? _welcome() : _dashboard(),
      ),
    );
  }

  Widget _welcome() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF173B52), Color(0xFF168C83)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 34),
              SizedBox(height: 28),
              Text('زندگی تو،\nانتخاب‌های تو', style: TextStyle(color: Colors.white, fontSize: 30, height: 1.35, fontWeight: FontWeight.w900)),
              SizedBox(height: 12),
              Text('از اولین قدم تا تصمیم‌های بزرگ؛ داستانت را خودت می‌سازی.', style: TextStyle(color: Colors.white70, height: 1.8)),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text('شخصیتت را بساز', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        TextField(
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            labelText: 'نام شخصیت',
            hintText: 'مثلاً آرمان',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          onChanged: (v) => name = v.trim().isEmpty ? 'آرمان' : v.trim(),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: city,
          decoration: InputDecoration(
            labelText: 'محل تولد',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
          items: const ['تهران', 'مشهد', 'اصفهان', 'شیراز', 'تبریز', 'رشت', 'اهواز', 'کرمانشاه']
              .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (v) => setState(() => city = v ?? 'تهران'),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _startLife,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Text('شروع زندگی', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        const Text('نسخه آزمایشی: انتخاب‌ها و رویدادها فعلاً محدودند و در نسخه‌های بعدی گسترش پیدا می‌کنند.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF7A8496), fontSize: 11, height: 1.7)),
      ],
    );
  }

  Widget _dashboard() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _profileCard(),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(child: _statCard('سلامت', health, Icons.favorite_rounded, const Color(0xFFE66B75))),
            const SizedBox(width: 8),
            Expanded(child: _statCard('شادکامی', happiness, Icons.sentiment_satisfied_alt_rounded, const Color(0xFFE6A94A))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _statCard('هوش', intelligence, Icons.psychology_rounded, const Color(0xFF6686D8))),
            const SizedBox(width: 8),
            Expanded(child: _moneyCard()),
          ],
        ),
        const SizedBox(height: 16),
        if (currentEvent != null) _eventCard(currentEvent!),
        if (lastResult != null && currentEvent == null) _resultCard(lastResult!),
        const SizedBox(height: 12),
        if (!gameOver && currentEvent == null)
          FilledButton.icon(
            onPressed: _ageUp,
            icon: const Icon(Icons.fast_forward_rounded),
            label: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text('رفتن به سال بعد  ←  ${age + 1} سالگی', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        if (gameOver)
          FilledButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('شروع یک زندگی تازه'),
            ),
          ),
        const SizedBox(height: 20),
        const Text('مرور زندگی', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (history.isEmpty)
          const Text('هنوز اتفاقی ثبت نشده است.', style: TextStyle(color: Color(0xFF7A8496)))
        else
          ...history.take(8).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 7, color: Color(0xFF168C83)),
                const SizedBox(width: 9),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 13, height: 1.5))),
              ],
            ),
          )),
      ],
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF172B46),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: Colors.white.withOpacity(.12), borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 31),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('$age ساله • $occupation', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                Text('📍 $city', style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
          Column(
            children: [
              Text('$age', style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
              const Text('سن', style: TextStyle(color: Colors.white60, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, int value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF697386)))]),
            const SizedBox(height: 10),
            Text('$value از ۱۰۰', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: value / 100, minHeight: 6, backgroundColor: const Color(0xFFEDF0F4), color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moneyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF168C83), size: 18), SizedBox(width: 6), Text('دارایی', style: TextStyle(fontSize: 12, color: Color(0xFF697386)))]),
            const SizedBox(height: 10),
            Text('$money میلیون', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('تومان', style: TextStyle(fontSize: 11, color: Color(0xFF9AA3B2))),
          ],
        ),
      ),
    );
  }

  Widget _eventCard(LifeEvent event) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Icon(Icons.auto_awesome, color: Color(0xFFE6A94A)), SizedBox(width: 7), Text('اتفاق تازه', style: TextStyle(color: Color(0xFF168C83), fontWeight: FontWeight.bold, fontSize: 12))]),
            const SizedBox(height: 10),
            Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            Text(event.description, style: const TextStyle(height: 1.8, color: Color(0xFF596579))),
            const SizedBox(height: 15),
            ...event.choices.map((choice) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                  side: const BorderSide(color: Color(0xFFDDE5EC)),
                ),
                onPressed: () => _choose(choice),
                child: Row(children: [Expanded(child: Text(choice.label, style: const TextStyle(color: Color(0xFF17233D), fontWeight: FontWeight.w600))), const Icon(Icons.chevron_left_rounded, size: 19)]),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(String result) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF168C83)),
            const SizedBox(width: 10),
            Expanded(child: Text(result, style: const TextStyle(height: 1.7))),
          ],
        ),
      ),
    );
  }
}
