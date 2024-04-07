import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/task.dart';
import 'package:todo/task_drawer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  @override
  void initState() {
    super.initState();
    initializeTasks();
    _checkExpiredTasks();
    defaultOrder.addAll(tasks);
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
    setState(() {
      tasks = tasks.toList();
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
        title: Text('GIOW', style: GoogleFonts.sixCaps(color: Colors.amber, fontWeight: FontWeight.w900,),),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.amber,),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.amber),
            onPressed: () {
              _showSortOptions(context);
            },
          ),
        ],
      ),
      body: Column(
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
                  prefixIcon: Icon(Icons.search, color: Colors.amber),
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
                    activeColor: Colors.amber,
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
                      decorationColor: Colors.amber,
                      decorationThickness: 3,
                      color: filteredTasks[index].isCompleted ? Colors.amber : isExpired ? Colors.red : Colors.amber,
                    ),
                  ),
                  subtitle: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(filteredTasks[index].priority,style: TextStyle(fontWeight: FontWeight.bold ,color: filteredTasks[index].priority=='High'?const Color.fromARGB(255, 135, 36, 29):filteredTasks[index].priority=='Medium'?const Color.fromARGB(255, 151, 139, 35):const Color.fromARGB(255, 46, 105, 48)),),
                      const SizedBox(width: 10,),
                      Text(
                        '${filteredTasks[index].dueDate.day}-${filteredTasks[index].dueDate.month}-${filteredTasks[index].dueDate.year}',
                        style: const TextStyle(color: Color.fromARGB(255, 255, 221, 120)),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete,color: Colors.amber,),
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
        backgroundColor: Colors.amber,
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
          backgroundColor: Colors.amber,
          title: const Text('Filter',style: TextStyle(fontWeight: FontWeight.bold),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption(FilterOption.All),
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
          backgroundColor: Colors.amber,
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

  void _applyFilter() {
    if (_selectedFilterOption == FilterOption.All) {
      tasks.sort((a, b) => b.createdDate.compareTo(a.createdDate));
      filteredTasks = tasks;
    } else {
      filteredTasks = tasks.where((task) => task.priority == _selectedFilterOption.toString().split('.').last).toList();
    }
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
        tz.TZDateTime.from(dueDate.subtract(Duration(days: 1)), tz.local).subtract(Duration(hours: 10)),
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
enum FilterOption { All, High, Medium, Low }
