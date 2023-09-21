import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todolist/data.dart';
import 'package:todolist/edit.dart';

const taskBoxName = 'tasks';
void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(PriorityAdapter());
  await Hive.openBox<TaskEntity>(taskBoxName);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: primaryVariantColor),
  );
  runApp(const MyApp());
}

const Color primaryColor = Color(0xff794Cff);
const Color primaryVariantColor = Color(0xff5C0AFF);
final secondryTextColor = Color(0xffAFBED0);
const normalPriority = Color(0xffF09819);
const highPriority = primaryColor;
const lowPriority = Color(0xff3BE1F1);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final primeryTextColor = Color(0xff1D2830);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(const TextTheme(
            headline6: TextStyle(fontWeight: FontWeight.bold),
          )),
          inputDecorationTheme: InputDecorationTheme(
            floatingLabelBehavior: FloatingLabelBehavior.never,
            labelStyle: TextStyle(color: secondryTextColor),
            border: InputBorder.none,
            iconColor: secondryTextColor,
          ),
          colorScheme: ColorScheme.light(
            primary: primaryColor,
            onPrimary: Colors.white,
            primaryContainer: primaryVariantColor,
            background: Color(0xffF3F5F8),
            onSurface: primeryTextColor,
            onBackground: primeryTextColor,
            secondary: primaryColor,
            onSecondary: Colors.white,
          )),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final TextEditingController controller = TextEditingController();
  final ValueNotifier<String> searchKeywordNotifier = ValueNotifier('');
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<TaskEntity>(taskBoxName);
    final themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditTaskScreen(
                  task: TaskEntity(),
                ),
              ),
            );
          },
          label: const Row(
            children: [
              Text('Add New Task'),
              SizedBox(
                width: 4,
              ),
              Icon(CupertinoIcons.add),
            ],
          )),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                themeData.primaryColor,
                themeData.colorScheme.primaryContainer,
              ])),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'To Do List',
                          style: themeData.textTheme.headline6!
                              .apply(color: themeData.colorScheme.onPrimary),
                        ),
                        Icon(
                          CupertinoIcons.share,
                          color: themeData.colorScheme.onPrimary,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 38,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(19),
                        color: themeData.colorScheme.onPrimary,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) {
                          searchKeywordNotifier.value = controller.text;
                        },
                        controller: controller,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(CupertinoIcons.search),
                          label: Text('Search tasks...'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: searchKeywordNotifier,
                builder: (context, value, child) {
                  return ValueListenableBuilder<Box<TaskEntity>>(
                      valueListenable: box.listenable(),
                      builder: (context, box, child) {
                        final List<TaskEntity> items;
                        if (controller.text.isEmpty) {
                          items = box.values.toList();
                        } else {
                          items = box.values
                              .where(
                                  (task) => task.name.contains(controller.text))
                              .toList();
                        }
                        if (items.isNotEmpty) {
                          return ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 16, 16, 100),
                              itemCount: items.length + 1,
                              itemBuilder: (condex, index) {
                                if (index == 0) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Today',
                                            style: themeData
                                                .textTheme.headline6!
                                                .apply(fontSizeFactor: 0.9),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 4),
                                            width: 70,
                                            height: 3,
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(1.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                      MaterialButton(
                                        textColor: secondryTextColor,
                                        elevation: 0,
                                        color: const Color(0xffEAEFF5),
                                        onPressed: () {
                                          box.clear();
                                        },
                                        child: const Row(
                                          children: [
                                            Text('Delet All'),
                                            SizedBox(
                                              width: 4,
                                            ),
                                            Icon(
                                              CupertinoIcons.delete_solid,
                                              size: 18,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  final TaskEntity task = items[index - 1];
                                  return TaskIteme(task: task);
                                }
                              });
                        } else {
                          return const Emptystate();
                        }
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Emptystate extends StatelessWidget {
  const Emptystate({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/empty_state.svg',
          width: 120,
        ),
        const SizedBox(
          height: 12,
        ),
        const Text('Your Task Is Empty'),
      ],
    );
  }
}

class TaskIteme extends StatefulWidget {
  static const double height = 74;
  const TaskIteme({
    super.key,
    required this.task,
  });

  final TaskEntity task;

  @override
  State<TaskIteme> createState() => _TaskItemeState();
}

class _TaskItemeState extends State<TaskIteme> {
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    final Color priorityColor;
    switch (widget.task.priority) {
      case Priority.low:
        priorityColor = lowPriority;
        break;
      case Priority.normal:
        priorityColor = normalPriority;
        break;
      case Priority.high:
        priorityColor = highPriority;
        break;
    }
    return InkWell(
      onLongPress: () {
        widget.task.delete();
      },
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditTaskScreen(task: widget.task)));
      },
      child: Container(
        alignment: Alignment.centerLeft,
        height: TaskIteme.height,
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.only(left: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: themeData.colorScheme.surface,
        ),
        child: Row(
          children: [
            MyCheckBox(
              value: widget.task.isCompleted,
              onTap: () {
                setState(() {
                  widget.task.isCompleted = !widget.task.isCompleted;
                });
              },
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Text(
                widget.task.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : null),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Container(
              width: 5,
              height: TaskIteme.height,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyCheckBox extends StatelessWidget {
  final bool value;
  final GestureTapCallback onTap;
  const MyCheckBox({super.key, required this.value, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: !value
              ? Border.all(
                  color: secondryTextColor,
                  width: 2,
                )
              : null,
          color: value ? primaryColor : null,
        ),
        child: value
            ? Icon(
                CupertinoIcons.check_mark,
                size: 16,
                color: themeData.colorScheme.onPrimary,
              )
            : null,
      ),
    );
  }
}
