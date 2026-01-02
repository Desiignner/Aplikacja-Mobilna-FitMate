import 'package:fitmate/api/models/models.dart';
import 'package:fitmate/services/app_data_service.dart';
import 'package:fitmate/utils/app_colors.dart';
import 'package:fitmate/widgets/app_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BodyMeasurementsScreen extends StatefulWidget {
  const BodyMeasurementsScreen({super.key});

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> {
  final AppDataService _appData = AppDataService();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _bodyFatController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _bicepsController = TextEditingController();
  final _thighsController = TextEditingController();

  // Target Weight
  final _targetWeightController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _appData.loadBodyMeasurements();

    // Pre-fill target weight if exists
    final target = _appData.targetWeight.value;
    if (target != null) {
      _targetWeightController.text = target.toString();
    }

    // Pre-fill metrics form if defaults exist
    final metrics = _appData.userMetrics.value;
    if (metrics['weight'] != null) {
      _weightController.text = metrics['weight']!.replaceAll(' kg', '');
    }
    if (metrics['height'] != null) {
      _heightController.text = metrics['height']!.replaceAll(' cm', '');
    }
    if (metrics['bodyFat'] != null && metrics['bodyFat'] != '-') {
      _bodyFatController.text = metrics['bodyFat']!.replaceAll('%', '');
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveNewMeasurement() async {
    final w = double.tryParse(_weightController.text);
    final h = int.tryParse(_heightController.text);
    if (w == null || h == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid weight and height')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final dto = CreateBodyMeasurementDto(
        weightKg: w,
        heightCm: h,
        bodyFatPercentage: double.tryParse(_bodyFatController.text),
        chestCm: int.tryParse(_chestController.text),
        waistCm: int.tryParse(_waistController.text),
        hipsCm: int.tryParse(_hipsController.text),
        bicepsCm: int.tryParse(_bicepsController.text),
        thighsCm: int.tryParse(_thighsController.text),
      );
      await _appData.saveMeasurement(dto);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Measurement saved')),
        );
      }
      _weightController.clear();
      // _heightController.clear(); // Keep height
      _bodyFatController.clear();
      _chestController.clear();
      _waistController.clear();
      _hipsController.clear();
      _bicepsController.clear();
      _thighsController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveTargetWeight() async {
    final t = double.tryParse(_targetWeightController.text);
    if (t != null) {
      await _appData.saveTargetWeight(t);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Target updated')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainBackgroundColor,
      appBar: AppBar(
        title: const Text('Your Profile'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                'Body Metrics',
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: primaryColor),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading && _appData.bodyMeasurements.value.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildSummaryRow(),
                  const SizedBox(height: 24),
                  _buildChartsRow(),
                  const SizedBox(height: 24),
                  _buildBottomRow(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow() {
    return ValueListenableBuilder<List<BodyMeasurementDto>>(
      valueListenable: _appData.bodyMeasurements,
      builder: (context, measurements, _) {
        String currentWeight = '-';
        String bmi = '-';
        String inGo = '-'; // Weight change?

        if (measurements.isNotEmpty) {
          final latest = measurements.first; // sorted desc
          currentWeight = '${latest.weightKg} kg';
          bmi = latest.bmi.toStringAsFixed(1);

          if (measurements.length > 1) {
            final prev = measurements[1];
            final diff = latest.weightKg - prev.weightKg;
            inGo = '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg';
          }
        }

        return Row(
          children: [
            Expanded(child: _buildMetricCard('Current Weight', currentWeight)),
            const SizedBox(width: 12),
            Expanded(
                child: ValueListenableBuilder<double?>(
              valueListenable: _appData.targetWeight,
              builder: (context, val, _) => _buildMetricCard(
                  'Target Weight', val != null ? '$val kg' : '-'),
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _buildMetricCard('Change', inGo,
                    color: inGo.startsWith('+')
                        ? Colors.redAccent
                        : primaryColor)),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard('BMI', bmi, color: primaryColor)),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(String title, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: secondaryTextColor, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color ?? Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChartsRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Stack on mobile, Row on tablet/desktop (assuming mobile execution -> Stack)
        return Column(
          children: [
            _buildWeightChart(),
            const SizedBox(height: 16),
            _buildMeasurementsChart(), // Placeholder for multi-line chart
          ],
        );
      },
    );
  }

  Widget _buildWeightChart() {
    return AppCard(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Weight Progress',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<BodyMeasurementDto>>(
                valueListenable: _appData.bodyMeasurements,
                builder: (context, measurements, _) {
                  if (measurements.isEmpty) {
                    return const Center(
                        child: Text('No data',
                            style: TextStyle(color: secondaryTextColor)));
                  }

                  // Sort by date asc for chart
                  final sorted = List<BodyMeasurementDto>.from(measurements)
                    ..sort(
                        (a, b) => a.measuredAtUtc.compareTo(b.measuredAtUtc));

                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) =>
                              const FlLine(color: Colors.white10)),
                      titlesData: const FlTitlesData(show: false), // Simplified
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: sorted
                              .asMap()
                              .entries
                              .map((e) =>
                                  FlSpot(e.key.toDouble(), e.value.weightKg))
                              .toList(), // Use weightKg from BodyMeasurementDto
                          isCurved: true,
                          color: primaryColor,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                              show: true,
                              color: primaryColor.withValues(alpha: 0.1)),
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

  Widget _buildMeasurementsChart() {
    return AppCard(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Body Measurements',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // Legend
            Wrap(spacing: 8, children: [
              _legendItem('Chest', Colors.blue),
              _legendItem('Waist', Colors.purple),
              _legendItem('Hips', Colors.pink),
            ]),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<BodyMeasurementDto>>(
                valueListenable: _appData.bodyMeasurements,
                builder: (context, list, _) {
                  if (list.isEmpty) {
                    return const Center(
                        child: Text('No data',
                            style: TextStyle(color: secondaryTextColor)));
                  }
                  // Sort asc
                  final sorted = List<BodyMeasurementDto>.from(list)
                    ..sort(
                        (a, b) => a.measuredAtUtc.compareTo(b.measuredAtUtc));

                  return LineChart(
                    LineChartData(
                      gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) =>
                              const FlLine(color: Colors.white10)),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        if (sorted.any((m) => m.chestCm != null))
                          _line(sorted, (m) => m.chestCm?.toDouble(),
                              Colors.blue),
                        if (sorted.any((m) => m.waistCm != null))
                          _line(sorted, (m) => m.waistCm?.toDouble(),
                              Colors.purple),
                        if (sorted.any((m) => m.hipsCm != null))
                          _line(
                              sorted, (m) => m.hipsCm?.toDouble(), Colors.pink),
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

  LineChartBarData _line(List<BodyMeasurementDto> data,
      double? Function(BodyMeasurementDto) selector, Color color) {
    return LineChartBarData(
      spots: data
          .asMap()
          .entries
          .where((e) => selector(e.value) != null)
          .map((e) => FlSpot(e.key.toDouble(), selector(e.value)!))
          .toList(),
      isCurved: true,
      color: color,
      dotData: const FlDotData(show: true),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, color: color, size: 8),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(color: secondaryTextColor, fontSize: 10)),
      ],
    );
  }

  Widget _buildBottomRow() {
    return Column(
      children: [
        // Left Column inputs ( Settings + New)
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settings',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _targetWeightController,
                decoration: const InputDecoration(
                  labelText: 'Target Weight (kg)',
                  filled: true,
                  fillColor: mainBackgroundColor,
                  labelStyle: TextStyle(color: secondaryTextColor),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTargetWeight,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child:
                      const Text('Save', style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('New Measurement',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          filled: true,
                          fillColor: mainBackgroundColor,
                          labelStyle: TextStyle(color: secondaryTextColor)),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          filled: true,
                          fillColor: mainBackgroundColor,
                          labelStyle: TextStyle(color: secondaryTextColor)),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _bodyFatController,
                      decoration: const InputDecoration(
                          labelText: 'Body Fat (%)',
                          filled: true,
                          fillColor: mainBackgroundColor,
                          labelStyle: TextStyle(color: secondaryTextColor)),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _chestController,
                      decoration: const InputDecoration(
                          labelText: 'Chest (cm)',
                          filled: true,
                          fillColor: mainBackgroundColor,
                          labelStyle: TextStyle(color: secondaryTextColor)),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _waistController,
                      decoration: const InputDecoration(
                          labelText: 'Waist (cm)',
                          filled: true,
                          fillColor: mainBackgroundColor,
                          labelStyle: TextStyle(color: secondaryTextColor)),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _hipsController,
                      decoration: const InputDecoration(
                          labelText: 'Hips (cm)',
                          filled: true,
                          fillColor: mainBackgroundColor,
                          labelStyle: TextStyle(color: secondaryTextColor)),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _bicepsController,
                      decoration: const InputDecoration(
                          labelText: 'Biceps (cm)',
                          filled: true,
                          fillColor: mainBackgroundColor,
                          labelStyle: TextStyle(color: secondaryTextColor)),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _thighsController,
                      decoration: const InputDecoration(
                          labelText: 'Thighs (cm)',
                          filled: true,
                          fillColor: mainBackgroundColor,
                          labelStyle: TextStyle(color: secondaryTextColor)),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveNewMeasurement,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  child: const Text('Save Measurement',
                      style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // History Table
        _buildHistoryTable(),
      ],
    );
  }

  Widget _buildHistoryTable() {
    return ValueListenableBuilder<List<BodyMeasurementDto>>(
      valueListenable: _appData.bodyMeasurements,
      builder: (context, data, _) {
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('History',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingTextStyle:
                      const TextStyle(color: secondaryTextColor, fontSize: 12),
                  dataTextStyle: const TextStyle(color: Colors.white),
                  columns: const [
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Weight')),
                    DataColumn(label: Text('BMI')),
                    DataColumn(label: Text('Fat %')),
                    DataColumn(label: Text('Chest')),
                    DataColumn(label: Text('Waist')),
                    DataColumn(label: Text('Hips')),
                    DataColumn(label: Text('Biceps')),
                    DataColumn(label: Text('Thighs')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: data.map((m) {
                    return DataRow(cells: [
                      DataCell(Text(DateFormat('dd.MM.yyyy')
                          .format(m.measuredAtUtc.toLocal()))),
                      DataCell(Text('${m.weightKg}')),
                      DataCell(Text(m.bmi.toString())),
                      DataCell(Text(m.bodyFatPercentage?.toString() ?? '-')),
                      DataCell(Text(m.chestCm?.toString() ?? '-')),
                      DataCell(Text(m.waistCm?.toString() ?? '-')),
                      DataCell(Text(m.hipsCm?.toString() ?? '-')),
                      DataCell(Text(m.bicepsCm?.toString() ?? '-')),
                      DataCell(Text(m.thighsCm?.toString() ?? '-')),
                      DataCell(IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 20),
                        onPressed: () => _confirmDelete(m.id),
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBackgroundColor,
        title: const Text('Delete?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _appData.deleteMeasurement(id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}
