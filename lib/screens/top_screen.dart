import 'package:flutter/material.dart';

class TopScreen extends StatefulWidget {
  const TopScreen({super.key});

  @override
  _TopScreenState createState() => _TopScreenState();
}

class _TopScreenState extends State<TopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  final List<String> labels = ["Tuần", "Tháng", "Năm"];

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: labels.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Top địa điểm"),
        bottom: TabBar(
          controller: _controller,
          tabs: labels.map((e) => Tab(text: e)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [
          Center(child: Text("Top tuần")),
          Center(child: Text("Top tháng")),
          Center(child: Text("Top năm")),
        ],
      ),
    );
  }
}
