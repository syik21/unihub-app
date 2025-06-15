import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

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
  int touchedIndex = DateTime.now().month - 1;

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
  int todaydate = DateTime.now().day - 1;
  int currentDayIndex = DateTime.now().day - 1;

  List<double> dailyData = List.generate(
    31,
    (_) => double.parse((Random().nextDouble() * 10).toStringAsFixed(2)),
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
      'name': 'Device',
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
      'daily': List.generate(
        31,
        (i) => double.parse((0.7 + (i % 7) * 0.15).toStringAsFixed(2)),
      ),
    },
    {
      'name': 'HVAC',
      'icon': Icons.ac_unit,
      'color': Colors.redAccent,
      'daily': List.generate(
        31,
        (i) => double.parse((1.2 + (i % 5) * 0.25).toStringAsFixed(2)),
      ),
    },
    {
      'name': 'Device',
      'icon': Icons.print,
      'color': Colors.deepPurpleAccent,
      'daily': List.generate(
        31,
        (i) => double.parse((0.4 + (i % 4) * 0.1).toStringAsFixed(2)),
      ),
    },
    {
      'name': 'Network',
      'icon': Icons.dns,
      'color': Colors.blueAccent,
      'daily': List.generate(
        31,
        (i) => double.parse((0.3 + (i % 3) * 0.08).toStringAsFixed(2)),
      ),
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                          Text(
                            '$totalEnergy KWH',
                            style: Theme.of(context).textTheme.headlineMedium,
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
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.tertiary),
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
                                  touchedIndex = tapped;
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
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: monthlyData[i],
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
                                    toY: 24,
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
                                    '${categories.fold<double>(0, (sum, cat) {
                                      final selectedMonthIndex = touchedIndex;
                                      return sum + (cat['monthly'][selectedMonthIndex] as double);
                                    }).toStringAsFixed(2)} KWh',
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
                      style: Theme.of(context).textTheme.labelLarge,
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
                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: Theme.of(context).colorScheme.tertiary,),
                        style: Theme.of(context).textTheme.labelSmall,
                        items:
                            years
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
                        width: 180,
                        height: 180,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 60,
                            startDegreeOffset: -90,
                            sections: List.generate(categories.length, (i) {
                              final cat = categories[i];
                              final selectedMonthIndex = touchedIndex;
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
                                  final selectedMonthIndex = touchedIndex;
                                  return sum +
                                      (cat['monthly'][selectedMonthIndex]
                                          as double);
                                })
                                .toStringAsFixed(2),
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
                    final selectedMonthIndex = touchedIndex;
                    final value = cat['monthly'][selectedMonthIndex] as double;
                    return energyDetailBox(context, color, icon, cat, value);
                  }),
                ),
                const SizedBox(height: 24),
              ] else ...[
                //  Daily Bar Chart
                Column(
                  children: [
                    CarouselSlider.builder(
                      options: CarouselOptions(
                        initialPage: todaydate,
                        height: 400,
                        viewportFraction: 0.23,
                        enlargeCenterPage: false,
                        enableInfiniteScroll: false,
                        scrollDirection: Axis.horizontal,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentDayIndex = index;
                          });
                        },
                      ),
                      itemCount: dailyData.length,
                      itemBuilder: (context, index, realIdx) {
                        final isSelected = index == currentDayIndex;
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
                                        size: 20,
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        '${dailyData[index]} KWH',
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
                              height: (290 * dailyData[index]) / 10,
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
                Row(
                  children: [
                    Text(
                      'MONTH :',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        decoration: AppDecorations.cardDecoration(context),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 2,
                        ),
                        child: DropdownButton<int>(
                          dropdownColor: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                          value: selectedMonth,
                          underline: const SizedBox(),
                          isExpanded: true,
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          style: Theme.of(context).textTheme.labelSmall,
                          items: List.generate(
                            monthsFull.length,
                            (i) => DropdownMenuItem(
                              value: i,
                              child: Text(
                                '${monthsFull[i]} $selectedYearForMonth',
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
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // DETAILS ENERGY USAGE for daily
                Text(
                  'DETAILS ENERGY USAGE',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(letterSpacing: 1.1),
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
                              final value = cat['daily'][(currentDayIndex)];
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
                            '${dailyData[currentDayIndex]}',
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
                  children: List.generate(dailyCategories.length, (i) {
                    final cat = dailyCategories[i];
                    final color = cat['color'] as Color;
                    final icon = cat['icon'] as IconData;
                    final value = cat['daily'][(currentDayIndex)] as double;
                    return energyDetailBox(context, color, icon, cat, value);
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
                  '$value KWH',
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
