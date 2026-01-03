import 'package:flutter/material.dart';

class LeftBar extends StatelessWidget {
  const LeftBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.grey.shade100,
      child: ListView(
        children: const [
          _Section(
            title: '系統管理',
            items: [
              _Item('使用者管理'),
              _Item('系統設定'),
            ],
          ),
          _Section(
            title: '出勤系統',
            items: [
              _Item('打卡紀錄'),
              _Item('統計報表'),
            ],
          ),
          _Section(
            title: '財務系統',
            items: [
              _Item('請款申請'),
              _Item('簽核流程'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<_Item> items;

  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: items,
    );
  }
}

class _Item extends StatelessWidget {
  final String title;
  const _Item(this.title);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () {
        // TODO: Navigator push
      },
    );
  }
}
