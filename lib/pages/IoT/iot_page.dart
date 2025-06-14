import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class IotPage extends StatefulWidget {
  const IotPage({super.key});

  @override
  State<IotPage> createState() => _IotPageState();
}

class _IotPageState extends State<IotPage> {
  // Hardcoded data
  final double totalEnergy = 75.41;
  final List<double> monthlyData = [
    7.2,
    5.1,
    8.3,
    6.0,
    9.2,
    4.8,
    8.0,
    5.5,
    10.1,
    21.09,
    6.7,
    7.4,
  ];
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
  final List<int> years = [2023, 2024, 2025];
  int selectedYear = 2025;
  int? touchedIndex;

  // For daily view
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
  int selectedMonth = 4; // May (0-based)
  int selectedYearForMonth = 2025;
  int? touchedDayIndex;
  List<double> dailyData = List.generate(
    31,
    (i) => 2.0 + (i % 7) * 0.7,
  ); // Demo data

  String viewMode = 'MONTHLY'; // 'MONTHLY' or 'DAILY'

  // Category data for each month (example for October 2025)
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Lighting',
      'icon': Icons.lightbulb_outline,
      'color': Colors.amber,
      'monthly': [5.0, 4.2, 5.5, 5.1, 6.0, 4.8, 5.7, 4.9, 6.2, 6.04, 5.3, 5.6],
    },
    {
      'name': 'HVAC',
      'icon': Icons.ac_unit,
      'color': Colors.redAccent,
      'monthly': [7.0, 6.1, 8.0, 7.2, 8.5, 6.0, 7.8, 6.5, 9.0, 10.05, 7.1, 7.3],
    },
    {
      'name': 'Equipment',
      'icon': Icons.print,
      'color': Colors.deepPurpleAccent,
      'monthly': [2.5, 2.0, 2.8, 2.6, 3.0, 2.2, 2.9, 2.7, 3.1, 3.00, 2.8, 2.9],
    },
    {
      'name': 'Network',
      'icon': Icons.dns,
      'color': Colors.blueAccent,
      'monthly': [1.5, 1.2, 2.0, 1.8, 2.1, 1.5, 2.0, 1.7, 2.3, 2.00, 1.9, 2.0],
    },
  ];

  // Daily category data for each day (demo data for 31 days)
  final List<Map<String, dynamic>> dailyCategories = [
    {
      'name': 'Lighting',
      'icon': Icons.lightbulb_outline,
      'color': Colors.amber,
      'daily': List.generate(31, (i) => 0.7 + (i % 7) * 0.15),
    },
    {
      'name': 'HVAC',
      'icon': Icons.ac_unit,
      'color': Colors.redAccent,
      'daily': List.generate(31, (i) => 1.2 + (i % 5) * 0.25),
    },
    {
      'name': 'Equipment',
      'icon': Icons.print,
      'color': Colors.deepPurpleAccent,
      'daily': List.generate(31, (i) => 0.4 + (i % 4) * 0.1),
    },
    {
      'name': 'Network',
      'icon': Icons.dns,
      'color': Colors.blueAccent,
      'daily': List.generate(31, (i) => 0.3 + (i % 3) * 0.08),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'IOT MANAGEMENT',
                  style: TextStyle(
                    fontFamily: 'Nura',
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // ENERGY GENERATED + dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ENERGY GENERATED',
                        style: TextStyle(
                          fontFamily: 'Nura',
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 1.1,
                          color: Colors.black54,
                        ),
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
                          Text(
                            '$totalEnergy KWH',
                            style: const TextStyle(
                              fontFamily: 'Nura',
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    width: 140,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    child: DropdownButton<String>(
                      value: viewMode,
                      underline: const SizedBox(),
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'MONTHLY',
                          child: Text(
                            'MONTHLY',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'DAILY',
                          child: Text(
                            'DAILY',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            viewMode = val;
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
                          maxY: 24,
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
                                  if (touchedIndex == tapped) {
                                    touchedIndex = null;
                                  } else {
                                    touchedIndex = tapped;
                                  }
                                });
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
                                      style: const TextStyle(
                                        fontFamily: 'Nura',
                                        fontWeight: FontWeight.w700,
                                        fontSize: 9,
                                        color: Colors.black54,
                                      ),
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
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: monthlyData[i],
                                  color:
                                      isTouched ? Colors.orange : Colors.black,
                                  width: 18,
                                  borderRadius: BorderRadius.circular(6),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: 24,
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                      if (touchedIndex != null)
                        Positioned(
                          left:
                              16.0 +
                              (touchedIndex! * 22.5), // Adjust for bar position
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
                                child: Text(
                                  '⚡ ${monthlyData[touchedIndex!].toStringAsFixed(2)} KWH',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
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
                    const Text(
                      'YEAR:',
                      style: TextStyle(
                        fontFamily: 'Nura',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      width: 100,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      child: DropdownButton<int>(
                        value: selectedYear,
                        underline: const SizedBox(),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        items:
                            years
                                .map(
                                  (year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(
                                      '$year',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedYear = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // DETAILS ENERGY USAGE Title
                const SizedBox(height: 12),
                const Text(
                  'DETAILS ENERGY USAGE',
                  style: TextStyle(
                    fontFamily: 'Nura',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                // Pie Chart with total in center
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 60,
                            startDegreeOffset: -90,
                            sections: List.generate(categories.length, (i) {
                              final cat = categories[i];
                              final selectedMonthIndex =
                                  touchedIndex ?? (DateTime.now().month - 1);
                              final value = cat['monthly'][selectedMonthIndex];
                              final color = cat['color'] as Color;
                              return PieChartSectionData(
                                color: color,
                                value: value,
                                title: '',
                                radius: 28,
                                showTitle: false,
                              );
                            }),
                          ),
                        ),
                      ),
                      // Center total
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            categories
                                .fold<double>(0, (sum, cat) {
                                  final selectedMonthIndex =
                                      touchedIndex ??
                                      (DateTime.now().month - 1);
                                  return sum +
                                      (cat['monthly'][selectedMonthIndex]
                                          as double);
                                })
                                .toStringAsFixed(2),
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
                // Month and Year
                Center(
                  child: Text(
                    '${monthsFull[(touchedIndex ?? (DateTime.now().month - 1))].toUpperCase()} $selectedYear',
                    style: const TextStyle(
                      fontFamily: 'Nura',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Category Cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.3,
                  children: List.generate(categories.length, (i) {
                    final cat = categories[i];
                    final color = cat['color'] as Color;
                    final icon = cat['icon'] as IconData;
                    final selectedMonthIndex =
                        touchedIndex ?? (DateTime.now().month - 1);
                    final value = cat['monthly'][selectedMonthIndex] as double;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 32),
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
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$value KWH',
                                  style: const TextStyle(
                                    fontFamily: 'Nura',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
              ] else ...[
                // Daily Bar Chart
                SizedBox(
                  height: 220,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(dailyData.length, (i) {
                        final isTouched = i == touchedDayIndex;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (touchedDayIndex == i) {
                                touchedDayIndex = null;
                              } else {
                                touchedDayIndex = i;
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (isTouched)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 6),
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
                                    child: Text(
                                      '⚡ ${dailyData[i].toStringAsFixed(2)} KWH',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 16,
                                  height: 30 + dailyData[i] * 5,
                                  decoration: BoxDecoration(
                                    color:
                                        isTouched
                                            ? Colors.orange
                                            : Colors.black,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${i + 1}',
                                  style: const TextStyle(
                                    fontFamily: 'Nura',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Month selector
                Row(
                  children: [
                    const Text(
                      'MONTH:',
                      style: TextStyle(
                        fontFamily: 'Nura',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      width: 160,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      child: DropdownButton<int>(
                        value: selectedMonth,
                        underline: const SizedBox(),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        items: List.generate(
                          monthsFull.length,
                          (i) => DropdownMenuItem(
                            value: i,
                            child: Text(
                              '${monthsFull[i]} $selectedYearForMonth',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedMonth = val;
                              // Optionally update dailyData for the new month
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // DETAILS ENERGY USAGE for daily
                const Text(
                  'DETAILS ENERGY USAGE',
                  style: TextStyle(
                    fontFamily: 'Nura',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                // Pie Chart with total in center for selected day
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 60,
                            startDegreeOffset: -90,
                            sections: List.generate(dailyCategories.length, (
                              i,
                            ) {
                              final cat = dailyCategories[i];
                              final value =
                                  cat['daily'][(touchedDayIndex ?? 0)];
                              final color = cat['color'] as Color;
                              return PieChartSectionData(
                                color: color,
                                value: value,
                                title: '',
                                radius: 28,
                                showTitle: false,
                              );
                            }),
                          ),
                        ),
                      ),
                      // Center total for selected day
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            dailyCategories
                                .fold<double>(
                                  0,
                                  (sum, cat) =>
                                      sum +
                                      (cat['daily'][(touchedDayIndex ?? 0)]
                                          as double),
                                )
                                .toStringAsFixed(2),
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
                    '${monthsFull[selectedMonth].toUpperCase()} ${(touchedDayIndex ?? 0) + 1}, $selectedYearForMonth',
                    style: const TextStyle(
                      fontFamily: 'Nura',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Category Cards for daily
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.3,
                  children: List.generate(dailyCategories.length, (i) {
                    final cat = dailyCategories[i];
                    final color = cat['color'] as Color;
                    final icon = cat['icon'] as IconData;
                    final value =
                        cat['daily'][(touchedDayIndex ?? 0)] as double;
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 32),
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
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$value KWH',
                                  style: const TextStyle(
                                    fontFamily: 'Nura',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
