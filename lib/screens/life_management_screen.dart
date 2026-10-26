import 'package:flutter/material.dart';

import '../life_management.dart';

/// لوحة إدارة الحياة: أساس المحاكاة الإدارية، لا بطاقة حدث.
/// ثمانية تبويبات تعرض الموارد الحقيقية، وزر واحد "تقدم شهرا"
/// ينفذ الشهر ويعرض تقريره، وتبويب المشاريع يبدأ مشروعا واحدا
/// نشطا بثمن مقدّم ويعرض تقدمه حتى اكتماله.
class LifeManagementScreen extends StatefulWidget {
  const LifeManagementScreen({super.key});

  @override
  State<LifeManagementScreen> createState() => _LifeManagementScreenState();
}

class _LifeManagementScreenState extends State<LifeManagementScreen>
    with SingleTickerProviderStateMixin {
  final LifeManagementState _state = LifeManagementState();
  MonthReport? _lastReport;
  late final TabController _tabs;

  static const _tabLabels = [
    'نظرة عامة',
    'وقت',
    'مال',
    'صحة',
    'مهارة',
    'علاقات',
    'مشاريع',
    'أهداف',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _tabLabels.length, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            Text(value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );

  Widget _panel(List<Widget> children) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );

  Widget _bucketRow(
    String label,
    int value,
    void Function(int) onChange,
  ) =>
      Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
              IconButton(
                onPressed: () => setState(() => onChange(value - 5)),
                icon: const Icon(Icons.remove),
                tooltip: 'إنقاص 5',
              ),
              Text('$value',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: () => setState(() => onChange(value + 5)),
                icon: const Icon(Icons.add),
                tooltip: 'زيادة 5',
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final s = _state;
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة إدارة الحياة'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: [for (final label in _tabLabels) Tab(text: label)],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('العمر ${s.ageYears} — الشهر ${s.months}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('النقد: ${s.cash}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الادخار: ${s.savings}'),
                        Text('الصحة: ${s.health} / 100'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('المهارة: ${s.skill} / 100'),
                        Text('العلاقات: ${s.relationships} / 100'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        setState(() {
                          _lastReport = s.advanceMonth();
                        });
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('تقدم شهرا ⏭️'),
                    ),
                    if (s.cash < 0)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'النقد سالب: أنت مدين، وفائدة 10% ستُضاف في الشهر التالي. راجع ميزانية المال قبل التقدم.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _panel([
                  const Text('نظرة عامة',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('الدخل الشهري المتوقع', '${s.monthlyIncome}'),
                  _row('المصروف الشهري المتوقع', '${s.monthlyExpenses}'),
                  if (s.cash < 0)
                    _row('فائدة الدين الشهرية المتوقعة (10%)',
                        '${(-s.cash) * 10 ~/ 100}'),
                  _row('الادخار الشهري المتوقع', '${s.monthlySavingsDeposit}'),
                  const SizedBox(height: 12),
                  const Text('تقرير الشهر الأخير:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  if (_lastReport == null)
                    const Text(
                        'لم يمر شهر بعد. اضغط "تقدم شهرا" لترى أول تقرير.')
                  else
                    for (final line in _lastReport!.lines)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Text('• $line'),
                      ),
                ]),
                _panel([
                  const Text('ميزانية الوقت — المجموع 100 دائما',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text(
                      'رفع بند يسحب من أكبر بند آخر، فكل ساعة لها ثمن في مكان آخر. العمل يرفع الدخل، والدراسة ترفع المهارة، والصحة والراحة يحميان صحتك.'),
                  const SizedBox(height: 8),
                  for (final key in LifeManagementState.timeBuckets)
                    _bucketRow(
                      LifeManagementState.timeLabels[key]!,
                      s.time[key]!,
                      (v) => s.setTimeBucket(key, v),
                    ),
                  const SizedBox(height: 8),
                  Card(
                    child: SwitchListTile(
                      title: const Text('عمل إضافي هذا الشهر'),
                      subtitle: const Text(
                          'دخل +500، لكن الصحة -5 والعلاقات -3 في الشهر نفسه. المال السريع له ثمن، فلا يصلح دائما.'),
                      value: s.overtime,
                      onChanged: (v) => setState(() => s.setOvertime(v)),
                    ),
                  ),
                ]),
                _panel([
                  const Text('ميزانية المال — المجموع 100 دائما',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text(
                      'السكن والطعام والترفيه مصروف شهري، والادخار يُخصم من نقدك إلى رصيد ادخار منفصل، والتعلم يرفع مهارتك مع الدراسة.'),
                  const SizedBox(height: 8),
                  for (final key in LifeManagementState.moneyBuckets)
                    _bucketRow(
                      LifeManagementState.moneyLabels[key]!,
                      s.money[key]!,
                      (v) => s.setMoneyBucket(key, v),
                    ),
                ]),
                _panel([
                  const Text('الصحة',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('الصحة الآن', '${s.health} / 100'),
                  const Text(
                      'الصحة تتحسن بمجموع وقت الصحة والراحة، وتتراجع إن قلّ عن 25. إهمالها لا يقتلك بخيار واحد، بل يتراكم شهرا بعد شهر.'),
                ]),
                _panel([
                  const Text('المهارة',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('المهارة الآن', '${s.skill} / 100'),
                  const Text(
                      'الدراسة والتعلم يرفعان المهارة، والمهارة الأعلى ترفع أجرك الشهري فعلا (كل نقطة مهارة = +3 دخل). ترك التعلم تماما يُنقص المهارة نقطة شهريا.'),
                ]),
                _panel([
                  const Text('العلاقات',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('العلاقات الآن', '${s.relationships} / 100'),
                  const Text(
                      'وقت العلاقات فوق 15 يحسّن علاقاتك، وتحته يضعفها. العلاقات هنا مورد إداري لا حدثا عابرا.'),
                ]),
                _panel([
                  const Text('مشاريع',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text(
                      'مشروع واحد نشط فقط: ثمنه يُدفع مقدما من نقدك، ويتقدم مع كل شهر، وأثره يُطبق مرة واحدة عند اكتماله ولا يُعاد بدؤه.'),
                  const SizedBox(height: 8),
                  for (final p in LifeManagementState.projectCatalog)
                    Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold)),
                            Text(p.description),
                            Text(
                                'المدة: ${p.durationMonths} أشهر — التكلفة: ${p.cost}'),
                            Text('عند الاكتمال: ${p.effect}'),
                            if (s.completedProjectIds.contains(p.id))
                              const Text('مكتمل ✓ — أثره مطبّق ولا يُعاد بدؤه')
                            else if (s.activeProjectId == p.id) ...[
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: s.activeProjectMonths /
                                    p.durationMonths,
                              ),
                              Text(
                                  'نشط الآن: شهر ${s.activeProjectMonths} من ${p.durationMonths}'),
                            ] else
                              FilledButton(
                                onPressed: s.activeProjectId != null ||
                                        s.cash < p.cost
                                    ? null
                                    : () => setState(
                                        () => s.startProject(p.id)),
                                child: Text(s.activeProjectId != null
                                    ? 'مشروع آخر نشط الآن'
                                    : s.cash < p.cost
                                        ? 'النقد لا يكفي لبدئه'
                                        : 'ابدأ المشروع (${p.cost})'),
                              ),
                          ],
                        ),
                      ),
                    ),
                ]),
                _panel([
                  const Text('أهداف',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text(
                      'أهداف قابلة للقياس من إدارتك نفسها، لا من خيار واحد.'),
                  const SizedBox(height: 8),
                  for (final g in s.goals)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('${g.name} — ${g.current} / ${g.target}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(value: g.progress),
                        ],
                      ),
                    ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
