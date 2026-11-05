import 'package:flutter/material.dart';

void main() => runApp(const TareeqiApp());

const navy = Color(0xFF103B70);
const blue = Color(0xFF1769C2);
const turquoise = Color(0xFF16A6A1);
const yellow = Color(0xFFFFC928);
const ink = Color(0xFF172B45);
const pale = Color(0xFFF3F7FC);

class TareeqiApp extends StatelessWidget {
  const TareeqiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'طريقي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: pale,
        colorScheme: ColorScheme.fromSeed(seedColor: blue, primary: blue),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: HomeShell(),
      ),
    );
  }
}

enum PostKind { truck, cargo }

class TransportPost {
  TransportPost({
    required this.kind, required this.owner, required this.from,
    required this.to, required this.vehicle, required this.capacity,
    required this.price, required this.note, required this.time,
  });
  final PostKind kind;
  final String owner, from, to, vehicle, capacity, price, note, time;
}

final demoPosts = <TransportPost>[
  TransportPost(kind: PostKind.truck, owner: 'شركة الشام للنقل', from: 'دمشق',
    to: 'حلب', vehicle: 'شاحنة قلاب', capacity: '25 طن', price: '450 دولار',
    note: 'متاحة للتحميل اليوم، تواصل للتفاصيل.', time: 'منذ 15 دقيقة'),
  TransportPost(kind: PostKind.cargo, owner: 'مؤسسة النور التجارية', from: 'حمص',
    to: 'اللاذقية', vehicle: 'براد مطلوب', capacity: '18 طن مواد غذائية',
    price: 'السعر قابل للتفاوض', note: 'نبحث عن سيارة مبردة مع التزام بموعد التسليم.',
    time: 'منذ 40 دقيقة'),
  TransportPost(kind: PostKind.truck, owner: 'أبو أحمد', from: 'حلب',
    to: 'دمشق', vehicle: 'فان مغلق', capacity: '2 طن', price: 'حسب الاتفاق',
    note: 'أبحث عن حمولة للعودة إلى دمشق.', time: 'منذ ساعة'),
];

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;
  String filter = 'الكل';
  final posts = List<TransportPost>.from(demoPosts);

  void addPost(TransportPost post) {
    setState(() { posts.insert(0, post); tab = 0; filter = 'الكل'; });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      FeedPage(posts: posts, filter: filter,
        onFilter: (v) => setState(() => filter = v),
        onChat: () => setState(() => tab = 2)),
      const GroupsPage(),
      const ChatsPage(),
      const ProfilePage(),
    ];
    return Scaffold(
      appBar: _bar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.local_shipping_rounded, color: yellow),
          const SizedBox(width: 8),
          const Text('طريقي', style: TextStyle(fontWeight: FontWeight.w900)),
        ]),
        actions: [
          IconButton(onPressed: () => _message(context, 'الإشعارات',
            'لا توجد إشعارات جديدة حالياً.'), icon: const Icon(Icons.notifications_none)),
          IconButton(onPressed: () => _message(context, 'البحث',
            'استخدم شريط البحث في صفحة المنشورات للعثور على الشاحنات والحمولات.'),
            icon: const Icon(Icons.search)),
        ],
      ),
      body: IndexedStack(index: tab, children: pages),
      floatingActionButton: tab == 0 ? FloatingActionButton.extended(
        backgroundColor: yellow, foregroundColor: ink,
        onPressed: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => Directionality(textDirection: TextDirection.rtl,
            child: NewPostPage(onSubmit: addPost)))),
        icon: const Icon(Icons.add), label: const Text('إضافة إعلان',
          style: TextStyle(fontWeight: FontWeight.bold)),
      ) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dynamic_feed_outlined),
            selectedIcon: Icon(Icons.dynamic_feed), label: 'المنشورات'),
          NavigationDestination(icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups), label: 'المجموعات'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble), label: 'المحادثات'),
          NavigationDestination(icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

class FeedPage extends StatefulWidget {
  const FeedPage({super.key, required this.posts, required this.filter,
    required this.onFilter, required this.onChat});
  final List<TransportPost> posts;
  final String filter;
  final ValueChanged<String> onFilter;
  final VoidCallback onChat;
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final search = TextEditingController();
  @override
  void dispose() { search.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final visible = widget.posts.where((p) {
      final matchesFilter = widget.filter == 'الكل' ||
        (widget.filter == 'شاحنات' && p.kind == PostKind.truck) ||
        (widget.filter == 'طلبات نقل' && p.kind == PostKind.cargo);
      final q = search.text.trim();
      final matchesSearch = q.isEmpty ||
        '${p.owner} ${p.from} ${p.to} ${p.vehicle} ${p.note}'.contains(q);
      return matchesFilter && matchesSearch;
    }).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [navy, blue]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('شبكة النقل والشحن السورية', style: TextStyle(
              color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('اعثر على حمولة أو سيارة نقل في مكان واحد',
              style: TextStyle(color: Colors.white70)),
            SizedBox(height: 14),
            Row(children: [
              _HeroChip(icon: Icons.verified_user, text: 'حسابات مهنية'),
              SizedBox(width: 8),
              _HeroChip(icon: Icons.route, text: 'كل المحافظات'),
            ]),
          ]),
        ),
        const SizedBox(height: 16),
        TextField(controller: search, onChanged: (_) => setState(() {}),
          decoration: _deco(
            hint: 'ابحث عن محافظة أو شاحنة أو حمولة...',
            prefix: const Icon(Icons.search))),
        const SizedBox(height: 14),
        Row(children: ['الكل', 'شاحنات', 'طلبات نقل'].map((v) =>
          Padding(padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(label: Text(v), selected: widget.filter == v,
              onSelected: (_) => widget.onFilter(v)))).toList()),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('أحدث المنشورات', style: TextStyle(
            color: ink, fontSize: 18, fontWeight: FontWeight.bold)),
          Text('${visible.length} إعلان', style: const TextStyle(color: Colors.grey)),
        ]),
        const SizedBox(height: 8),
        if (visible.isEmpty)
          const _EmptyState(icon: Icons.search_off, title: 'لا توجد نتائج',
            subtitle: 'جرّب تغيير كلمات البحث أو نوع الإعلان.')
        else
          ...visible.map((p) => PostCard(post: p, onChat: widget.onChat)),
      ]);
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.text});
  final IconData icon; final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(color: Colors.white.withAlpha(36),
      borderRadius: BorderRadius.circular(30)),
    child: Row(children: [Icon(icon, color: yellow, size: 16),
      const SizedBox(width: 5), Text(text, style: const TextStyle(
        color: Colors.white, fontSize: 11))]));
}

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, required this.onChat});
  final TransportPost post; final VoidCallback onChat;
  @override
  Widget build(BuildContext context) {
    final truck = post.kind == PostKind.truck;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white, elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(padding: const EdgeInsets.all(15), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(backgroundColor: truck ? blue.withAlpha(26) : turquoise.withAlpha(31),
              child: Icon(truck ? Icons.local_shipping : Icons.inventory_2,
                color: truck ? blue : turquoise)),
            const SizedBox(width: 9),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post.owner, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(post.time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: truck ? const Color(0xFFE8F1FF) : const Color(0xFFE4F7F4),
                borderRadius: BorderRadius.circular(20)),
              child: Text(truck ? 'شاحنة متاحة' : 'طلب نقل',
                style: TextStyle(color: truck ? blue : turquoise,
                  fontSize: 11, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _RoutePoint(label: 'من', city: post.from)),
            const Icon(Icons.arrow_back, color: turquoise),
            Expanded(child: _RoutePoint(label: 'إلى', city: post.to)),
          ]),
          const Divider(height: 22),
          Wrap(spacing: 14, runSpacing: 8, children: [
            _Info(icon: Icons.local_shipping_outlined, text: post.vehicle),
            _Info(icon: Icons.scale_outlined, text: post.capacity),
          ]),
          const SizedBox(height: 10),
          Text(post.note, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.payments_outlined, color: turquoise, size: 19),
            const SizedBox(width: 5),
            Expanded(child: Text(post.price, style: const TextStyle(
              color: navy, fontWeight: FontWeight.w900, fontSize: 16))),
            FilledButton.icon(onPressed: onChat,
              icon: const Icon(Icons.chat_bubble_outline, size: 17),
              label: const Text('تواصل')),
          ]),
        ])));
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({required this.label, required this.city});
  final String label, city;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start,
    children: [Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      Text(city, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]);
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});
  final IconData icon; final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min,
    children: [Icon(icon, color: Colors.grey, size: 17), const SizedBox(width: 5),
      Text(text, style: const TextStyle(fontSize: 12, color: ink))]);
}

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});
  static const groups = [
    ('دمشق – حلب', '12,500 عضو', Icons.route),
    ('حمص – طرطوس', '8,200 عضو', Icons.local_shipping),
    ('شاحنات البراد والتبريد', '5,700 عضو', Icons.ac_unit),
    ('نقل مواد البناء', '6,100 عضو', Icons.construction),
    ('أصحاب البيك أب والفانات', '3,400 عضو', Icons.airport_shuttle),
    ('نقل البضائع الغذائية', '4,800 عضو', Icons.restaurant),
  ];
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16),
    children: [
      const Text('مجموعات النقل', style: TextStyle(fontSize: 21,
        fontWeight: FontWeight.bold, color: ink)),
      const SizedBox(height: 5),
      const Text('تواصل مع العاملين في نفس خط النقل أو مجال عملك.',
        style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 14),
      ...groups.map((g) => Card(color: Colors.white, child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFFEAF2FC),
          child: Icon(g.$3, color: blue)),
        title: Text(g.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(g.$2),
        trailing: FilledButton.tonal(onPressed: () => _message(context, g.$1,
          'هذه مجموعة تجريبية. ربط المجموعات بالخادم سيأتي في مرحلة backend.'),
          child: const Text('عرض')),
      ))),
    ]);
}

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16),
    children: [
      const Text('المحادثات', style: TextStyle(fontSize: 21,
        fontWeight: FontWeight.bold, color: ink)),
      const SizedBox(height: 12),
      ...[
        ('شركة الشام للنقل', 'هل الشاحنة متاحة غداً؟', Icons.business),
        ('أبو أحمد – سائق', 'السعر قابل للتفاوض', Icons.person),
        ('مؤسسة النور التجارية', 'تم استلام تفاصيل الطلب', Icons.warehouse),
      ].map((c) => Card(color: Colors.white, child: ListTile(
        leading: CircleAvatar(backgroundColor: const Color(0xFFEAF2FC),
          child: Icon(c.$3, color: blue)),
        title: Text(c.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(c.$2),
        trailing: const Text('10:30', style: TextStyle(color: Colors.grey, fontSize: 11)),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => Directionality(textDirection: TextDirection.rtl,
            child: ChatDetailPage(name: c.$1)))),
      ))),
      const Padding(padding: EdgeInsets.only(top: 12),
        child: Text('المحادثات المعروضة بيانات تجريبية وليست رسائل حقيقية.',
          style: TextStyle(color: Colors.grey, fontSize: 12))),
    ]);
}

