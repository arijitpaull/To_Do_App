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
        
        child: Material(
          color:  const Color.fromARGB(255, 33, 33, 33),
          borderRadius: BorderRadius.circular(20),
          child: Container(
              margin: const EdgeInsets.only(top: 40,left: 16,right: 16, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title', 
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 255, 155, 255)
                      ),
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20,),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 255, 155, 255)),
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    maxLines: 8,
                    minLines: 1,
                  ),
                  DropdownButtonFormField(
                    value: _priority,
                    dropdownColor: const Color.fromARGB(255, 57, 57, 57),
                    onChanged: (value) {
                      setState(() {
                        _priority = value.toString();
                      });
                    },
                    items: ['High', 'Medium', 'Low']
                        .map<DropdownMenuItem<String>>((String value) {
                          Color priorityTextColor;
                          if(value=='High'){
                            priorityTextColor = Colors.red;
                          } else if(value == "Medium"){
                            priorityTextColor = Colors.yellow;
                          } else {
                            priorityTextColor = Colors.green;
                          }
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(color: priorityTextColor),
                        ),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Priority',labelStyle: TextStyle(color: Color.fromARGB(255, 255, 155, 255))),
                  ),
                  ListTile(
                    title: const Text('Due-date', style: TextStyle(color: Color.fromARGB(255, 255, 155, 255)),),
                    subtitle: Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',style: const TextStyle(color: Color.fromARGB(255, 255, 205, 255)),),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); 
                        },
                        child: const Text('Cancel',style: TextStyle(color: Color.fromARGB(255, 255, 155, 255)),),
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
                                  backgroundColor: Color.fromARGB(255, 255, 155, 255),
                                  title: const Text('Incomplete'),
                                  content: const Text('Please enter a title.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.black)),
                                      child: const Text('Okay',style: TextStyle(color: Color.fromARGB(255, 255, 155, 255)),),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 255, 155, 255))),
                        child: const Text('Save',style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ),
        ),
      );
  }
}
