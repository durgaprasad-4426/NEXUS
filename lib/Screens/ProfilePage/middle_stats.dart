import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MiddleStats extends StatelessWidget {
  final String userId;
  const MiddleStats({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection("users").doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};

        // Parse stats safely
        final statsRaw = userData['stats'] as Map<String, dynamic>? ?? {};
        final statsMap = <String, int>{};
        statsRaw.forEach((key, value) {
          statsMap[key] = value is int ? value : int.tryParse(value.toString()) ?? 0;
        });

        final data = statsMap.entries.map((e) => ProgressData(e.key, e.value)).toList();

        if (data.isEmpty) {
          return const Center(
            child: Text(
              "No learning stats available yet",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Learning Statistics",
              style: TextStyle(
                color: Colors.amber,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _buildChart(data),
            ),
          ],
        );
      },
    );
  }

  // Extracted chart for clean code
  SfCartesianChart _buildChart(List<ProgressData> data) {
    return SfCartesianChart(
      backgroundColor: Colors.transparent,
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(color: Colors.white),
        axisLine: const AxisLine(color: Colors.white70),
      ),
      primaryYAxis: NumericAxis(
        labelStyle: const TextStyle(color: Colors.white),
        axisLine: const AxisLine(color: Colors.white70),
        majorGridLines: const MajorGridLines(color: Colors.white24),
      ),
      tooltipBehavior: TooltipBehavior(enable: true, color: Colors.amber),
      series: <CartesianSeries<ProgressData, String>>[
        ColumnSeries<ProgressData, String>(
          dataSource: data,
          xValueMapper: (ProgressData stats, _) => stats.topic,
          yValueMapper: (ProgressData stats, _) => stats.progress,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          gradient: const LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.pinkAccent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          animationDuration: 800,
        ),
      ],
    );
  }
}

class ProgressData {
  final String topic;
  final int progress;
  ProgressData(this.topic, this.progress);
}