class ChatDetailPage extends StatefulWidget {
  const ChatDetailPage({super.key, required this.name});
  final String name;
  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}
class _ChatDetailPageState extends State<ChatDetailPage> {
  final controller = TextEditingController();
  final messages = <String>['السلام عليكم، هل الشاحنة متاحة؟',
    'وعليكم السلام، نعم متاحة غداً.'];
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _bar(title: Text(widget.name)),
    body: Column(children: [
      Expanded(child: ListView(padding: const EdgeInsets.all(16),
        children: messages.asMap().entries.map((e) => Align(
          alignment: e.key.isEven ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: e.key.isEven ? const Color(0xFFE3F2FD) : Colors.white,
              borderRadius: BorderRadius.circular(14)),
            child: Text(e.value)))).toList())),
      SafeArea(child: Padding(padding: const EdgeInsets.all(10),
        child: Row(children: [
          Expanded(child: TextField(controller: controller,
            decoration: _deco(hint: 'اكتب رسالة...'))),
          IconButton(onPressed: () {
            if (controller.text.trim().isEmpty) return;
            setState(() { messages.add(controller.text.trim()); controller.clear(); });
          }, icon: const Icon(Icons.send, color: blue)),
        ]))),
    ]),
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16),
    children: [
      Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(20)),
        child: const Column(children: [
          CircleAvatar(radius: 34, backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 38, color: blue)),
          SizedBox(height: 10),
          Text('مستخدم طريقي', style: TextStyle(color: Colors.white,
            fontWeight: FontWeight.bold, fontSize: 18)),
          Text('حساب تجريبي • سوريا', style: TextStyle(color: Colors.white70)),
        ])),
      const SizedBox(height: 14),
      ...[
        (Icons.badge_outlined, 'نوع الحساب', 'سائق / صاحب شاحنة / تاجر / شركة'),
        (Icons.location_on_outlined, 'المحافظة', 'اختر محافظتك'),
        (Icons.local_shipping_outlined, 'مركباتي', 'إضافة وإدارة المركبات'),
        (Icons.verified_user_outlined, 'توثيق الحساب', 'إضافة وثائق التحقق'),
        (Icons.workspace_premium_outlined, 'الاشتراك', 'الباقة المجانية'),
        (Icons.settings_outlined, 'الإعدادات', 'اللغة والخصوصية'),
      ].map((item) => Card(color: Colors.white, child: ListTile(
        leading: Icon(item.$1, color: blue), title: Text(item.$2),
        subtitle: Text(item.$3), trailing: const Icon(Icons.chevron_left),
        onTap: () => _message(context, item.$2,
          'سيتم تفعيل هذه الوظيفة عند ربط الحسابات والخادم في المرحلة التالية.'),
      ))),
    ]);
}

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key, required this.onSubmit});
  final ValueChanged<TransportPost> onSubmit;
  @override
  State<NewPostPage> createState() => _NewPostPageState();
}
class _NewPostPageState extends State<NewPostPage> {
  final from = TextEditingController(), to = TextEditingController(),
    vehicle = TextEditingController(), capacity = TextEditingController(),
    price = TextEditingController(), note = TextEditingController();
  PostKind kind = PostKind.cargo;
  @override
  void dispose() {
    from.dispose(); to.dispose(); vehicle.dispose(); capacity.dispose();
    price.dispose(); note.dispose(); super.dispose();
  }
  Widget field(String label, TextEditingController c, {String? hint}) =>
    Padding(padding: const EdgeInsets.only(bottom: 11),
      child: TextField(controller: c, decoration: _deco(label: label, hint: hint)));
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _bar(title: const Text('إضافة إعلان جديد')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      SegmentedButton<PostKind>(
        segments: const [
          ButtonSegment(value: PostKind.cargo, label: Text('طلب حمولة'), icon: Icon(Icons.inventory_2)),
          ButtonSegment(value: PostKind.truck, label: Text('شاحنة متاحة'), icon: Icon(Icons.local_shipping)),
        ],
        selected: {kind}, onSelectionChanged: (v) => setState(() => kind = v.first)),
      const SizedBox(height: 16),
      field('من محافظة / مدينة', from, hint: 'مثلاً دمشق'),
      field('إلى محافظة / مدينة', to, hint: 'مثلاً حلب'),
      field('نوع المركبة أو البضاعة', vehicle),
      field('الحمولة أو الوزن', capacity),
      field('السعر المعروض', price, hint: 'مثلاً 450 دولار أو قابل للتفاوض'),
      field('تفاصيل إضافية', note),
      const SizedBox(height: 8),
      FilledButton.icon(
        onPressed: () {
          if ([from, to, vehicle].any((c) => c.text.trim().isEmpty)) {
            _message(context, 'بيانات ناقصة', 'يرجى إدخال مكان الانطلاق والوجهة ونوع المركبة أو البضاعة.');
            return;
          }
          widget.onSubmit(TransportPost(kind: kind, owner: 'مستخدم جديد',
            from: from.text.trim(), to: to.text.trim(), vehicle: vehicle.text.trim(),
            capacity: capacity.text.trim().isEmpty ? 'غير محدد' : capacity.text.trim(),
            price: price.text.trim().isEmpty ? 'قابل للتفاوض' : price.text.trim(),
            note: note.text.trim().isEmpty ? 'يرجى التواصل للتفاصيل.' : note.text.trim(),
            time: 'الآن'));
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تمت إضافة الإعلان محلياً في هذه النسخة التجريبية.')));
        },
        icon: const Icon(Icons.publish), label: const Text('نشر الإعلان'),
      ),
      const SizedBox(height: 10),
      const Text('ملاحظة: النشر في هذه النسخة تجريبي ومحلي على الجهاز فقط.',
        style: TextStyle(color: Colors.grey, fontSize: 12)),
    ]),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.subtitle});
  final IconData icon; final String title, subtitle;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(30),
    child: Column(children: [Icon(icon, size: 44, color: Colors.grey),
      const SizedBox(height: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey))]));
}

void _message(BuildContext context, String title, String body) {
  showDialog<void>(context: context, builder: (_) => AlertDialog(
    title: Text(title), content: Text(body),
    actions: [TextButton(onPressed: () => Navigator.pop(context),
      child: const Text('حسناً'))],
  ));
}

PreferredSizeWidget _bar({required Widget title, List<Widget>? actions}) => AppBar(
  title: title, actions: actions,
  backgroundColor: navy, foregroundColor: Colors.white,
  centerTitle: true, elevation: 0,
);

InputDecoration _deco({String? label, String? hint, Widget? prefix}) =>
  InputDecoration(
    labelText: label, hintText: hint, prefixIcon: prefix,
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
