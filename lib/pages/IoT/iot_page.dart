import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnergyUsagePage extends StatefulWidget {
  const EnergyUsagePage({super.key});

  @override
  State<EnergyUsagePage> createState() => _IotPageState();
}

class _IotPageState extends State<EnergyUsagePage> {
  List<double> monthlyData = List.filled(12, 0.0);
  bool isLoading = false;
  final List<String> months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUN',
    'JUL',
    'AUG',
    'SEP',
    'OCT',
    'NOV',
    'DEC',
  ];
  final List<String> monthsFull = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  late final int initialDay = DateTime.now().day - 1;
  late final int currentYear = DateTime.now().year;
  late final int currentMonth = DateTime.now().month - 1;

  int selectedYear = DateTime.now().year;
  int touchedIndex = DateTime.now().month - 1;
  int selectedMonth = DateTime.now().month - 1;
  int selectedYearForMonth = DateTime.now().year;
  int currentDayIndex = DateTime.now().day - 1;

  Map<String, double> categoryUsage = {
    'lighting': 0.0,
    'hvac': 0.0,
    'device': 0.0,
    'network': 0.0,
  };

  final Map<String, Map<String, dynamic>> categoryMeta = {
    'lighting': {
      'icon': Icons.lightbulb_outline,
      'color': Colors.amber,
      'label': 'LIGHTING',
    },
    'hvac': {'icon': Icons.ac_unit, 'color': Colors.redAccent, 'label': 'HVAC'},
    'device': {
      'icon': Icons.print,
      'color': Colors.deepPurpleAccent,
      'label': 'DEVICE',
    },
    'network': {
      'icon': Icons.dns,
      'color': Colors.blueAccent,
      'label': 'NETWORK',
    },
  };

  Set<int> availableYears = {};
  Map<int, Set<int>> yearToMonths = {};
  Map<String, double> dailyCategoryUsage = {
    'lighting': 0.0,
    'hvac': 0.0,
    'device': 0.0,
    'network': 0.0,
  };
  List<double> dailyData = [];
  String viewMode = 'MONTHLY';
  bool isCategoryLoading = false;
  bool isDailyCategoryLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMonthlyUsage();
    fetchCategoryUsage();
    fetchAvailableYearsAndMonths();
    fetchDailyCategoryUsage();
  }

  Future<void> fetchMonthlyUsage() async {
    setState(() {
      isLoading = true;
    });
    final response = await Supabase.instance.client
        .from('daily_usage')
        .select('date, usage_kwh')
        .gte('date', DateTime(selectedYear, 1, 1).toIso8601String())
        .lte(
          'date',
          DateTime(selectedYear, 12, 31, 23, 59, 59).toIso8601String(),
        );
    // Reset monthly data
    List<double> monthly = List.filled(12, 0.0);
    for (final row in response) {
      final date = DateTime.parse(row['date']);
      final monthIdx = date.month - 1;
      final usage = (row['usage_kwh'] as num?)?.toDouble() ?? 0.0;
      monthly[monthIdx] += usage;
    }
    setState(() {
      monthlyData = monthly;
      isLoading = false;
    });
  }

  Future<void> fetchCategoryUsage() async {
    setState(() {
      isCategoryLoading = true;
    });
    final response = await Supabase.instance.client
        .from('v_monthly_category_usage')
        .select()
        .eq('year', selectedYear)
        .eq('month', touchedIndex + 1); // touchedIndex is 0-based
    // Reset
    Map<String, double> usage = {
      'lighting': 0.0,
      'hvac': 0.0,
      'device': 0.0,
      'network': 0.0,
    };
    for (final row in response) {
      final cat = (row['category'] as String).toLowerCase();
      final val = (row['total_kwh'] as num?)?.toDouble() ?? 0.0;
      if (usage.containsKey(cat)) usage[cat] = val;
    }
    setState(() {
      categoryUsage = usage;
      isCategoryLoading = false;
    });
  }

  Future<void> fetchAvailableYearsAndMonths() async {
    final response = await Supabase.instance.client
        .from('daily_usage')
        .select('date');
    final Map<int, Set<int>> yToM = {};
    for (final row in response) {
      final date = DateTime.parse(row['date']);
      yToM.putIfAbsent(date.year, () => <int>{});
      yToM[date.year]!.add(date.month - 1); // Dart months are 0-based
    }
    setState(() {
      yearToMonths = yToM;
      availableYears = yToM.keys.toSet();
      // If current selectedYearForMonth is not available, select the first available
      if (!availableYears.contains(selectedYearForMonth) &&
          availableYears.isNotEmpty) {
        selectedYearForMonth = availableYears.first;
      }
      // If current selectedMonth is not available for the year, select the first available
      final monthsForYear = yearToMonths[selectedYearForMonth] ?? {};
      if (!monthsForYear.contains(selectedMonth) && monthsForYear.isNotEmpty) {
        selectedMonth = monthsForYear.first;
      }
      fetchDailyData();
      fetchDailyCategoryUsage();
    });
  }

  Future<void> fetchDailyData() async {
    final int year = selectedYearForMonth;
    final int month = selectedMonth + 1; // Dart months are 0-based
    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final response = await Supabase.instance.client
        .from('daily_usage')
        .select('date, usage_kwh')
        .gte('date', DateTime(year, month, 1).toIso8601String())
        .lte(
          'date',
          DateTime(year, month, daysInMonth, 23, 59, 59).toIso8601String(),
        );
    // Aggregate usage by day
    List<double> daily = List.filled(daysInMonth, 0.0);
    for (final row in response) {
      final date = DateTime.parse(row['date']);
      final dayIdx = date.day - 1;
      final usage = (row['usage_kwh'] as num?)?.toDouble() ?? 0.0;
      daily[dayIdx] += usage;
    }
    setState(() {
      dailyData = daily;
      // Adjust currentDayIndex if out of range
      if (currentDayIndex >= daysInMonth) {
        currentDayIndex = daysInMonth - 1;
      }
    });
  }

  Future<void> fetchDailyCategoryUsage() async {
    setState(() {
      isDailyCategoryLoading = true;
    });
    final int year = selectedYearForMonth;
    final int month = selectedMonth + 1;
    final int day = currentDayIndex + 1;
    final response = await Supabase.instance.client
        .from('v_daily_category_usage')
        .select()
        .eq('year', year)
        .eq('month', month)
        .eq('day', day);
    Map<String, double> usage = {
      'lighting': 0.0,
      'hvac': 0.0,
      'device': 0.0,
      'network': 0.0,
    };
    for (final row in response) {
      final cat = (row['category'] as String).toLowerCase();
      final val = (row['total_kwh'] as num?)?.toDouble() ?? 0.0;
      if (usage.containsKey(cat)) usage[cat] = val;
    }
    setState(() {
      dailyCategoryUsage = usage;
      isDailyCategoryLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double totalYearlyEnergy = monthlyData.fold(0.0, (a, b) => a + b);
    final double totalForMonth = categoryUsage.values.fold(
      0.0,
      (a, b) => a + b,
    );
    final List<int> monthsList =
        (yearToMonths[selectedYearForMonth]?.toList() ?? [])..sort();
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Energy usage",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 40),
              // ENERGY GENERATED + dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ENERGY GENERATED',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.flash_on,
                            color: Colors.amber,
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Text.rich(
                            TextSpan(
                              text: totalYearlyEnergy.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.headlineMedium,
                              children: [
                                const TextSpan(
                                  text: '  kwh', // your dynamic status
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: AppDecorations.cardDecoration(context),
                    width: MediaQuery.of(context).size.width * 0.35,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    child: DropdownButton<String>(
                      borderRadius: BorderRadius.circular(12),
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      value: viewMode,
                      underline: const SizedBox(),
                      isExpanded: true,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      style: Theme.of(context).textTheme.labelSmall,
                      items: [
                        DropdownMenuItem(
                          value: 'MONTHLY',
                          child: Text('MONTHLY'),
                        ),
                        DropdownMenuItem(value: 'DAILY', child: Text('DAILY')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            viewMode = val;
                            currentDayIndex = DateTime.now().day;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (viewMode == 'MONTHLY') ...[
                // Monthly Bar Chart
                SizedBox(
                  height: 220,
                  child: Stack(
                    children: [
                      BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.center,
                          maxY: (monthlyData.reduce(max) * 1.2).clamp(10, 1000),
                          barTouchData: BarTouchData(
                            enabled: true,
                            touchTooltipData: BarTouchTooltipData(
                              //! tooltipBgColor: Colors.transparent,
                              getTooltipItem:
                                  (group, groupIndex, rod, rodIndex) => null,
                            ),
                            touchCallback: (event, response) {
                              if (response != null &&
                                  response.spot != null &&
                                  event.isInterestedForInteractions &&
                                  (event is FlTapUpEvent ||
                                      event is FlTapDownEvent)) {
                                setState(() {
                                  final tapped =
                                      response.spot!.touchedBarGroupIndex;
                                  touchedIndex = tapped;
                                });
                                fetchCategoryUsage();
                              }
                            },
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (
                                  double value,
                                  TitleMeta meta,
                                ) {
                                  final idx = value.toInt();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      months[idx],
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(fontSize: 8),
                                    ),
                                  );
                                },
                                reservedSize: 28,
                              ),
                            ),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(12, (i) {
                            final isTouched = i == touchedIndex;
                            final barValue =
                                monthlyData[i] == 0 ? 0.1 : monthlyData[i];
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: barValue,
                                  color:
                                      isTouched
                                          ? Colors.orange
                                          : Theme.of(
                                            context,
                                          ).colorScheme.tertiary,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(6),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: (monthlyData.reduce(max) * 1.2).clamp(
                                      10,
                                      1000,
                                    ),
                                    color:
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.grey[200]
                                            : Color(0xFF2F3545),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                      Positioned(
                        left:
                            (touchedIndex *
                                MediaQuery.of(context).size.width *
                                0.055), // Adjust for bar position
                        top: 10,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(30),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.flash_on,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  Text(
                                    '${monthlyData[touchedIndex].toStringAsFixed(2)} KWh',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Year selector
                Row(
                  children: [
                    Text(
                      'YEAR:',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: AppDecorations.cardDecoration(context),
                      width: 100,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<int>(
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                        value: selectedYear,
                        underline: const SizedBox(),
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        style: Theme.of(context).textTheme.labelMedium,
                        items:
                            (availableYears.toList()..sort())
                                .map(
                                  (year) => DropdownMenuItem(
                                    value: year,
                                    child: Text('$year'),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedYear = val;
                            });
                            fetchMonthlyUsage();
                            fetchCategoryUsage();
                            fetchAvailableYearsAndMonths();
                            fetchDailyData();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text(
                  'DETAILS ENERGY USAGE',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(letterSpacing: 1.1),
                ),
                const SizedBox(height: 16),
                // Pie Chart with total in center
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 250,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 80,
                            startDegreeOffset: -90,
                            sections:
                                totalForMonth > 0
                                    ? [
                                      PieChartSectionData(
                                        color: Colors.amber,
                                        value: categoryUsage['lighting'] ?? 0,
                                        title: '',
                                        radius: 28,
                                        showTitle: false,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.redAccent,
                                        value: categoryUsage['hvac'] ?? 0,
                                        title: '',
                                        radius: 28,
                                        showTitle: false,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.deepPurpleAccent,
                                        value: categoryUsage['device'] ?? 0,
                                        title: '',
                                        radius: 28,
                                        showTitle: false,
                                      ),
                                      PieChartSectionData(
                                        color: Colors.blueAccent,
                                        value: categoryUsage['network'] ?? 0,
                                        title: '',
                                        radius: 28,
                                        showTitle: false,
                                      ),
                                    ]
                                    : [
                                      PieChartSectionData(
                                        color:
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? Colors.grey[200]!
                                                : Color(0xFF2F3545),
                                        value: 100,
                                        title: '',
                                        radius: 28,
                                        showTitle: false,
                                      ),
                                    ],
                          ),
                        ),
                      ),
                      // Center total
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            totalForMonth.toStringAsFixed(2),
                            style: const TextStyle(
                              fontFamily: 'Nura',
                              fontWeight: FontWeight.w800,
                              fontSize: 32,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Text(
                            'KWH',
                            style: TextStyle(
                              fontFamily: 'Nura',
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Month and Year
                Center(
                  child: Text(
                    '${monthsFull[(touchedIndex)].toUpperCase()} $selectedYear',
                    style: const TextStyle(
                      fontFamily: 'Nura',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (isCategoryLoading) ...[
                  Center(child: CircularProgressIndicator()),
                ] else ...[
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.3,
                    children:
                        categoryMeta.keys.map((cat) {
                          final meta = categoryMeta[cat]!;
                          final value = categoryUsage[cat] ?? 0.0;
                          return energyDetailBox(
                            context,
                            meta['color'],
                            meta['icon'],
                            {'name': meta['label']},
                            value,
                          );
                        }).toList(),
                  ),
                ],
              ] else ...[
                //  Daily Bar Chart
                Column(
                  children: [
                    CarouselSlider.builder(
                      options: CarouselOptions(
                        initialPage: currentDayIndex,
                        height: 400,
                        viewportFraction: 0.23,
                        enlargeCenterPage: false,
                        enableInfiniteScroll: false,
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentDayIndex = index;
                          });
                          fetchDailyCategoryUsage();
                        },
                      ),
                      itemCount: dailyData.length,
                      itemBuilder: (context, index, realIdx) {
                        final isSelected = index == currentDayIndex;
                        final double maxDaily =
                            dailyData.isNotEmpty ? dailyData.reduce(max) : 1;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (isSelected)
                              Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: AppDecorations.cardDecoration(
                                  context,
                                ).copyWith(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Wrap(
                                  children: [
                                    const Center(
                                      child: Icon(
                                        Icons.flash_on,
                                        color: Colors.amber,
                                        size: 19,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        dailyData[index].toStringAsFixed(2),
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.labelSmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 10),
                            AnimatedContainer(
                              constraints: BoxConstraints(maxHeight: 290),
                              margin: EdgeInsets.symmetric(horizontal: 25),
                              duration: Duration(milliseconds: 300),
                              height:
                                  maxDaily > 0
                                      ? (290 * dailyData[index]) / maxDaily
                                      : 0,
                              width: 40,
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.orange
                                        : Theme.of(
                                          context,
                                        ).colorScheme.tertiary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(child: Text("${index + 1}")),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Month selector
                LayoutBuilder(
                  builder: (context, constraints) {
                    //final isSmallScreen =  constraints.maxWidth < 400;
                    return Wrap(
                      spacing: 20,
                      runSpacing: 12,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      direction: Axis.horizontal,
                      children: [
                        // YEAR Picker
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'YEAR :',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: AppDecorations.cardDecoration(
                                context,
                              ),
                              width: 100,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: DropdownButton<int>(
                                dropdownColor:
                                    Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                                value: selectedYearForMonth,
                                underline: const SizedBox(),
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                style: Theme.of(context).textTheme.labelSmall,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      selectedYearForMonth = val;
                                      final monthsForYear =
                                          yearToMonths[selectedYearForMonth] ??
                                          {};
                                      if (!monthsForYear.contains(
                                            selectedMonth,
                                          ) &&
                                          monthsForYear.isNotEmpty) {
                                        selectedMonth = monthsForYear.first;
                                      }
                                    });
                                    fetchDailyData();
                                    fetchDailyCategoryUsage();
                                  }
                                },
                                items:
                                    (availableYears.toList()..sort())
                                        .map(
                                          (year) => DropdownMenuItem(
                                            value: year,
                                            child: Text(year.toString()),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                          ],
                        ),

                        // MONTH Picker
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'MONTH :',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: AppDecorations.cardDecoration(
                                context,
                              ),
                              width: 120,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: DropdownButton<int>(
                                dropdownColor:
                                    Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                                value: selectedMonth,
                                underline: const SizedBox(),
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                style: Theme.of(context).textTheme.labelSmall,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      selectedMonth = val;
                                    });
                                    fetchDailyData();
                                    fetchDailyCategoryUsage();
                                  }
                                },
                                items:
                                    monthsList
                                        .map(
                                          (m) => DropdownMenuItem(
                                            value: m,
                                            child: Text(monthsFull[m]),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),
                // DETAILS ENERGY USAGE for daily
                Text(
                  'DETAILS ENERGY USAGE',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(letterSpacing: 1.1),
                ),
                const SizedBox(height: 20),
                // Pie Chart with total in center for selected day
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 70,
                            startDegreeOffset: -90,
                            sections: [
                              PieChartSectionData(
                                color: Colors.amber,
                                value: dailyCategoryUsage['lighting'] ?? 0,
                                title: '',
                                radius: 28,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: Colors.redAccent,
                                value: dailyCategoryUsage['hvac'] ?? 0,
                                title: '',
                                radius: 28,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: Colors.deepPurpleAccent,
                                value: dailyCategoryUsage['device'] ?? 0,
                                title: '',
                                radius: 28,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: Colors.blueAccent,
                                value: dailyCategoryUsage['network'] ?? 0,
                                title: '',
                                radius: 28,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Center total for selected day
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dailyData[currentDayIndex].toStringAsFixed(2),
                            style: const TextStyle(
                              fontFamily: 'Nura',
                              fontWeight: FontWeight.w900,
                              fontSize: 32,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Text(
                            'KWH',
                            style: TextStyle(
                              fontFamily: 'Nura',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Date label
                Center(
                  child: Text(
                    '${(currentDayIndex) + 1} ${monthsFull[selectedMonth].toUpperCase()} $selectedYearForMonth',
                    style: const TextStyle(
                      fontFamily: 'Nura',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Category Cards for daily
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.3,
                  children:
                      categoryMeta.keys.map((cat) {
                        final meta = categoryMeta[cat]!;
                        final value = dailyCategoryUsage[cat] ?? 0.0;
                        return energyDetailBox(
                          context,
                          meta['color'],
                          meta['icon'],
                          {'name': meta['label']},
                          value,
                        );
                      }).toList(),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Container energyDetailBox(
    BuildContext context,
    Color color,
    IconData icon,
    Map<String, dynamic> cat,
    double value,
  ) {
    return Container(
      decoration: AppDecorations.cardDecoration(context),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: MediaQuery.of(context).size.width * 0.07,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      cat['name'].toString().toUpperCase(),
                      style: const TextStyle(
                        fontFamily: 'Nura',
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${value.toStringAsFixed(2)} KWH',
                  style: const TextStyle(
                    fontFamily: 'Nura',
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
