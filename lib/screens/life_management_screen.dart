import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game_feel.dart';
import '../goals.dart';
import '../live_scene.dart';
import '../tutorial.dart';
import '../world_events.dart';
import '../life_management.dart';

/// لوحة إدارة الحياة: أساس المحاكاة الإدارية، لا بطاقة حدث.
/// ثمانية تبويبات تعرض الموارد الحقيقية، وزر واحد "تقدم شهرا"
/// ينفذ الشهر ويعرض تقريره، وتبويب المشاريع يبدأ مشروعا واحدا
/// نشطا بثمن مقدّم ويعرض تقدمه حتى اكتماله.
/// الحفظ على الجهاز من اللوحة نفسها: كل شهر يتقدم يُحفظ
/// تلقائيا، وزر "حفظ الإدارة" يحفظ يدويا، وعند فتح اللوحة من
/// جديد تُستأنف الإدارة المحفوظة إن وُجدت، لا تبدأ من الصفر.
class LifeManagementScreen extends StatefulWidget {
  const LifeManagementScreen({super.key});

  @override
  State<LifeManagementScreen> createState() => _LifeManagementScreenState();
}

class _LifeManagementScreenState extends State<LifeManagementScreen>
    with SingleTickerProviderStateMixin {
  static const _saveKey = 'life_management_v1';

  LifeManagementState _state = LifeManagementState();
  MonthReport? _lastReport;
  String? _saveStatus;
  bool _soundOn = true;
  int _streakMonths = 0;
  int _tutorialStep = 0;
  bool _eventSceneDismissed = false;
  String? _eventNote;

  void _advanceMonth() {
    setState(() {
      _lastReport = _state.advanceMonth();
      _streakMonths =
          (_state.cash < 0 || _state.health < 30) ? 0 : _streakMonths + 1;
      _finishTutorialStep(
          nextTutorialStep(_tutorialStep, TutorialEvent.advanced));
      _eventSceneDismissed = false;
      _eventNote = null;
    });
    // كل شهر يتقدم يُحفظ تلقائيا، فلا تضيع الإدارة
    // إن أُغلقت اللعبة دون حفظ يدوي.
    _save();
    GameFeel.playAction(soundOn: _soundOn);
  }
  late final TabController _tabs;

  static const _tabLabels = [
    'نظرة عامة',
    'وقت',
    'مال',
    'صحة',
    'مهارة',
    'علاقات',
    'مشاريع',
    'أهداف الحياة',
    'أهداف',
  ];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _tabLabels.length, vsync: this);
    _loadSaved();
    _loadTutorialDone();
  }

  /// يقرأ علامة انتهاء التعليم المحفوظة؛ تعليم منتهٍ لا يعود.
  Future<void> _loadTutorialDone() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('life_tutorial_done_v1') == true && mounted) {
      setState(() => _tutorialStep = 3);
    }
  }

  Future<void> _persistTutorialDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('life_tutorial_done_v1', true);
  }

  void _finishTutorialStep(int next) {
    _tutorialStep = next;
    if (next >= 3) _persistTutorialDone();
  }

  /// يستأنف الإدارة المحفوظة على الجهاز إن وُجدت. أي حفظ تالف
  /// يُتجاهل بهدوء وتبدأ إدارة جديدة، فلا يكسر حفظ قديم اللعب.
  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_saveKey);
    if (raw == null) return;
    try {
      final restored =
          LifeManagementState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (!mounted) return;
      setState(() {
        _state = restored;
        _saveStatus =
            'تم استئناف إدارة محفوظة — الشهر ${restored.months}، النقد ${restored.cash}.';
      });
    } catch (_) {
      // حفظ تالف: يُتجاهل وتبدأ إدارة جديدة.
    }
  }

  /// يحفظ حالة الإدارة الحالية على الجهاز ويعرض تأكيدا.
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_saveKey, jsonEncode(_state.toJson()));
    if (!mounted) return;
    setState(() {
      _saveStatus = 'تم حفظ الإدارة (الشهر ${_state.months}).';
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  /// شريط التعليم التفاعلي: يظهر فوق المشهد الحي في تبويب
  /// نظرة عامة حتى ينتهي، وزراه في الخطوة 2 ينفذان إجراءين
  /// إداريين حقيقيين (تفعيل الرياضة أو بدء مشروع)، لا خيارين
  /// سرديين، مع زر تخطٍ في كل خطوة فلا يعلق اللاعب أبدا.
  Widget _tutorialBanner() {
    if (_tutorialStep >= 3) return const SizedBox.shrink();
    final s = _state;
    final affordableProjects = LifeManagementState.projectCatalog
        .where((p) =>
            s.activeProjectId == null &&
            !s.completedProjectIds.contains(p.id) &&
            s.cash >= p.cost)
        .toList();
    return Card(
      key: const Key('tutorial-banner'),
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.amber, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(tutorialStepTitle(_tutorialStep),
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(tutorialStepHint(_tutorialStep)),
            if (_tutorialStep == 1) ...[
              const SizedBox(height: 8),
              if (!s.gym)
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      s.gym = true;
                      _finishTutorialStep(nextTutorialStep(
                          _tutorialStep, TutorialEvent.managementAction));
                    });
                  },
                  child: const Text('فعّل الرياضة هذا الشهر'),
                ),
              if (affordableProjects.isNotEmpty)
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      s.startProject(affordableProjects.first.id);
                      _finishTutorialStep(nextTutorialStep(
                          _tutorialStep, TutorialEvent.managementAction));
                    });
                  },
                  child: Text(
                      'ابدأ مشروعا (${affordableProjects.first.name} — ${affordableProjects.first.cost})'),
                ),
              if (s.gym && affordableProjects.isEmpty)
                const Text(
                    'الرياضة مفعّلة ولا مشروع بمقدور نقدك الآن — اضغط «تخطي هذه الخطوة» ثم تقدم شهرا لتجمع دخلا.'),
              TextButton(
                onPressed: () {
                  setState(() {
                    _finishTutorialStep(nextTutorialStep(
                        _tutorialStep, TutorialEvent.managementAction));
                  });
                },
                child: const Text('تخطي هذه الخطوة'),
              ),
            ],
            TextButton(
              onPressed: () {
                setState(() {
                  _finishTutorialStep(nextTutorialStep(
                      _tutorialStep, TutorialEvent.skipped));
                });
              },
              child: const Text('تخطي التعليم'),
            ),
          ],
        ),
      ),
    );
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
        actions: [
          IconButton(
            icon: Icon(_soundOn ? Icons.volume_up : Icons.volume_off),
            tooltip: _soundOn ? 'كتم الصوت' : 'تشغيل الصوت',
            onPressed: () => setState(() => _soundOn = !_soundOn),
          ),
        ],
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
                        AnimatedCountText(
                          prefix: 'النقد: ',
                          value: s.cash,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedCountText(
                          prefix: 'الادخار: ',
                          value: s.savings,
                        ),
                        AnimatedCountText(
                          prefix: 'الصحة: ',
                          value: s.health,
                          suffix: ' / 100',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedCountText(
                          prefix: 'المهارة: ',
                          value: s.skill,
                          suffix: ' / 100',
                        ),
                        AnimatedCountText(
                          prefix: 'العلاقات: ',
                          value: s.relationships,
                          suffix: ' / 100',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedBar(label: 'الصحة', fraction: s.health / 100),
                    AnimatedBar(label: 'المهارة', fraction: s.skill / 100),
                    AnimatedBar(
                      label: 'العلاقات',
                      fraction: s.relationships / 100,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: _tutorialStep == 0 || _tutorialStep == 2
                          ? BoxDecoration(
                              border: Border.all(
                                  color: Colors.amber, width: 3),
                              borderRadius: BorderRadius.circular(12),
                            )
                          : null,
                      child: FilledButton(
                        onPressed: _advanceMonth,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('تقدم شهرا ⏭️'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: _save,
                      child: const Text('حفظ الإدارة'),
                    ),
                    if (_saveStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _saveStatus!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.green),
                        ),
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
                  _tutorialBanner(),
                  const SizedBox(height: 8),
                  if (_lastReport != null && !_eventSceneDismissed)
                    MonthEventScene(
                      healthDelta: _lastReport!.healthDelta,
                      skillDelta: _lastReport!.skillDelta,
                      relationshipsDelta: _lastReport!.relationshipsDelta,
                      cashDelta: _lastReport!.cashDelta,
                      streakMonths: _streakMonths,
                      gymOn: s.gym,
                      socialOn: s.social,
                      onFocusHealth: () {
                        setState(() {
                          s.gym = true;
                          s.setRecovery(true);
                          _eventSceneDismissed = true;
                          _eventNote =
                              'قررت: التركيز على الصحة — الرياضة والتعافي مفعّلان للشهر التالي.';
                        });
                      },
                      onFocusRelationships: () {
                        setState(() {
                          s.social = true;
                          _eventSceneDismissed = true;
                          _eventNote =
                              'قررت: التركيز على العلاقات — اللقاء الاجتماعي مفعّل للشهر التالي.';
                        });
                      },
                      onKeepPlan: () {
                        setState(() {
                          _eventSceneDismissed = true;
                          _eventNote =
                              'قررت: واصل خطتك كما هي دون تغيير.';
                        });
                      },
                    ),
                  if (_lastReport != null && !_eventSceneDismissed)
                    const SizedBox(height: 8),
                  if (_eventNote != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(_eventNote!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                    ),
                  LifeLiveScene(
                    health: s.health,
                    skill: s.skill,
                    relationships: s.relationships,
                    cash: s.cash,
                    savings: s.savings,
                    ageYears: s.ageYears,
                    months: s.months,
                  ),
                  const SizedBox(height: 8),
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
                  Card(
                    child: SwitchListTile(
                      title: const Text('إجازة تعافٍ هذا الشهر'),
                      subtitle: const Text(
                          'دخل -400، لكن الصحة +6 والعلاقات +2 في الشهر نفسه. التعافي يُشترى بمال مفقود، ولا يجتمع مع العمل الإضافي أبدا.'),
                      value: s.recovery,
                      onChanged: (v) => setState(() => s.setRecovery(v)),
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
                  const SizedBox(height: 8),
                  Card(
                    child: SwitchListTile(
                      title: const Text('عضوية نادٍ رياضي هذا الشهر'),
                      subtitle: const Text(
                          'دخل -250 كل شهر، لكن الصحة +4 في الشهر نفسه. صحة تُشترى بمال متكرر، وهي أرخص من إجازة التعافي لكنها لا تريح علاقاتك.'),
                      value: s.gym,
                      onChanged: (v) => setState(() => s.gym = v),
                    ),
                  ),
                ]),
                _panel([
                  const Text('المهارة',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('المهارة الآن', '${s.skill} / 100'),
                  const Text(
                      'الدراسة والتعلم يرفعان المهارة، والمهارة الأعلى ترفع أجرك الشهري فعلا (كل نقطة مهارة = +3 دخل). ترك التعلم تماما يُنقص المهارة نقطة شهريا.'),
                  const SizedBox(height: 8),
                  Card(
                    child: SwitchListTile(
                      title: const Text('دورة مهنية هذا الشهر'),
                      subtitle: const Text(
                          'دخل -350 كل شهر، لكن المهارة +2 في الشهر نفسه، والصحة -1 من الجهد الدراسي الإضافي. تسريع مهارة يُشترى بمال وجهد، لا مجانا أبدا.'),
                      value: s.course,
                      onChanged: (v) => setState(() => s.course = v),
                    ),
                  ),
                ]),
                _panel([
                  const Text('العلاقات',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  _row('العلاقات الآن', '${s.relationships} / 100'),
                  const Text(
                      'وقت العلاقات فوق 15 يحسّن علاقاتك، وتحته يضعفها. العلاقات هنا مورد إداري لا حدثا عابرا.'),
                  const SizedBox(height: 8),
                  Card(
                    child: SwitchListTile(
                      title: const Text('لقاء اجتماعي هذا الشهر'),
                      subtitle: const Text(
                          'دخل -300 كل شهر، لكن العلاقات +5 في الشهر نفسه، والصحة -1 من السهر والإرهاق. تواصل يُشترى بمال وصحة قليلة، لا مجانا أبدا.'),
                      value: s.social,
                      onChanged: (v) => setState(() => s.social = v),
                    ),
                  ),
                  Card(
                    child: SwitchListTile(
                      title: const Text('تطوع مجتمعي هذا الشهر'),
                      subtitle: const Text(
                          'دخل -200 كل شهر، لكن العلاقات +4 في الشهر نفسه، والصحة +1 من النشاط والمعنى. أرخص من اللقاء وأبطأ علاقات منه، لكنه لا يرهقك بل ينشطك.'),
                      value: s.volunteer,
                      onChanged: (v) => setState(() => s.volunteer = v),
                    ),
                  ),
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
                  const Text('الأهداف والمكافآت',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  GoalsPanel(
                    months: s.months,
                    health: s.health,
                    skill: s.skill,
                    relationships: s.relationships,
                    cash: s.cash,
                    savings: s.savings,
                    completedProjectCount: s.completedProjectIds.length,
                    streakMonths: _streakMonths,
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
