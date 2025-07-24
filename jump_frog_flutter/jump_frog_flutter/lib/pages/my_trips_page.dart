import 'package:flutter/material.dart';
import 'trip_detail_page.dart';

class MyTripsPage extends StatefulWidget {
  const MyTripsPage({super.key});
  @override
  State<MyTripsPage> createState() => _MyTripsPageState();
}

class _MyTripsPageState extends State<MyTripsPage> {
  int _tabIndex = 0;
  final List<_TripCardData> _ongoingTrips = const [
    _TripCardData(
      route: '上海',
      destination: '日本',
      days: '3天2晚',
      status: '进行中',
      startDate: '2024-07-01',
    ),
    _TripCardData(
      route: '广州',
      destination: '泰国',
      days: '4天3晚',
      status: '进行中',
      startDate: '2024-07-10',
    ),
  ];
  final List<_TripCardData> _completedTrips = const [
    _TripCardData(
      route: '北京',
      destination: '韩国',
      days: '2天1晚',
      status: '已完成',
      startDate: '2024-06-10',
    ),
    _TripCardData(
      route: '上海',
      destination: '日本',
      days: '2天1晚',
      status: '已完成',
      startDate: '2024-05-20',
    ),
  ];

  void _openTripDetail(_TripCardData data) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TripDetailPage(
          route: data.route,
          destination: data.destination,
          days: data.days,
          startDate: data.startDate,
          status: data.status,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trips = _tabIndex == 0 ? _ongoingTrips : _completedTrips;
    return Scaffold(
      appBar: AppBar(title: const Text('我的行程')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TabBtn(
                label: '进行中',
                selected: _tabIndex == 0,
                onTap: () => setState(() => _tabIndex = 0),
              ),
              _TabBtn(
                label: '已完成',
                selected: _tabIndex == 1,
                onTap: () => setState(() => _tabIndex = 1),
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: trips.isEmpty
                ? const Center(child: Text('暂无行程'))
                : ListView.builder(
                    itemCount: trips.length,
                    itemBuilder: (context, i) => _TripCard(
                      data: trips[i],
                      onTap: () => _openTripDetail(trips[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? Colors.green : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.green : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _TripCardData {
  final String route;
  final String destination;
  final String days;
  final String status;
  final String startDate;
  const _TripCardData({
    required this.route,
    required this.destination,
    required this.days,
    required this.status,
    required this.startDate,
  });
}

class _TripCard extends StatelessWidget {
  final _TripCardData data;
  final VoidCallback? onTap;
  const _TripCard({required this.data, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const Icon(Icons.flight, color: Colors.green, size: 32),
        title: Text(
          '${data.route} → ${data.destination}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${data.days}  |  ${data.startDate}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: data.status == '进行中'
                ? Colors.green.shade100
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            data.status,
            style: TextStyle(
              color: data.status == '进行中' ? Colors.green : Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
