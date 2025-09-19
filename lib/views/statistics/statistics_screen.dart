import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/mood/mood_bloc.dart';
import '../../controllers/habit/habit_bloc.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'week';
  final List<String> _periods = ['week', 'month', 'year'];

  @override
  void initState() {
    super.initState();
    context.read<MoodBloc>().add(const LoadMoodEntries());
    context.read<HabitBloc>().add(LoadHabits());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => _periods.map((period) {
              return PopupMenuItem(
                value: period,
                child: Text(period.toUpperCase()),
              );
            }).toList(),
          ),
        ],
      ),
      body: BlocBuilder<MoodBloc, MoodState>(
        builder: (context, moodState) {
          return BlocBuilder<HabitBloc, HabitState>(
            builder: (context, habitState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 24),
                    _buildMoodChart(moodState),
                    const SizedBox(height: 24),
                    _buildHabitChart(habitState),
                    const SizedBox(height: 24),
                    _buildInsightsCard(moodState, habitState),
                    const SizedBox(height: 24),
                    _buildMoodDistribution(moodState),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: _periods.map((period) {
            final isSelected = period == _selectedPeriod;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    period.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMoodChart(MoodState moodState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: moodState is MoodLoaded
                  ? _buildMoodLineChart(moodState.moodEntries)
                  : const Center(
                      child: Text('No mood data available'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodLineChart(List<dynamic> moodEntries) {
    if (moodEntries.isEmpty) {
      return const Center(
        child: Text('No mood data available'),
      );
    }

    // Sort entries by date
    moodEntries.sort((a, b) => a.date.compareTo(b.date));

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < moodEntries.length) {
                  final date = moodEntries[value.toInt()].date;
                  return Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: moodEntries.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.moodValue.toDouble());
            }).toList(),
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitChart(HabitState habitState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Habit Completion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: habitState is HabitLoaded
                  ? _buildHabitBarChart(habitState.habits)
                  : const Center(
                      child: Text('No habit data available'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitBarChart(List<dynamic> habits) {
    if (habits.isEmpty) {
      return const Center(
        child: Text('No habit data available'),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < habits.length) {
                  return Text(
                    habits[value.toInt()].name,
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: habits.asMap().entries.map((entry) {
          // Mock completion rate - in real app, calculate from actual data
          final completionRate = (entry.key + 1) * 20.0;
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: completionRate,
                color: Theme.of(context).primaryColor,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightsCard(MoodState moodState, HabitState habitState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildInsightItem(
              icon: Icons.trending_up,
              title: 'Mood Trend',
              description: 'Your mood has been improving over the last week',
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              icon: Icons.check_circle,
              title: 'Habit Consistency',
              description: 'You\'re doing great with your exercise routine',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildInsightItem(
              icon: Icons.lightbulb,
              title: 'Correlation Found',
              description: 'Better sleep correlates with improved mood',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodDistribution(MoodState moodState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mood Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (moodState is MoodLoaded)
              _buildMoodDistributionChart(moodState.moodEntries)
            else
              const Center(
                child: Text('No mood data available'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodDistributionChart(List<dynamic> moodEntries) {
    if (moodEntries.isEmpty) {
      return const Center(
        child: Text('No mood data available'),
      );
    }

    // Count mood values
    final moodCounts = <int, int>{};
    for (int i = 1; i <= 5; i++) {
      moodCounts[i] = 0;
    }

    for (final entry in moodEntries) {
      moodCounts[entry.moodValue] = (moodCounts[entry.moodValue] ?? 0) + 1;
    }

    final total = moodEntries.length;
    final moodLabels = ['😢', '😕', '😐', '😊', '😄'];

    return Column(
      children: moodCounts.entries.map((entry) {
        final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                moodLabels[entry.key - 1],
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getMoodColor(entry.key),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getMoodColor(int moodValue) {
    switch (moodValue) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
