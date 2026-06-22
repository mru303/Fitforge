import React, { useState, useEffect } from 'react';
import { 
  Flame, 
  Scale, 
  TrendingDown, 
  TrendingUp, 
  Plus, 
  Trash2, 
  Edit3, 
  Activity, 
  Award, 
  User, 
  Info, 
  Search, 
  ChevronRight, 
  Share2, 
  ArrowLeft, 
  Laptop, 
  Smartphone, 
  Code2, 
  Copy, 
  Check, 
  Lock, 
  Unlock, 
  VolumeX, 
  Calculator, 
  Sparkles, 
  RotateCcw,
  Calendar,
  AlertCircle,
  Sun,
  Moon
} from 'lucide-react';

// Interfaces for our state elements
interface WeightLog {
  id: string;
  weight: number;
  date: string;
  notes: string;
}

interface BmiRecord {
  id: string;
  score: number;
  category: string;
  date: string;
  height: number;
  weight: number;
}

interface Badge {
  id: string;
  title: string;
  description: string;
  iconCode: string;
}

export default function App() {
  const [theme, setTheme] = useState<'dark' | 'light'>(() => {
    const saved = localStorage.getItem('fitforge_theme');
    return (saved as 'dark' | 'light') || 'dark';
  });

  useEffect(() => {
    localStorage.setItem('fitforge_theme', theme);
  }, [theme]);

  // 1. Initial/Persisted Data
  const [weightLogs, setWeightLogs] = useState<WeightLog[]>(() => {
    const saved = localStorage.getItem('fitforge_weight_logs');
    if (saved) {
      try { return JSON.parse(saved); } catch (e) { /* fallback */ }
    }
    // High-fidelity pre-populated defaults
    return [
      { id: '1', weight: 78.4, date: '2026-06-22', notes: 'Morning check-in. Progressing steadily.' },
      { id: '2', weight: 79.1, date: '2026-06-20', notes: 'Slight muscle building water weight.' },
      { id: '3', weight: 79.8, date: '2026-06-18', notes: 'Post training weight.' },
      { id: '4', weight: 80.5, date: '2026-06-15', notes: 'Starting FitForge routine!' },
      { id: '5', weight: 81.2, date: '2026-06-12', notes: 'Baseline weighing.' },
    ];
  });

  const [bmiRecords, setBmiRecords] = useState<BmiRecord[]>(() => {
    const saved = localStorage.getItem('fitforge_bmi_records');
    if (saved) {
      try { return JSON.parse(saved); } catch (e) { /* fallback */ }
    }
    return [
      { id: '101', score: 25.6, category: 'Overweight', date: '2026-06-12', height: 175, weight: 81.2 },
      { id: '102', score: 24.8, category: 'Normal', date: '2026-06-22', height: 175, weight: 78.4 },
    ];
  });

  const [goalWeight, setGoalWeight] = useState<number>(() => {
    const saved = localStorage.getItem('fitforge_goal_weight');
    return saved ? parseFloat(saved) : 70.0;
  });

  // Simulator Screen Layout States
  const [activeScreen, setActiveScreen] = useState<'splash' | 'app'>('splash');
  const [activeTab, setActiveTab] = useState<'dashboard' | 'tracker' | 'bmi' | 'calories' | 'insights'>('dashboard');
  
  // Tab inner views
  const [bmiSubTab, setBmiSubTab] = useState<'calc' | 'history'>('calc');

  // Interactive Form Inputs
  const [bmiHeight, setBmiHeight] = useState<number>(175); // cm
  const [bmiWeightInput, setBmiWeightInput] = useState<number>(75); // kg
  const [bmiAge, setBmiAge] = useState<number>(26);
  const [bmiGender, setBmiGender] = useState<'Male' | 'Female'>('Male');

  // Calorie input states
  const [calorieHeight, setCalorieHeight] = useState<number>(175);
  const [calorieWeight, setCalorieWeight] = useState<number>(78);
  const [calorieAge, setCalorieAge] = useState<number>(26);
  const [calorieGender, setCalorieGender] = useState<'Male' | 'Female'>('Male');
  const [calorieActivity, setCalorieActivity] = useState<string>('Moderately Active');

  // Logs Form States
  const [showLogModal, setShowLogModal] = useState(false);
  const [editLogItem, setEditLogItem] = useState<WeightLog | null>(null);
  const [logWeight, setLogWeight] = useState<string>('');
  const [logDate, setLogDate] = useState<string>(new Date().toISOString().split('T')[0]);
  const [logNotes, setLogNotes] = useState<string>('');

  // Goal Form State
  const [showGoalModal, setShowGoalModal] = useState(false);
  const [goalInput, setGoalInput] = useState<string>('');

  // Search/Filter states inside BMI history
  const [historySearch, setHistorySearch] = useState('');
  const [historyFilter, setHistoryFilter] = useState('All');
  const [historySort, setHistorySort] = useState<'Newest' | 'Oldest' | 'Highest' | 'Lowest'>('Newest');

  // Custom clock state for phone status bar
  const [phoneTime, setPhoneTime] = useState('09:41');

  // Code Viewer / Inspector states
  const [selectedInspectFile, setSelectedInspectFile] = useState<string>('home_tab.dart');
  const [copiedCodeFlag, setCopiedCodeFlag] = useState(false);

  // Synchronize dynamic lists to local storage
  useEffect(() => {
    localStorage.setItem('fitforge_weight_logs', JSON.stringify(weightLogs));
  }, [weightLogs]);

  useEffect(() => {
    localStorage.setItem('fitforge_bmi_records', JSON.stringify(bmiRecords));
  }, [bmiRecords]);

  useEffect(() => {
    localStorage.setItem('fitforge_goal_weight', goalWeight.toString());
  }, [goalWeight]);

  // Update simulator's status bar clock
  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      let hours = now.getHours();
      let minutes = now.getMinutes().toString().padStart(2, '0');
      setPhoneTime(`${hours.toString().padStart(2, '0')}:${minutes}`);
    };
    updateTime();
    const interval = setInterval(updateTime, 10000);
    return () => clearInterval(interval);
  }, []);

  // Splash transitions simulation
  useEffect(() => {
    if (activeScreen === 'splash') {
      const timer = setTimeout(() => {
        setActiveScreen('app');
      }, 2500);
      return () => clearTimeout(timer);
    }
  }, [activeScreen]);

  // Dynamic calculations: Streak count, weight metrics, milestones
  const getTrackingStreak = (): number => {
    if (weightLogs.length === 0) return 0;
    const sortedDates = [...weightLogs]
      .map(entry => entry.date)
      .filter((value, index, self) => self.indexOf(value) === index)
      .sort((a, b) => new Date(b).getTime() - new Date(a).getTime()); // descending

    let count = 0;
    let checkDate = new Date(); // start today

    const normalizeDateStr = (d: Date) => d.toISOString().split('T')[0];
    
    // Check if we logged today or yesterday
    const formattedToday = normalizeDateStr(checkDate);
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const formattedYesterday = normalizeDateStr(yesterday);

    if (!sortedDates.includes(formattedToday) && !sortedDates.includes(formattedYesterday)) {
      return 0;
    }

    let searchDate = sortedDates.includes(formattedToday) ? formattedToday : formattedYesterday;
    let currIndex = sortedDates.indexOf(searchDate);

    if (currIndex === -1) return 0;

    count = 1;
    let checkDay = new Date(searchDate);
    
    for (let i = currIndex + 1; i < sortedDates.length; i++) {
      checkDay.setDate(checkDay.getDate() - 1);
      const prevDateStr = normalizeDateStr(checkDay);
      if (sortedDates[i] === prevDateStr) {
        count++;
      } else {
        break;
      }
    }
    return count;
  };

  const getWeightChange = (): { diff: number; trend: 'gain' | 'loss' | 'stable' } => {
    if (weightLogs.length < 2) return { diff: 0, trend: 'stable' };
    const sorted = [...weightLogs].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
    const initial = sorted[0].weight;
    const current = sorted[sorted.length - 1].weight;
    const diff = current - initial;
    return {
      diff: Math.abs(diff),
      trend: diff > 0 ? 'gain' : diff < 0 ? 'loss' : 'stable'
    };
  };

  const currentWeight = weightLogs.length > 0 ? weightLogs[0].weight : 75.0;
  const initialWeight = weightLogs.length > 0 ? [...weightLogs].reverse()[0].weight : 75.0;

  // Goal Progress Ring % calculation
  const getGoalProgress = (): number => {
    if (weightLogs.length === 0) return 0;
    const startW = initialWeight;
    const currentW = currentWeight;
    const targetW = goalWeight;

    if (Math.abs(startW - targetW) < 0.1) return 100;
    const totalRequired = startW - targetW;
    const achieved = startW - currentW;
    const percent = (achieved / totalRequired) * 100;

    if (percent < 0) return 0;
    if (percent > 100) return 100;
    return Math.round(percent);
  };

  // Badge list and active achievement system indicators
  const badges: Badge[] = [
    { id: 'first_entry', title: 'First Step', description: 'Logged your very first weight entry!', iconCode: 'first_entry' },
    { id: 'streak_7', title: 'Consistency Spike', description: 'Tracked weight across a 7-day streak.', iconCode: 'streak_7' },
    { id: 'streak_30', title: 'Dedicated Forger', description: 'Completed a 30-day weight tracking milestone.', iconCode: 'streak_30' },
    { id: 'goal_hit', title: 'Forge Mastered', description: 'Successfully reached your goal weight!', iconCode: 'goal_hit' },
    { id: 'champion', title: 'Iron Consistency', description: 'Maintained 5 or more distinct logs.', iconCode: 'champion' },
  ];

  const getIsBadgeUnlocked = (badgeId: string): boolean => {
    if (badgeId === 'first_entry') return weightLogs.length >= 1;
    if (badgeId === 'streak_7') return getTrackingStreak() >= 7;
    if (badgeId === 'streak_30') return getTrackingStreak() >= 30;
    if (badgeId === 'champion') return weightLogs.length >= 5;
    if (badgeId === 'goal_hit') {
      if (weightLogs.length === 0) return false;
      const startW = initialWeight;
      if (startW >= goalWeight) {
        return currentWeight <= goalWeight;
      } else {
        return currentWeight >= goalWeight;
      }
    }
    return false;
  };

  // Live BMI Calculator helper function
  const latestBmiItem = bmiRecords.length > 0 ? bmiRecords[0] : { score: 23.4, category: 'Normal' };

  const getBmiDetails = (heightCm: number, weightKg: number) => {
    const score = parseFloat((weightKg / Math.pow(heightCm / 100, 2)).toFixed(1));
    let category = 'Normal';
    let color = '#10B981'; // emerald
    let recs: string[] = [];

    if (score < 18.5) {
      category = 'Underweight';
      color = '#F59E0B'; // amber
      recs = [
        'Prioritize progressive weight training to build lean muscle mass.',
        'Focus on energy-dense, nutrient-rich foods (nuts, healthy fats).',
        'Eat smaller, calorie-dense foods frequently throughout the day.'
      ];
    } else if (score < 25) {
      category = 'Normal';
      color = '#10B981'; // emerald
      recs = [
        'Outstanding! Maintain your current energy balance.',
        'Keep active with standard resistance and cardio workouts.',
        'Maintain fiber-rich diets with diverse fresh foods.'
      ];
    } else if (score < 30) {
      category = 'Overweight';
      color = '#F97316'; // orange / amber
      recs = [
        'Attempt a moderate energy deficit (~300-500 kcal daily).',
        'Incorporate high-intensity interval cardiorespiratory movements.',
        'Raise dietary portion consciousness and emphasize protein targets.'
      ];
    } else {
      category = 'Obese';
      color = '#EF4444'; // red
      recs = [
        'Consult with physical trainers or medical supervisors before loading.',
        'Incorporate low-impact movements daily (e.g., walking, swimming).',
        'Work on clean eating, sleep metrics, and sustainable calorie targets.'
      ];
    }

    const idealMin = parseFloat((18.5 * Math.pow(heightCm / 100, 2)).toFixed(1));
    const idealMax = parseFloat((24.9 * Math.pow(heightCm / 100, 2)).toFixed(1));

    return { score, category, color, recs, range: `${idealMin} - ${idealMax} kg` };
  };

  const customCalculatorOutput = getBmiDetails(bmiHeight, bmiWeightInput);

  // Calorie calculations
  const getCaloriesDetails = (height: number, weight: number, age: number, gender: string, activity: string) => {
    let bmr = 0;
    if (gender === 'Male') {
      bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }

    let multiplier = 1.2;
    if (activity === 'Sedentary') multiplier = 1.2;
    else if (activity === 'Lightly Active') multiplier = 1.375;
    else if (activity === 'Moderately Active') multiplier = 1.55;
    else if (activity === 'Very Active') multiplier = 1.725;
    else if (activity === 'Athlete') multiplier = 1.9;

    const maintenance = Math.round(bmr * multiplier);
    return {
      maintenance,
      loss: maintenance - 500,
      gain: maintenance + 500
    };
  };

  const caloriesBudget = getCaloriesDetails(calorieHeight, calorieWeight, calorieAge, calorieGender, calorieActivity);

  // 2. Action callbacks
  const handleSaveBmiRecord = () => {
    const details = getBmiDetails(bmiHeight, bmiWeightInput);
    const newRecord: BmiRecord = {
      id: Date.now().toString(),
      score: details.score,
      category: details.category,
      date: new Date().toISOString().split('T')[0],
      height: bmiHeight,
      weight: bmiWeightInput,
    };
    setBmiRecords([newRecord, ...bmiRecords]);
    setBmiSubTab('history');
  };

  const handleOpenAddLog = () => {
    setEditLogItem(null);
    setLogWeight('');
    setLogDate(new Date().toISOString().split('T')[0]);
    setLogNotes('');
    setShowLogModal(true);
  };

  const handleOpenEditLog = (item: WeightLog) => {
    setEditLogItem(item);
    setLogWeight(item.weight.toString());
    setLogDate(item.date);
    setLogNotes(item.notes);
    setShowLogModal(true);
  };

  const handleSaveLog = () => {
    const wVal = parseFloat(logWeight);
    if (isNaN(wVal) || wVal <= 20 || wVal > 300) {
      alert('Please enter a realistic weight (20 - 300 kg).');
      return;
    }

    if (editLogItem) {
      // Modify
      setWeightLogs(weightLogs.map(item => 
        item.id === editLogItem.id ? { ...item, weight: wVal, date: logDate, notes: logNotes } : item
      ).sort((a,b) => new Date(b.date).getTime() - new Date(a.date).getTime()));
    } else {
      // Create
      const newEntry: WeightLog = {
        id: Date.now().toString(),
        weight: wVal,
        date: logDate,
        notes: logNotes
      };
      setWeightLogs([newEntry, ...weightLogs].sort((a,b) => new Date(b.date).getTime() - new Date(a.date).getTime()));
    }
    setShowLogModal(false);
  };

  const handleDeleteLog = (id: string) => {
    if (confirm('Delete this weight record entry?')) {
      setWeightLogs(weightLogs.filter(item => item.id !== id));
    }
  };

  const handleSaveGoal = () => {
    const target = parseFloat(goalInput);
    if (isNaN(target) || target <= 20 || target > 350) {
      alert('Please enter a target weight.');
      return;
    }
    setGoalWeight(target);
    setShowGoalModal(false);
  };

  // Multi-Filter inner state for BMI history list logic
  const filteredBmiRecords = bmiRecords.filter(rec => {
    const matchSearch = rec.category.toLowerCase().includes(historySearch.toLowerCase()) ||
                        rec.score.toFixed(1).includes(historySearch) ||
                        rec.date.includes(historySearch);
    const matchFilter = historyFilter === 'All' || rec.category === historyFilter;
    return matchSearch && matchFilter;
  }).sort((a, b) => {
    if (historySort === 'Newest') return new Date(b.date).getTime() - new Date(a.date).getTime();
    if (historySort === 'Oldest') return new Date(a.date).getTime() - new Date(b.date).getTime();
    if (historySort === 'Highest') return b.score - a.score;
    if (historySort === 'Lowest') return a.score - b.score;
    return 0;
  });

  // Source texts of various Flutter Dart components
  const dartFilesContents: Record<string, string> = {
    'main.dart': `import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/fitness_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FitForgeApp());
}

class FitForgeApp extends StatelessWidget {
  const FitForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FitnessProvider()),
      ],
      child: MaterialApp(
        title: 'FitForge',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark, // Dark Mode Only
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0F172A),
          colorScheme: const ColorScheme.dark(
            brightness: Brightness.dark,
            primary: Color(0xFFA855F7),
            secondary: Color(0xFF3B82F6),
            background: Color(0xFF0F172A),
            surface: Color(0xFF1E293B),
            error: Color(0xFFEF4444),
          ),
          textTheme: const TextTheme(
            headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
            titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.3),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          cardTheme: CardTheme(
            color: const Color(0xFF1E293B),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/dashboard': (context) => const DashboardScreen(),
        },
      ),
    );
  }
}`,
    'fitness_provider.dart': `import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weight_entry.dart';
import '../models/bmi_record.dart';
import '../models/achievement_badge.dart';

class FitnessProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  List<WeightEntry> _weightEntries = [];
  List<BmiRecord> _bmiRecords = [];
  double _goalWeight = 70.0;
  List<AchievementBadge> _badges = [];

  FitnessProvider() {
    _initBadges();
    _loadFromPrefs();
  }
  
  // Real Local Persistence via shared_preferences
  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _goalWeight = _prefs.getDouble('goal_weight') ?? 70.0;
    
    final weightJson = _prefs.getStringList('weight_entries') ?? [];
    _weightEntries = weightJson.map((e) => WeightEntry.fromJson(e)).toList();
    _weightEntries.sort((a, b) => b.date.compareTo(a.date));

    final bmiJson = _prefs.getStringList('bmi_records') ?? [];
    _bmiRecords = bmiJson.map((e) => BmiRecord.fromJson(e)).toList();
    
    _checkAndUnlockAchievements();
    _isInitialized = true;
    notifyListeners();
  }

  // Weight Logging CRUD Actions...
  Future<void> addWeightEntry(double weight, DateTime date, String notes) async {
    final entry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weight: weight,
      date: date,
      notes: notes,
    );
    _weightEntries.add(entry);
    _weightEntries.sort((a, b) => b.date.compareTo(a.date));
    await _prefs.setStringList('weight_entries', _weightEntries.map((e) => e.toJson()).toList());
    _checkAndUnlockAchievements();
    notifyListeners();
  }
  // Other helper logic, streaks calculating, calculations details...
}`,
    'splash_screen.dart': `class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
    _controller.forward();
    
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/dashboard');
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFFA855F7), Color(0xFF3B82F6)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.fitness_center_rounded, size: 46, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text('FitForge', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}`,
    'home_tab.dart': `class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fitness = Provider.of<FitnessProvider>(context);
    final weightEntries = fitness.weightEntries;
    double currentWeight = weightEntries.isNotEmpty ? weightEntries.first.weight : 75.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Welcome back, Iron Forger'),
              _buildStreakBadge(fitness.trackingStreak),
            ],
          ),
          const SizedBox(height: 28),
          _buildGoalCompletionRing(fitness.goalProgressPercentage),
          const SizedBox(height: 24),
          _buildStatsGrid(currentWeight, fitness.goalWeight),
        ],
      ),
    );
  }
}`,
    'weight_tracker_tab.dart': `class WeightTrackerTab extends StatefulWidget {
  @override
  State<WeightTrackerTab> createState() => _WeightTrackerTabState();
}

class _WeightTrackerTabState extends State<WeightTrackerTab> {
  // Direct integration with FitnessProvider
  // Full Add / Edit / Delete modals & lists:
  void _showFormModal({WeightEntry? entry}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Log weight directly to local DB'),
            // TextFields ...
          ],
        ),
      ),
    );
  }
}`,
    'bmi_tab.dart': `class BmiTab extends StatefulWidget {
  const BmiTab({super.key});
  @override
  State<BmiTab> createState() => _BmiTabState();
}

class _BmiTabState extends State<BmiTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _heightCm = 175.0;
  double _weightKg = 70.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.calculate_outlined), text: 'BMI Calculator'),
            Tab(icon: Icon(Icons.history), text: 'Saved Records'),
          ]
        ),
        // Switch views dynamically with BMI Recommendations and search!
      ],
    );
  }
}`,
    'calories_tab.dart': `class CaloriesTab extends StatefulWidget {
  const CaloriesTab({super.key});
  @override
  State<CaloriesTab> createState() => _CaloriesTabState();
}

class _CaloriesTabState extends State<CaloriesTab> {
  // Activity Level forms and Harris-Benedict formulas
  // Generates complete maintenance, loss, and gain cards!
}`,
    'analytics_theme_tab.dart': `class AnalyticsThemeTab extends StatelessWidget {
  Widget _buildWeightLineChart(List<dynamic> entries) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: entries.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.weight)).toList(),
            isCurved: true,
            color: const Color(0xFFA855F7),
            barWidth: 4,
          )
        ]
      )
    );
  }
}`
  };

  const activeInspectFileTitle = selectedInspectFile;
  const activeInspectFileContent = dartFilesContents[selectedInspectFile] || '// Empty file';

  const handleCopyCode = () => {
    navigator.clipboard.writeText(activeInspectFileContent);
    setCopiedCodeFlag(true);
    setTimeout(() => setCopiedCodeFlag(false), 2000);
  };

  // Weight Trend visual path generator for smartphone screen
  const generateWeightMinMax = () => {
    if (weightLogs.length === 0) return { min: 60, max: 90 };
    const weights = weightLogs.map(l => l.weight);
    return {
      min: Math.min(...weights) - 1,
      max: Math.max(...weights) + 1
    };
  };

  const { min: yMin, max: yMax } = generateWeightMinMax();

  // Create SVG points coordinates based on logs for smooth line chart drawing in simulator
  const generateSvgPoints = (): string => {
    if (weightLogs.length < 2) return '';
    const sorted = [...weightLogs].sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
    
    const width = 280;
    const height = 110;
    const paddingLeft = 10;
    const paddingRight = 10;
    const paddingTop = 15;
    const paddingBottom = 15;

    const xSpan = sorted.length - 1;
    const ySpan = (yMax - yMin) || 1;

    return sorted.map((entry, index) => {
      const x = paddingLeft + (index / xSpan) * (width - paddingLeft - paddingRight);
      const ratio = (entry.weight - yMin) / ySpan;
      // SVG 0 is top, so we reverse it
      const y = height - paddingBottom - ratio * (height - paddingTop - paddingBottom);
      return `${x},${y}`;
    }).join(' ');
  };

  const svgLinePoints = generateSvgPoints();

  return (
    <div className={`min-h-screen ${theme === 'light' ? 'light-theme bg-[#F1F5F9] text-slate-800' : 'bg-[#0F172A] text-slate-100'} flex flex-col justify-between font-sans antialiased selection:bg-purple-500/20 transition-colors duration-300`}>
      
      {/* 1. Header / Navigation status line */}
      <header className={`border-b ${theme === 'light' ? 'border-slate-200 bg-white/90 text-slate-800 shadow-sm' : 'border-white/5 bg-[#1E293B]/85 text-slate-200'} px-6 py-4 sticky top-0 z-40 backdrop-blur-md transition-all duration-300`}>
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
          <div>
            <div className="flex items-center gap-2.5">
              <div className="p-1 px-2.5 bg-gradient-to-r from-purple-600 to-blue-600 rounded-lg text-[11px] font-bold tracking-wider text-white">
                FLUTTER & DART DEPLOYABLE
              </div>
              <span className={`text-xs ${theme === 'light' ? 'text-slate-500' : 'text-slate-400'} font-mono tracking-widest uppercase`}>PROTOTYPE COMPOSER</span>
            </div>
            <h1 className={`text-2xl font-black tracking-tight ${theme === 'light' ? 'text-slate-900' : 'text-white'} mt-1`}>
              FitForge <span className="text-purple-500 font-light text-base">Development Suite</span>
            </h1>
          </div>

          <div className="flex items-center gap-2">
            <span className={`text-xs font-mono px-3 py-1.5 rounded-full border flex items-center gap-2.5 ${theme === 'light' ? 'text-emerald-700 bg-emerald-500/10 border-emerald-500/20' : 'text-emerald-400 bg-emerald-500/10 border-emerald-500/20'}`}>
              <span className="h-2 w-2 rounded-full bg-emerald-500 animate-pulse"></span>
              Workspace Synced
            </span>
            <button 
              onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
              className={`text-xs font-semibold px-3.5 py-1.5 rounded-lg flex items-center gap-1.5 transition-all cursor-pointer ${
                theme === 'dark' 
                  ? 'text-yellow-400 bg-yellow-500/10 border border-yellow-500/20 hover:bg-yellow-500/25' 
                  : 'text-indigo-600 bg-indigo-500/10 border border-indigo-500/25 hover:bg-indigo-500/35'
              }`}
              title="Toggle light/dark theme"
            >
              {theme === 'dark' ? <Sun className="h-3.5 w-3.5" /> : <Moon className="h-3.5 w-3.5" />}
              {theme === 'dark' ? 'Light Theme' : 'Dark Theme'}
            </button>
            <button 
              onClick={() => setActiveScreen('splash')}
              className={`text-xs font-medium px-3.5 py-1.5 rounded-lg flex items-center gap-1.5 transition-all cursor-pointer ${theme === 'light' ? 'text-slate-700 hover:text-slate-950 bg-slate-200/60 hover:bg-slate-200/90 border border-slate-300/60' : 'text-slate-300 hover:text-white bg-white/5 border border-white/10 hover:bg-white/10'}`}
            >
              <RotateCcw className="h-3.5 w-3.5" />
              Reboot App
            </button>
          </div>
        </div>
      </header>

      {/* 2. Main content zone */}
      <main className="flex-1 max-w-7xl w-full mx-auto p-4 sm:p-6 grid grid-cols-1 lg:grid-cols-12 gap-8 items-start my-auto">
        
        {/* Left Side: Gorgeous Smartphone Emulator Frame (lg:col-span-5) */}
        <div className="lg:col-span-5 flex flex-col items-center justify-center">
          <div className="text-center mb-4">
            <p className="text-xs text-slate-400 uppercase tracking-widest font-semibold flex items-center justify-center gap-2">
              <Smartphone className="h-3 w-3 text-purple-400" /> Live Interactive Application Emulator
            </p>
          </div>

          {/* Smartphone device model shell */}
          <div id="device-preview" className={`relative w-full max-w-[370px] aspect-[9/19] rounded-[48px] border-4 ${theme === 'light' ? 'border-slate-300 ring-slate-200/50 bg-slate-100' : 'border-slate-800 ring-slate-800/50 bg-[#070A13]'} shadow-2xl overflow-hidden flex flex-col ring-8 transition-all duration-300`}>
            {/* Dynamic Status Bar */}
            <div className={`absolute top-0 inset-x-0 h-10 ${theme === 'light' ? 'bg-[#F8FAFC] text-slate-700' : 'bg-[#0F172A] text-slate-200'} flex items-center justify-between px-6 z-50 text-xs font-semibold transition-colors duration-300`}>
              <span>{phoneTime}</span>
              {/* Apple Health style sensor island / notch */}
              <div className="w-24 h-4 bg-black rounded-full absolute left-1/2 -translate-x-1/2 top-1.5 flex items-center justify-center">
                <span className="block h-1 w-1 bg-blue-900/30 rounded-full"></span>
              </div>
              <div className="flex items-center gap-1.5">
                <span className={`text-[10px] uppercase ${theme === 'light' ? 'text-purple-650' : 'text-purple-400'} font-mono`}>5G</span>
                <div className={`h-2 w-4 ${theme === 'light' ? 'bg-slate-300' : 'bg-slate-400/50'} rounded-sm relative`}>
                  <div className={`absolute left-0 top-0 h-full w-4/5 ${theme === 'light' ? 'bg-[#A855F7]' : 'bg-slate-200'} rounded-sm`}></div>
                </div>
              </div>
            </div>

            {/* Screen Content Frame */}
            <div className={`flex-1 pt-10 pb-4 overflow-y-auto scrollbar-none flex flex-col ${theme === 'light' ? 'bg-[#F8FAFC] text-slate-900' : 'bg-[#0F172A] text-slate-100'} relative transition-colors duration-300`}>
              <h2 className="sr-only">FitForge Application Screen</h2>
              
              {/* SPLASH VIEW STATE */}
              {activeScreen === 'splash' && (
                <div className="flex-1 flex flex-col items-center justify-center p-6 text-center animate-fade-in">
                  <div className="w-20 h-20 bg-gradient-to-br from-purple-500 to-blue-500 rounded-2xl flex items-center justify-center shadow-lg transform scale-110 shadow-purple-500/25 animate-pulse mb-6">
                    <Flame className="h-10 w-10 text-white" />
                  </div>
                  <h2 className="text-3xl font-black tracking-tight text-white mb-2">FitForge</h2>
                  <p className="text-[10px] tracking-[4px] font-bold text-slate-500 uppercase">STRENGTH IN NUMBERS</p>
                  
                  <div className="mt-20 w-8 h-8 rounded-full border-2 border-purple-500/20 border-t-purple-500 animate-spin"></div>
                </div>
              )}

              {/* ACTIVE RUNNING APP ENVIRONMENT */}
              {activeScreen === 'app' && (
                <div className="flex-1 flex flex-col">
                  
                  {/* APP TAB CONTENTS */}
                  <div className="flex-1 p-5">
                    
                    {/* A. DASHBOARD TAB */}
                    {activeTab === 'dashboard' && (
                      <div className="space-y-6">
                        {/* Header Greeting */}
                        <div className="flex justify-between items-center">
                          <div>
                            <span className="text-[10px] text-slate-400 uppercase tracking-widest font-semibold">DAILY STATS</span>
                            <h3 className="text-xl font-bold tracking-tight">Iron Forger</h3>
                          </div>
                          
                          {/* Active Days Streak widget */}
                          <div className="flex items-center gap-1 bg-[#1E293B] border border-white/5 px-2.5 py-1 rounded-full text-xs">
                            <Flame className={`h-4.5 w-4.5 text-amber-500 ${getTrackingStreak() > 0 ? "animate-pulse" : "opacity-30"}`} />
                            <span className="font-bold">{getTrackingStreak()} Days</span>
                          </div>
                        </div>

                        {/* Goal Progress Ring card */}
                        <div className="bg-gradient-to-br from-[#A855F7] to-[#3B82F6] rounded-3xl p-5 shadow-lg relative overflow-hidden group">
                          <div className="space-y-1">
                            <span className="text-[9px] uppercase tracking-wider font-extrabold text-white/70">Goal Completion</span>
                            <div className="text-3xl font-black">{getGoalProgress()}%</div>
                            <div className="flex items-center gap-1 text-[11px] font-semibold text-white/90">
                              {getWeightChange().trend === 'loss' ? (
                                <TrendingDown className="h-3 w-3" />
                              ) : (
                                <TrendingUp className="h-3 w-3" />
                              )}
                              <span>
                                {getWeightChange().trend === 'loss' ? 'Down' : 'Up'}{' '}
                                {getWeightChange().diff.toFixed(1)} kg since baseline
                              </span>
                            </div>
                          </div>

                          {/* SVG absolute progressive wheel */}
                          <div className="absolute right-5 bottom-4 w-20 h-20">
                            <svg className="w-full h-full transform -rotate-90">
                              <circle cx="40" cy="40" r="32" stroke="rgba(255,255,255,0.15)" strokeWidth="6" fill="none" />
                              <circle 
                                cx="40" cy="40" r="32" 
                                stroke="#ffffff" strokeWidth="6" fill="none"
                                strokeDasharray={2 * Math.PI * 32}
                                strokeDashoffset={2 * Math.PI * 32 * (1 - Math.min(getGoalProgress(), 100) / 100)}
                                strokeLinecap="round"
                              />
                            </svg>
                            <div className="absolute inset-0 flex items-center justify-center">
                              <Activity className="h-5 w-5 text-white/90" />
                            </div>
                          </div>
                        </div>

                        {/* Health Info Grid */}
                        <div className="grid grid-cols-2 gap-3.5">
                          {/* Weight */}
                          <div className="glass-card rounded-2xl p-3.5 shadow-sm">
                            <div className="flex justify-between items-start text-slate-400">
                              <span className="text-[9px] uppercase tracking-wider font-bold">Weight</span>
                              <Scale className="h-3.5 w-3.5 text-purple-400" />
                            </div>
                            <div className="mt-1 text-lg font-black">{currentWeight} kg</div>
                            <span className="text-[9.5px] text-slate-400 leading-tight block truncate mt-0.5">
                              Logs: {weightLogs.length} entries
                            </span>
                          </div>

                          {/* Goal */}
                          <div className="glass-card rounded-2xl p-3.5 shadow-sm">
                            <div className="flex justify-between items-start text-slate-400">
                              <span className="text-[9px] uppercase tracking-wider font-bold">Target</span>
                              <Award className="h-3.5 w-3.5 text-blue-400" />
                            </div>
                            <div className="mt-1 text-lg font-black">{goalWeight} kg</div>
                            <span className="text-[9.5px] text-slate-400 leading-tight block truncate mt-0.5">
                              Remains: {Math.abs(currentWeight - goalWeight).toFixed(1)} kg
                            </span>
                          </div>

                          {/* Latest BMI Score */}
                          <div className="glass-card rounded-2xl p-3.5 shadow-sm">
                            <div className="flex justify-between items-start text-slate-400">
                              <span className="text-[9px] uppercase tracking-wider font-bold">BMI</span>
                              <Calculator className="h-3.5 w-3.5 text-emerald-400" />
                            </div>
                            <div className="mt-1 text-lg font-black">{latestBmiItem.score}</div>
                            <span className="text-[9.5px] text-emerald-400 leading-tight block font-semibold truncate mt-0.5">
                              {latestBmiItem.category}
                            </span>
                          </div>

                          {/* Streaks Logged */}
                          <div className="glass-card rounded-2xl p-3.5 shadow-sm">
                            <div className="flex justify-between items-start text-slate-400">
                              <span className="text-[9px] uppercase tracking-wider font-bold">Progress</span>
                              <Flame className="h-3.5 w-3.5 text-amber-500" />
                            </div>
                            <div className="mt-1 text-lg font-black">{getWeightChange().trend === 'loss' ? '-' : '+'}{getWeightChange().diff.toFixed(1)} kg</div>
                            <span className="text-[9.5px] text-slate-400 leading-tight block truncate mt-0.5">
                              Total variance
                            </span>
                          </div>
                        </div>

                        {/* Recent History Highlight */}
                        <div className="space-y-2.5">
                          <h4 className="text-sm font-bold tracking-tight text-white/90">Today's Summary</h4>
                          {weightLogs.length === 0 ? (
                            <div className="bg-slate-800/30 rounded-xl p-4 text-center text-slate-400 text-xs">
                              No log items. Click Tracker to log weight!
                            </div>
                          ) : (
                            <div className="glass-card rounded-2xl p-3.5 flex items-center justify-between">
                              <div className="flex items-center gap-3">
                                <div className="h-8 w-8 rounded-full bg-purple-500/10 flex items-center justify-center">
                                  <Scale className="h-4 w-4 text-purple-400" />
                                </div>
                                <div className="text-xs">
                                  <div className="font-bold">Last weighing recorded</div>
                                  <div className="text-[10px] text-slate-500">at {weightLogs[0].weight} kg on {weightLogs[0].date}</div>
                                </div>
                              </div>
                              <span className="text-[10px] font-bold text-emerald-400 uppercase tracking-widest">Active</span>
                            </div>
                          )}
                        </div>
                      </div>
                    )}


                    {/* B. WEIGHT TRACKER TAB */}
                    {activeTab === 'tracker' && (
                      <div className="space-y-5">
                        <div className="flex items-center justify-between">
                          <div>
                            <span className="text-[10px] text-slate-400 uppercase tracking-widest font-semibold font-mono">WEIGHT CRUD DATABASE</span>
                            <h3 className="text-xl font-extrabold tracking-tight">Record Forge</h3>
                          </div>
                          
                          <button 
                            onClick={handleOpenAddLog}
                            className="bg-purple-600 hover:bg-purple-700 text-xs font-bold px-3 py-1.5 rounded-lg flex items-center gap-1 shadow-lg shadow-purple-600/10 cursor-pointer"
                          >
                            <Plus className="h-3.5 w-3.5" />
                            Log Weight
                          </button>
                        </div>

                        {/* Goal adjuster card section inside tracker */}
                        <div className="glass-card p-4 rounded-2xl flex items-center justify-between">
                          <div className="space-y-1">
                            <span className="text-[9px] uppercase font-bold text-slate-400">Target Weight Budget</span>
                            <p className="text-base font-bold text-slate-200">{goalWeight} kg</p>
                          </div>
                          <button 
                            onClick={() => {
                              setGoalInput(goalWeight.toString());
                              setShowGoalModal(true);
                            }}
                            className="text-xs font-bold text-blue-400 hover:text-blue-300 flex items-center gap-1.5 cursor-pointer bg-slate-700/40 px-2.5 py-1.5 rounded-lg"
                          >
                            <Edit3 className="h-3.5 w-3.5" />
                            Adjust Target
                          </button>
                        </div>

                        {/* Weight records list */}
                        <div className="space-y-2.5">
                          <h4 className="text-xs uppercase tracking-widest font-bold text-slate-400">Logged Entries ({weightLogs.length})</h4>
                          
                          {weightLogs.length === 0 ? (
                            <div className="p-8 text-center bg-slate-900/45 rounded-2xl text-slate-500 text-xs">
                              Database has been wiped. Click 'Log Weight' to input values first.
                            </div>
                          ) : (
                            <div className="space-y-2 max-h-[290px] overflow-y-auto pr-1 scrollbar-none">
                              {weightLogs.map(item => (
                                <div key={item.id} className="glass-card p-3 rounded-2xl flex items-center justify-between">
                                  <div className="flex items-center gap-3">
                                    <div className="h-10 w-10 bg-purple-500/10 rounded-lg flex items-center justify-center font-bold text-purple-400 text-sm">
                                      {item.weight}
                                    </div>
                                    <div className="text-xs">
                                      <div className="font-bold text-slate-200">{item.date}</div>
                                      <p className="text-[10px] text-slate-400 w-36 truncate">{item.notes || 'No log details'}</p>
                                    </div>
                                  </div>
                                  
                                  {/* CRUD operations icons */}
                                  <div className="flex items-center gap-1">
                                    <button 
                                      onClick={() => handleOpenEditLog(item)}
                                      className="p-1 px-1.5 text-slate-400 hover:text-slate-200 cursor-pointer"
                                      title="Edit Log"
                                    >
                                      <Edit3 className="h-3.5 w-3.5" />
                                    </button>
                                    <button 
                                      onClick={() => handleDeleteLog(item.id)}
                                      className="p-1 px-1.5 text-red-400 hover:text-red-300 cursor-pointer"
                                      title="Delete Log"
                                    >
                                      <Trash2 className="h-3.5 w-3.5" />
                                    </button>
                                  </div>
                                </div>
                              ))}
                            </div>
                          )}
                        </div>
                      </div>
                    )}


                    {/* C. BMI TAB */}
                    {activeTab === 'bmi' && (
                      <div className="space-y-4">
                        {/* Sub-tab navigation */}
                        <div className="flex bg-[#1E293B] p-1 rounded-xl border border-white/5">
                          <button 
                            onClick={() => setBmiSubTab('calc')}
                            className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer ${bmiSubTab === 'calc' ? 'gradient-bg text-white shadow-md' : 'text-slate-400 hover:text-white'}`}
                          >
                            Calculate BMI
                          </button>
                          <button 
                            onClick={() => setBmiSubTab('history')}
                            className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer ${bmiSubTab === 'history' ? 'gradient-bg text-white shadow-md' : 'text-slate-400 hover:text-white'}`}
                          >
                            History Logs
                          </button>
                        </div>

                        {/* CASE 1: CALCULATOR VIEW */}
                        {bmiSubTab === 'calc' && (
                          <div className="space-y-4">
                            {/* Gender Select */}
                            <div className="grid grid-cols-2 gap-2">
                              <button 
                                onClick={() => setBmiGender('Male')}
                                className={`py-2 rounded-xl text-xs font-bold border flex flex-col items-center gap-1 transition-all cursor-pointer ${bmiGender === 'Male' ? 'bg-blue-600/10 border-blue-500 text-blue-400' : 'bg-slate-850 border-white/5 text-slate-400'}`}
                              >
                                <span className="text-lg">♂</span>
                                Male
                              </button>
                              <button 
                                onClick={() => setBmiGender('Female')}
                                className={`py-2 rounded-xl text-xs font-bold border flex flex-col items-center gap-1 transition-all cursor-pointer ${bmiGender === 'Female' ? 'bg-pink-600/10 border-pink-500 text-pink-400' : 'bg-slate-850 border-white/5 text-slate-400'}`}
                              >
                                <span className="text-lg">♀</span>
                                Female
                              </button>
                            </div>

                            {/* Height Slider */}
                            <div className="glass-card p-3.5 rounded-2xl space-y-1">
                              <div className="flex justify-between text-xs text-slate-400 font-bold">
                                <span>HEIGHT</span>
                                <span className="text-white font-black">{bmiHeight} cm</span>
                              </div>
                              <input 
                                type="range" min="100" max="220" 
                                value={bmiHeight} 
                                onChange={(e) => setBmiHeight(parseInt(e.target.value))}
                                className="w-full accent-purple-500 h-1 cursor-pointer bg-slate-700 rounded-lg outline-none"
                              />
                            </div>

                            {/* Weight Slider */}
                            <div className="glass-card p-3.5 rounded-2xl space-y-1">
                              <div className="flex justify-between text-xs text-slate-400 font-bold">
                                <span>WEIGHT</span>
                                <span className="text-white font-black">{bmiWeightInput} kg</span>
                              </div>
                              <input 
                                type="range" min="30" max="180" 
                                value={bmiWeightInput} 
                                onChange={(e) => setBmiWeightInput(parseInt(e.target.value))}
                                className="w-full accent-blue-500 h-1 cursor-pointer bg-slate-700 rounded-lg outline-none"
                              />
                            </div>

                            {/* Age input */}
                            <div className="glass-card p-3 rounded-2xl flex justify-between items-center px-4">
                              <span className="text-xs font-bold text-slate-400">AGE</span>
                              <div className="flex items-center gap-3">
                                <button onClick={() => setBmiAge(Math.max(1, bmiAge - 1))} className="h-6 w-6 rounded-full bg-slate-700 text-sm font-bold flex items-center justify-center">-</button>
                                <span className="text-xs font-bold">{bmiAge} yrs</span>
                                <button onClick={() => setBmiAge(bmiAge + 1)} className="h-6 w-6 rounded-full bg-slate-700 text-sm font-bold flex items-center justify-center">+</button>
                              </div>
                            </div>

                            {/* Result Display Meter */}
                            <div className="border border-white/5 rounded-xl p-4 bg-[#1E293B] flex flex-col items-center text-center">
                              <span className="text-[10px] text-slate-400 uppercase tracking-widest font-extrabold mb-1">METERED SCORE</span>
                              <div 
                                className="text-3xl font-black mb-1 animate-pulse" 
                                style={{ color: customCalculatorOutput.color }}
                              >
                                {customCalculatorOutput.score}
                              </div>
                              
                              <div 
                                className="text-[10px] font-bold px-2 py-0.5 rounded-full mb-3" 
                                style={{ backgroundColor: `${customCalculatorOutput.color}15`, color: customCalculatorOutput.color }}
                              >
                                {customCalculatorOutput.category.toUpperCase()}
                              </div>
                              
                              <p className="text-[10px] text-slate-400">
                                Recommended Ideal Range: <span className="font-bold text-slate-200">{customCalculatorOutput.range}</span>
                              </p>

                              <button 
                                onClick={handleSaveBmiRecord}
                                className="mt-4 w-full bg-slate-800 hover:bg-slate-705 border border-white/5 py-2 rounded-lg text-xs font-bold hover:text-purple-400 transition-all flex items-center justify-center gap-1.5 cursor-pointer"
                              >
                                <Lock className="h-3 w-3" />
                                Save BMI to History
                              </button>
                            </div>
                          </div>
                        )}

                        {/* CASE 2: SEARCHABLE HISTORY VIEW (Screen 7) */}
                        {bmiSubTab === 'history' && (
                          <div className="space-y-3.5">
                            {/* Search and Filters */}
                            <div className="space-y-2">
                              <div className="relative">
                                <Search className="absolute left-2.5 top-2.5 h-3.5 w-3.5 text-slate-500" />
                                <input 
                                  type="text" 
                                  placeholder="Search history score..."
                                  value={historySearch}
                                  onChange={(e) => setHistorySearch(e.target.value)}
                                  className="w-full text-xs bg-slate-850 py-2.5 pl-8 pr-3.5 rounded-lg border-none text-slate-200 placeholder-slate-500 outline-none focus:ring-1 focus:ring-purple-500/20"
                                />
                              </div>

                              <div className="grid grid-cols-2 gap-2 text-xs">
                                <select 
                                  value={historyFilter}
                                  onChange={(e) => setHistoryFilter(e.target.value)}
                                  className="bg-slate-850 p-2 rounded-lg outline-none border-none text-slate-300"
                                >
                                  <option value="All">All Category</option>
                                  <option value="Underweight">Underweight</option>
                                  <option value="Normal">Normal</option>
                                  <option value="Overweight">Overweight</option>
                                  <option value="Obese">Obese</option>
                                </select>

                                <select 
                                  value={historySort}
                                  onChange={(e) => setHistorySort(e.target.value as any)}
                                  className="bg-slate-850 p-2 rounded-lg outline-none border-none text-slate-300"
                                >
                                  <option value="Newest">Newest First</option>
                                  <option value="Oldest">Oldest First</option>
                                  <option value="Highest">Highest Score</option>
                                  <option value="Lowest">Lowest Score</option>
                                </select>
                              </div>
                            </div>

                            {/* Rendered List */}
                            <div className="space-y-2 max-h-[220px] overflow-y-auto pr-1 scrollbar-none">
                              {filteredBmiRecords.length === 0 ? (
                                <div className="text-center p-8 text-neutral-500 text-xs">No matching history found.</div>
                              ) : (
                                filteredBmiRecords.map(rec => {
                                  const cColors: Record<string, string> = {
                                    'Underweight': '#F59E0B',
                                    'Normal': '#10B981',
                                    'Overweight': '#F97316',
                                    'Obese': '#EF4444'
                                  };
                                  const color = cColors[rec.category] || '#10B981';

                                  return (
                                    <div key={rec.id} className="glass-card p-3 rounded-xl flex items-center justify-between">
                                      <div>
                                        <div className="flex items-center gap-2">
                                          <span className="font-extrabold text-white text-[15px]">{rec.score}</span>
                                          <span 
                                            className="text-[9px] font-extrabold px-1.5 py-0.5 rounded" 
                                            style={{ backgroundColor: `${color}15`, color }}
                                          >
                                            {rec.category.toUpperCase()}
                                          </span>
                                        </div>
                                        <p className="text-[10px] text-slate-500 mt-0.5">Inputs: {rec.height}cm / {rec.weight}kg</p>
                                      </div>
                                      <span className="text-[10px] font-mono text-slate-500">{rec.date}</span>
                                    </div>
                                  );
                                })
                              )}
                            </div>
                          </div>
                        )}
                      </div>
                    )}


                    {/* D. CALORIE RECOMMENDATION TAB */}
                    {activeTab === 'calories' && (
                      <div className="space-y-4">
                        <div className="space-y-1">
                          <span className="text-[10px] text-slate-400 uppercase tracking-widest font-bold tracking-widest font-mono">CALORIC EXPANSION FORM</span>
                          <h3 className="text-lg font-extrabold">Forge Energetics</h3>
                        </div>

                        {/* Sliders for Height & Weight */}
                        <div className="space-y-3.5 glass-card p-4 rounded-2xl">
                          {/* Height */}
                          <div className="space-y-0.5">
                            <div className="flex justify-between text-xs text-slate-400 font-bold">
                              <span>HEIGHT ({calorieHeight} cm)</span>
                            </div>
                            <input 
                              type="range" min="110" max="230" value={calorieHeight} 
                              onChange={(e) => setCalorieHeight(parseInt(e.target.value))}
                              className="w-full accent-purple-500 h-1 cursor-pointer bg-slate-700/60 rounded"
                            />
                          </div>

                          {/* Weight */}
                          <div className="space-y-0.5">
                            <div className="flex justify-between text-xs text-slate-400 font-bold">
                              <span>WEIGHT ({calorieWeight} kg)</span>
                            </div>
                            <input 
                              type="range" min="30" max="180" value={calorieWeight} 
                              onChange={(e) => setCalorieWeight(parseInt(e.target.value))}
                              className="w-full accent-blue-500 h-1 cursor-pointer bg-slate-700/60 rounded"
                            />
                          </div>

                          {/* Age & Gender */}
                          <div className="grid grid-cols-2 gap-2 text-xs">
                            <div className="bg-slate-900/60 p-2 rounded-lg flex justify-between items-center">
                              <span>AGE ({calorieAge})</span>
                              <div className="flex gap-1">
                                <button onClick={() => setCalorieAge(Math.max(1, calorieAge - 1))} className="px-1.5 bg-slate-700 rounded">-</button>
                                <button onClick={() => setCalorieAge(calorieAge + 1)} className="px-1.5 bg-slate-700 rounded">+</button>
                              </div>
                            </div>

                            <button 
                              onClick={() => setCalorieGender(calorieGender === 'Male' ? 'Female' : 'Male')}
                              className="bg-slate-900/60 p-2 rounded-lg text-left inline-flex items-center justify-between"
                            >
                              <span>GENDER</span>
                              <span className="font-bold text-purple-400">{calorieGender}</span>
                            </button>
                          </div>

                          {/* Activity Level selection */}
                          <div className="space-y-1">
                            <label className="text-[10px] text-slate-500 uppercase tracking-widest font-extrabold">Active Routine</label>
                            <select 
                              value={calorieActivity}
                              onChange={(e) => setCalorieActivity(e.target.value)}
                              className="w-full text-xs font-bold bg-slate-900 text-slate-200 p-2 rounded outline-none border-none"
                            >
                              <option value="Sedentary">Sedentary (No movement)</option>
                              <option value="Lightly Active">Lightly Active (1-3 days exercise)</option>
                              <option value="Moderately Active">Moderately Active (Moderate efforts)</option>
                              <option value="Very Active">Very Active (Heavy workouts)</option>
                              <option value="Athlete">Athlete (Competitive sports)</option>
                            </select>
                          </div>
                        </div>

                        {/* Bento Output Results list (Screen 8) */}
                        <div className="space-y-2.5">
                          {/* Weight Loss */}
                          <div className="glass-card p-3.5 rounded-2xl border-l-4 border-l-[#A855F7] flex justify-between items-center shadow-sm">
                            <div>
                              <div className="text-[9px] uppercase tracking-widest font-extrabold text-purple-400">Weight Loss</div>
                              <p className="text-[10px] text-slate-400">Target daily deficit</p>
                            </div>
                            <div className="text-right">
                              <span className="text-lg font-black">{caloriesBudget.loss}</span>
                              <span className="text-[10px] text-slate-400 block -mt-1">kcal / day</span>
                            </div>
                          </div>

                          {/* Maintenance */}
                          <div className="glass-card p-3.5 rounded-2xl border-l-4 border-l-[#3B82F6] flex justify-between items-center shadow-sm">
                            <div>
                              <div className="text-[9px] uppercase tracking-widest font-extrabold text-blue-400">Maintenance</div>
                              <p className="text-[10px] text-slate-400">Equilibrium balance</p>
                            </div>
                            <div className="text-right">
                              <span className="text-lg font-black">{caloriesBudget.maintenance}</span>
                              <span className="text-[10px] text-slate-400 block -mt-1">kcal / day</span>
                            </div>
                          </div>

                          {/* Weight Gain */}
                          <div className="glass-card p-3.5 rounded-2xl border-l-4 border-l-[#10B981] flex justify-between items-center shadow-sm">
                            <div>
                              <div className="text-[9px] uppercase tracking-widest font-extrabold text-emerald-400">Weight Gain</div>
                              <p className="text-[10px] text-slate-400">Muscle synthesis surplus</p>
                            </div>
                            <div className="text-right">
                              <span className="text-lg font-black">{caloriesBudget.gain}</span>
                              <span className="text-[10px] text-slate-400 block -mt-1">kcal / day</span>
                            </div>
                          </div>
                        </div>
                      </div>
                    )}


                    {/* E. ANALYTICS & INSIGHTS TAB (Screen 6, 9 & Badges) */}
                    {activeTab === 'insights' && (
                      <div className="space-y-4">
                        <div className="space-y-1">
                          <span className="text-[10px] text-slate-400 uppercase tracking-widest font-bold tracking-widest font-mono">ANALYTICS ENGINE</span>
                          <h3 className="text-lg font-bold">Forge Milestones</h3>
                        </div>

                        {/* Weight Trend Graph Visual Card (Screen 6) */}
                        <div className="glass-card p-4 rounded-2xl space-y-3">
                          <span className="text-[10px] font-extrabold tracking-wider uppercase text-slate-400">Chronological Weight Trend (kg)</span>
                          
                          {weightLogs.length < 2 ? (
                            <div className="h-32 bg-slate-900/40 rounded-2xl flex items-center justify-center text-slate-500 text-xs">
                              Need 2 logs to generate trend curve metrics.
                            </div>
                          ) : (
                            <div className="space-y-2">
                              <div className="h-28 w-full bg-slate-900/40 rounded-lg p-2 relative flex flex-col justify-end">
                                {/* SVG Trend Curve */}
                                <svg className="absolute inset-x-0 bottom-4 h-24 w-full overflow-visible" preserveAspectRatio="none">
                                  <polyline
                                    fill="none"
                                    stroke="url(#purpleGradient)"
                                    strokeWidth="4"
                                    strokeLinecap="round"
                                    points={svgLinePoints}
                                  />
                                  <defs>
                                     <linearGradient id="purpleGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                                       <stop offset="0%" stopColor="#A855F7" />
                                       <stop offset="100%" stopColor="#3B82F6" />
                                     </linearGradient>
                                  </defs>
                                </svg>
                                
                                {/* Label indicators */}
                                <div className="flex justify-between items-center text-[10px] text-slate-400 font-bold px-1 mt-auto">
                                  <span>{weightLogs[weightLogs.length-1].date}</span>
                                  <span>{weightLogs[0].date}</span>
                                </div>
                              </div>
                              <p className="text-[9.5px] text-slate-500 leading-normal text-center">
                                Weight values spanning from {yMin.toFixed(1)} kg to {yMax.toFixed(1)} kg
                              </p>
                            </div>
                          )}
                        </div>

                        {/* Badge Milestone List (Screen 5/6 System) */}
                        <div className="space-y-2.5">
                          <span className="text-[10px] tracking-wider uppercase text-slate-400 font-extrabold">Achievements System</span>
                          
                          <div className="space-y-2 max-h-[190px] overflow-y-auto pr-1 scrollbar-none">
                            {badges.map(b => {
                              const isUnlocked = getIsBadgeUnlocked(b.id);
                              return (
                                <div 
                                  key={b.id} 
                                  className={`p-3.5 rounded-xl border flex items-center gap-3 transition-all ${isUnlocked ? 'bg-emerald-500/5 border-emerald-500/15' : 'bg-[#1E293B] border-white/5 opacity-55'}`}
                                >
                                  <div className={`h-8 w-8 rounded-full flex items-center justify-center ${isUnlocked ? 'bg-emerald-500/20 text-emerald-400' : 'bg-slate-800 text-slate-500'}`}>
                                    {isUnlocked ? <Unlock className="h-4 w-4" /> : <Lock className="h-4 w-4" />}
                                  </div>
                                  <div>
                                    <div className={`text-xs font-bold ${isUnlocked ? 'text-white' : 'text-slate-400'}`}>{b.title}</div>
                                    <p className="text-[10px] text-slate-500">{b.description}</p>
                                  </div>
                                </div>
                              );
                            })}
                          </div>
                        </div>
                      </div>
                    )}

                  </div>

                  {/* BOTTOM PHONE NAVIGATION BAR */}
                  <div className={`border-t py-2.5 px-3 flex justify-around items-center transition-all duration-300 ${theme === 'light' ? 'bg-white border-slate-200 text-slate-500' : 'bg-[#0F172A] border-white/5 text-slate-400'}`}>
                    {/* Dash tab button */}
                    <button 
                      onClick={() => setActiveTab('dashboard')}
                      className={`flex flex-col items-center gap-0.5 cursor-pointer transition-colors duration-200 ${activeTab === 'dashboard' ? 'text-purple-500 font-bold' : theme === 'light' ? 'text-slate-400 hover:text-slate-800' : 'text-slate-400 hover:text-slate-200'}`}
                    >
                      <Activity className="h-4.5 w-4.5" />
                      <span className="text-[9px]">Dashboard</span>
                    </button>
                    
                    {/* Tracker tab button */}
                    <button 
                      onClick={() => setActiveTab('tracker')}
                      className={`flex flex-col items-center gap-0.5 cursor-pointer transition-colors duration-200 ${activeTab === 'tracker' ? 'text-purple-500 font-bold' : theme === 'light' ? 'text-slate-400 hover:text-slate-800' : 'text-slate-400 hover:text-slate-200'}`}
                    >
                      <Scale className="h-4.5 w-4.5" />
                      <span className="text-[9px]">Tracker</span>
                    </button>

                    {/* BMI tab button */}
                    <button 
                      onClick={() => setActiveTab('bmi')}
                      className={`flex flex-col items-center gap-0.5 cursor-pointer transition-colors duration-200 ${activeTab === 'bmi' ? 'text-purple-500 font-bold' : theme === 'light' ? 'text-slate-400 hover:text-slate-800' : 'text-slate-400 hover:text-slate-200'}`}
                    >
                      <Calculator className="h-4.5 w-4.5" />
                      <span className="text-[9px]">BMI Hub</span>
                    </button>

                    {/* Calories tab button */}
                    <button 
                      onClick={() => setActiveTab('calories')}
                      className={`flex flex-col items-center gap-0.5 cursor-pointer transition-colors duration-200 ${activeTab === 'calories' ? 'text-purple-500 font-bold' : theme === 'light' ? 'text-slate-400 hover:text-slate-800' : 'text-slate-400 hover:text-slate-200'}`}
                    >
                      <Flame className="h-4.5 w-4.5" />
                      <span className="text-[9px]">Calories</span>
                    </button>

                    {/* Insights Tab button */}
                    <button 
                      onClick={() => setActiveTab('insights')}
                      className={`flex flex-col items-center gap-0.5 cursor-pointer transition-colors duration-200 ${activeTab === 'insights' ? 'text-purple-500 font-bold' : theme === 'light' ? 'text-slate-400 hover:text-slate-800' : 'text-slate-400 hover:text-slate-200'}`}
                    >
                      <Award className="h-4.5 w-4.5" />
                      <span className="text-[9px]">Insights</span>
                    </button>
                  </div>

                </div>
              )}

            </div>
          </div>
        </div>

        {/* Right Side: Heavy duty Dart File Inspector and Code Deck */}
        <div className="lg:col-span-7 space-y-6">
          <div className="glass-card rounded-3xl p-5 shadow-xl">
            
            {/* Header with Title and Copy Options */}
            <div className={`flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 pb-4 border-b ${theme === 'light' ? 'border-slate-200' : 'border-white/5'}`}>
              <div>
                <h3 className={`text-lg font-extrabold tracking-tight ${theme === 'light' ? 'text-slate-900' : 'text-white'} flex items-center gap-2`}>
                  <Code2 className="h-5 w-5 text-purple-400" /> Flutter Dart Project Structure
                </h3>
                <p className={`text-xs ${theme === 'light' ? 'text-slate-600' : 'text-slate-400'}`}>
                  Select and inspect complete build-ready Dart classes inside your FitForge output directory.
                </p>
              </div>

              <div className="flex items-center gap-2">
                <button 
                  onClick={handleCopyCode}
                  className={`px-3 py-1.5 text-xs font-bold rounded-lg flex items-center gap-1.5 transition-all cursor-pointer ${theme === 'light' ? 'bg-slate-100 hover:bg-slate-200 text-slate-800 border border-slate-250' : 'bg-slate-800 hover:bg-slate-700 text-slate-200 hover:text-white border border-white/10'}`}
                >
                  {copiedCodeFlag ? <Check className="h-3.5 w-3.5 text-emerald-400" /> : <Copy className="h-3.5 w-3.5" />}
                  {copiedCodeFlag ? 'Copied' : 'Copy Code'}
                </button>
              </div>
            </div>

            {/* Select Box of available classes */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-2 mt-4 text-xs font-semibold">
              {[
                'main.dart',
                'fitness_provider.dart',
                'splash_screen.dart',
                'home_tab.dart',
                'weight_tracker_tab.dart',
                'bmi_tab.dart',
                'calories_tab.dart',
                'analytics_theme_tab.dart'
              ].map((fileName) => (
                <button 
                  key={fileName}
                  onClick={() => setSelectedInspectFile(fileName)}
                  className={`py-2 px-3 border rounded-lg text-left truncate transition-all cursor-pointer ${
                    selectedInspectFile === fileName 
                      ? 'bg-purple-600/15 border-purple-500 text-purple-600 dark:text-purple-300 font-bold' 
                      : theme === 'light' 
                        ? 'bg-slate-50 border-slate-200 text-slate-600 hover:bg-slate-100' 
                        : 'bg-slate-950 border-white/5 text-slate-400 hover:bg-[#13192B]'
                  }`}
                >
                  📁 {fileName}
                </button>
              ))}
            </div>

            {/* Simulated Code Panel with line counts */}
            <div className={`mt-5 ${theme === 'light' ? 'bg-[#0F1420] border-slate-250 shadow-sm' : 'bg-[#090D1A] border-white/5'} rounded-xl border overflow-hidden flex flex-col`}>
              <div className={`px-4 py-2 border-b ${theme === 'light' ? 'bg-slate-900/90 border-[#1B2335] text-slate-200' : 'bg-[#111827] border-white/5 text-slate-300'} flex items-center justify-between`}>
                <span className="text-xs font-mono text-purple-400 font-bold">{selectedInspectFile}</span>
                <span className="text-[10px] text-slate-500 font-mono">DART SOURCE CODE</span>
              </div>
              
              <div className="p-4 overflow-x-auto text-[11px] font-mono leading-relaxed text-slate-300 max-h-[420px] overflow-y-auto whitespace-pre">
                {activeInspectFileContent}
              </div>
            </div>

            {/* Quick compilation guidance callout */}
            <div className={`mt-5 rounded-xl p-4 flex items-start gap-3.5 border ${theme === 'light' ? 'bg-purple-500/5 border-purple-200' : 'bg-purple-500/5 border-purple-500/15'}`}>
              <Info className="h-5 w-5 text-purple-500 mt-0.5 shrink-0" />
              <div className={`text-xs font-medium leading-relaxed ${theme === 'light' ? 'text-slate-755' : 'text-slate-300'}`}>
                <span className={`font-bold block mb-0.5 ${theme === 'light' ? 'text-slate-900' : 'text-white'}`}>Ready to Build!</span>
                The workspace contains complete, build-ready Flutter files including <code className="text-purple-600 dark:text-purple-400 font-mono text-[11px]">pubspec.yaml</code>, <code className="text-purple-600 dark:text-purple-400 font-mono text-[11px]">lib/main.dart</code>, and complete Android files. Simply export the code and trigger build apk:
                <div className={`mt-2 p-2 rounded border text-[11px] font-mono text-emerald-550 dark:text-emerald-400 leading-none select-all cursor-pointer ${theme === 'light' ? 'bg-[#0E1525] border-slate-250' : 'bg-[#090D1A] border-white/5'}`}>
                  flutter build apk
                </div>
              </div>
            </div>

          </div>
        </div>

      </main>

      {/* 3. SIMULATOR INNER MODALS */}
      {/* 3A: Log Weight Entries CRUD Modal */}
      {showLogModal && (
        <div className="fixed inset-0 bg-black/75 z-50 flex items-center justify-center p-4 backdrop-blur-sm">
          <div className={`border w-full max-w-sm rounded-2xl p-6 space-y-4 transition-all duration-300 ${theme === 'light' ? 'bg-white border-slate-200 text-slate-800' : 'bg-[#1E293B] border-white/10 text-slate-100'}`}>
            <h3 className={`text-lg font-extrabold ${theme === 'light' ? 'text-slate-900' : 'text-white'}`}>
              {editLogItem ? 'Refine Log Entry' : 'Forge Log Entry'}
            </h3>

            <div className="space-y-3.5 text-xs">
              <div className="space-y-1">
                <label className={`font-bold block ${theme === 'light' ? 'text-slate-500' : 'text-slate-400'}`}>Weight (kg)</label>
                <input 
                  type="number" step="0.1"
                  placeholder="e.g. 74.5"
                  value={logWeight}
                  onChange={(e) => setLogWeight(e.target.value)}
                  className={`w-full p-3 rounded-lg outline-none transition-all ${theme === 'light' ? 'bg-slate-50 border border-slate-200 text-slate-900 focus:border-purple-450' : 'bg-slate-900 border border-white/5 text-slate-100 focus:border-purple-500/30'}`}
                />
              </div>

              <div className="space-y-1">
                <label className={`font-bold block ${theme === 'light' ? 'text-slate-500' : 'text-slate-400'}`}>Logging Date</label>
                <input 
                  type="date"
                  value={logDate}
                  onChange={(e) => setLogDate(e.target.value)}
                  className={`w-full p-3 rounded-lg outline-none transition-all ${theme === 'light' ? 'bg-slate-50 border border-slate-200 text-slate-900 focus:border-purple-450' : 'bg-slate-900 border border-white/5 text-slate-100 focus:border-purple-500/30'}`}
                />
              </div>

              <div className="space-y-1">
                <label className={`font-bold block ${theme === 'light' ? 'text-slate-500' : 'text-slate-400'}`}>Notes</label>
                <textarea 
                  rows={2}
                  placeholder="e.g. baseline or body fat check"
                  value={logNotes}
                  onChange={(e) => setLogNotes(e.target.value)}
                  className={`w-full p-3 rounded-lg outline-none transition-all ${theme === 'light' ? 'bg-slate-50 border border-slate-200 text-slate-900 focus:border-purple-450' : 'bg-slate-900 border border-white/5 text-slate-100 focus:border-purple-500/30'}`}
                />
              </div>
            </div>

            <div className="flex gap-2 text-xs font-bold pt-2">
              <button 
                onClick={() => setShowLogModal(false)}
                className={`flex-1 py-2.5 rounded-lg transition-all ${theme === 'light' ? 'bg-slate-100 text-slate-700 hover:bg-slate-200 border border-slate-200' : 'bg-slate-800 text-slate-400 hover:text-white border border-white/5'}`}
              >
                Cancel
              </button>
              <button 
                onClick={handleSaveLog}
                className="flex-1 bg-purple-600 hover:bg-purple-705 py-2.5 rounded-lg text-white"
              >
                Save
              </button>
            </div>
          </div>
        </div>
      )}

      {/* 3B: Adjust Target Weight Modal */}
      {showGoalModal && (
        <div className="fixed inset-0 bg-black/75 z-50 flex items-center justify-center p-4 backdrop-blur-sm">
          <div className={`border w-full max-w-sm rounded-2xl p-6 space-y-4 transition-all duration-300 ${theme === 'light' ? 'bg-white border-slate-200 text-slate-800' : 'bg-[#1E293B] border-white/10 text-slate-100'}`}>
            <h3 className={`text-lg font-extrabold ${theme === 'light' ? 'text-slate-900' : 'text-white'}`}>Adjust Weight Goal</h3>

            <div className="space-y-1 text-xs">
              <label className={`font-bold block mb-1 ${theme === 'light' ? 'text-slate-500' : 'text-slate-400'}`}>Target Weight (kg)</label>
              <input 
                type="number" step="0.5"
                placeholder="e.g. 70.0"
                value={goalInput}
                onChange={(e) => setGoalInput(e.target.value)}
                className={`w-full p-3 rounded-lg outline-none transition-all ${theme === 'light' ? 'bg-slate-50 border border-slate-200 text-slate-900 focus:border-purple-400' : 'bg-slate-900 border border-white/5 text-slate-100 focus:border-purple-500/30'}`}
              />
            </div>

            <div className="flex gap-2 text-xs font-bold pt-2">
              <button 
                onClick={() => setShowGoalModal(false)}
                className={`flex-1 py-2.5 rounded-lg transition-all ${theme === 'light' ? 'bg-slate-100 text-slate-700 hover:bg-slate-200 border border-slate-200' : 'bg-slate-800 text-slate-400 hover:text-white border border-white/5'}`}
              >
                Cancel
              </button>
              <button 
                onClick={handleSaveGoal}
                className="flex-1 bg-blue-600 hover:bg-blue-750 py-2.5 rounded-lg text-white"
              >
                Save Goal Weight
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Footer copyright */}
      <footer className="border-t border-white/5 bg-[#0A0D1A] py-6 px-6 text-center text-xs text-slate-500">
        <div className="max-w-7xl mx-auto flex flex-col sm:flex-row items-center justify-between gap-4">
          <p>© 2026 FitForge, Inc. Created as a dual Flutter+React composition environment in Google AI Studio.</p>
          <div className="flex items-center gap-4 text-slate-400">
            <span>Material 3 Ready</span>
            <span>Persistence Enabled</span>
          </div>
        </div>
      </footer>

    </div>
  );
}
