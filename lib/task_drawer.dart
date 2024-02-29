import 'package:flutter/material.dart';
import 'task.dart';

class TaskDrawer extends StatefulWidget {

  final Task? task; 

  const TaskDrawer({Key? key, this.task, required this.onSave}) : super(key: key);


  final Function(Task) onSave; 

  @override
  _TaskDrawerState createState() => _TaskDrawerState();
}

class _TaskDrawerState extends State<TaskDrawer> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _priority = 'Low';
  DateTime _dueDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
    }
  }

  bool _validateInputs() {
    if (_titleController.text.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0, 
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 40,left: 16,right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 20,),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  contentPadding: EdgeInsets.all(8),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 16),
                maxLines: 8,
                minLines: 1,
              ),
              DropdownButtonFormField(
                value: _priority,
                onChanged: (value) {
                  setState(() {
                    _priority = value.toString();
                  });
                },
                items: ['High', 'Medium', 'Low']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              ListTile(
                title: const Text('Due-date'),
                subtitle: Text('${_dueDate.day}-${_dueDate.month}-${_dueDate.year}'),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null && picked != _dueDate)
                    setState(() {
                      _dueDate = picked;
                    });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); 
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_validateInputs()) {
                        Task newTask = Task(
                          title: _titleController.text,
                          description: _descriptionController.text,
                          priority: _priority,
                          dueDate: _dueDate,
                          createdDate: DateTime.now(),
                        );
                        widget.onSave(newTask);
                        Navigator.pop(context); 
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Incomplete'),
                              content: const Text('Please enter a title.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Okay'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
