import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:GIOW/task.dart';
import 'package:GIOW/task_drawer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
  
class HomeScreen extends StatefulWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  const HomeScreen({super.key, required this.flutterLocalNotificationsPlugin});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  
  List<Task> tasks = [];
  List<Task> filteredTasks = [];
  SortOption _selectedSortOption = SortOption.Due;
  FilterOption _selectedFilterOption = FilterOption.All;
  List<Task> defaultOrder = [];
  late Box<Task> _box;

  @override
  void initState() {
    super.initState();
    Hive.initFlutter();
    _initialiseHive().then((_) {
    initializeTasks();
    _checkExpiredTasks();
    defaultOrder.addAll(tasks);
  });
  }

 @override
 void dispose() {
  _box.close();
  super.dispose();
 }

 Future<void> _initialiseHive() async{
  await Hive.openBox<Task>('tasks').then((box) {
    _box = box;
  });
 }

  void resetDefaultOrder() {
    setState(() {
      filteredTasks = List.from(defaultOrder);
    });
  }

  void _checkExpiredTasks() {
    final DateTime now = DateTime.now();
    for (Task task in tasks) {
      if (!task.isCompleted && task.dueDate.isBefore(now)) {
        _showExpiredTaskNotification(task);
      }
    }
  }

  void _showExpiredTaskNotification(Task task) async {
    await widget.flutterLocalNotificationsPlugin.show(
      0,
      'Your task "${task.title}" has expired',
      '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel id',
          'channel name',
          
          importance: Importance.high,
          priority: Priority.high,
          icon: 'app_icon',
        ),
      ),
    );
  }

  void initializeTasks() {
    final tasks = _box.values.toList().cast<Task>();
    setState(() {
      this.tasks = tasks;
      filteredTasks = tasks;
    });

  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 1, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 1, 1),
        titleTextStyle: const TextStyle(fontSize: 35),
        title: Text('GIOW', style: GoogleFonts.sixCaps(color: const Color.fromARGB(255, 255, 155, 255), fontWeight: FontWeight.w900,),),
        actions: [
          IconButton(
            onPressed: (){
              _resetDefaultOrder();
            }, 
            icon: const Icon(Icons.restart_alt, color: Color.fromARGB(255, 255, 155, 255),)
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color.fromARGB(255, 255, 155, 255),),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Color.fromARGB(255, 255, 155, 255)),
            onPressed: () {
              _showSortOptions(context);
            },
          ),
        ],
      ),
      body: filteredTasks.isEmpty?
      const Center(
        child: Text("No Items",
          style: TextStyle(
            color: Color.fromARGB(255, 30, 30, 30),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        )
      )
      :Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 20, 20, 20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Color.fromARGB(255, 255, 155, 255)),
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    filteredTasks = tasks
                        .where((task) =>
                            task.title.toLowerCase().contains(value.toLowerCase()) ||
                            task.description.toLowerCase().contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, index) {
                bool isExpired = filteredTasks[index].dueDate.isBefore(DateTime.now().subtract(const Duration(days: 1))) && !filteredTasks[index].isCompleted;
                return ListTile(
                  onTap: () {
                    _openEditModal(context, filteredTasks[index]);
                  },
                  leading: Checkbox(
                    value: filteredTasks[index].isCompleted,
                    activeColor: const Color.fromARGB(255, 255, 155, 255),
                    checkColor: Colors.black,
                    onChanged: (bool? value) {
                      setState(() {
                        filteredTasks[index].isCompleted = value ?? false;
                      });
                    },
                  ),
                  title: Text(
                    filteredTasks[index].title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: filteredTasks[index].isCompleted
                          ? TextDecoration.lineThrough
                          : isExpired? TextDecoration.none : TextDecoration.none,
                      decorationColor: const Color.fromARGB(255, 255, 155, 255),
                      decorationThickness: 3,
                      color: filteredTasks[index].isCompleted ? const Color.fromARGB(255, 255, 155, 255) : isExpired ? Colors.orange : Color.fromARGB(255, 255, 155, 255),
                    ),
                  ),
                  subtitle: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(filteredTasks[index].priority,style: TextStyle(fontWeight: FontWeight.bold ,color: filteredTasks[index].priority=='High'?const Color.fromARGB(255, 135, 36, 29):filteredTasks[index].priority=='Medium'?const Color.fromARGB(255, 151, 139, 35):const Color.fromARGB(255, 46, 105, 48)),),
                      const SizedBox(width: 10,),
                      Text(
                        '${filteredTasks[index].dueDate.day}-${filteredTasks[index].dueDate.month}-${filteredTasks[index].dueDate.year}',
                        style: const TextStyle(color: Color.fromARGB(255, 255, 205, 255)),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete,color: Color.fromARGB(255, 255, 155, 255),),
                    onPressed: () {
                      _deleteTask(filteredTasks[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openEditModal(context, null);
        },
        backgroundColor: const Color.fromARGB(255, 255, 155, 255),
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openEditModal(BuildContext context, Task? task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TaskDrawer(
          task: task,
          onSave: (Task editedTask) {
            if(task != null){
              final key = editedTask.createdDate.toString();
              _box.put(key, editedTask);
            } else {
              final key = editedTask.createdDate.toString();
              _box.add(editedTask);
            }
            setState(() {
              if (task != null) {
                
                int index = tasks.indexWhere((t) => t == task);
                if (index != -1) {
                  tasks[index] = editedTask;
                }
              } else {
                
                tasks.insert(0, editedTask); 
              }
              filteredTasks = tasks; 
            });
          },
        );
      },
    );
  }

  void _showFilterOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 155, 255),
          title: const Text('Filter',style: TextStyle(fontWeight: FontWeight.bold),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              _buildFilterOption(FilterOption.High),
              _buildFilterOption(FilterOption.Medium),
              _buildFilterOption(FilterOption.Low),
            ],
          ),
        );
      },
    ).then((_){
      _applyFilter();
    });
  }

  void _showSortOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 155, 255),
          title: const Text('Sort',style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption(SortOption.Due),
              _buildSortOption(SortOption.Priority),
  
            ],
          ),
        );
      },
    ).then((_){
      _applySort();
    });
  }

  Widget _buildFilterOption(FilterOption option) {
    return ListTile(

      title: Text(option.toString().split('.').last),
      
      onTap: () {
        setState(() {
          _selectedFilterOption = option;
          _applyFilter();
        });
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildSortOption(SortOption option) {
    String optionText;
  switch (option) {
    case SortOption.Due:
      optionText = 'Due';
      break;
    case SortOption.Priority:
      optionText = 'Priority';
      break;
  }

    return ListTile(
      title: Text(option.toString().split('.').last),
      onTap: () {
        setState(() {
          _selectedSortOption = option;
          _applySort();
        });
        Navigator.of(context).pop();
      },
    );
  }

  void _resetDefaultOrder() {
  setState(() {
    tasks.sort((a, b) => b.createdDate.compareTo(a.createdDate));  
    filteredTasks = List.from(tasks);  
  });
}


  void _applyFilter() {
    
      filteredTasks = tasks.where((task) => task.priority == _selectedFilterOption.toString().split('.').last).toList();
    
  }

  void _applySort() {
    if (_selectedSortOption == SortOption.Due) {
      filteredTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (_selectedSortOption == SortOption.Priority) {
      filteredTasks.sort((a, b) {
        if (a.priority == b.priority) {
          return b.createdDate.compareTo(a.createdDate); 
        }
        return _priorityToValue(b.priority) - _priorityToValue(a.priority);
      });
    } 
  }

  int _priorityToValue(String priority) {
    switch (priority) {
      case 'High':
        return 3;
      case 'Medium':
        return 2;
      case 'Low':
        return 1;
      default:
        return 0;
    }
  }

  void _deleteTask(Task task) {
    _box.delete(task);
    setState(() {
      tasks.remove(task);
      filteredTasks = tasks; 
    });
  }

  void _scheduleNotification(Task task) async {
    final DateTime now = DateTime.now();
    final DateTime tomorrow = now.add(Duration(days: 1));
    final DateTime dueDate = task.dueDate;
    
    if (dueDate.isAfter(now)) {
      await widget.flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Your task "${task.title}" is due tomorrow',
        '',
        tz.TZDateTime.from(dueDate.subtract(const Duration(days: 1)), tz.local).subtract(const Duration(hours: 10)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel id',
            'channel name',
            
            importance: Importance.high,
            priority: Priority.high,
            icon: 'app_icon',
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      await widget.flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Your task "${task.title}" is due today',
        '',
        tz.TZDateTime.from(dueDate, tz.local).subtract(Duration(hours: 10)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel id',
            'channel name',
            
            importance: Importance.high,
            priority: Priority.high,
            icon: 'app_icon',
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}

enum SortOption { Due, Priority }
enum FilterOption {All, High, Medium, Low }
