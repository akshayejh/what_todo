import 'package:flutter/material.dart';
import 'package:wemapgl/wemapgl.dart';
import 'package:what_todo/database_helper.dart';
import 'package:what_todo/models/task.dart';
import 'package:what_todo/models/todo.dart';
import 'package:what_todo/widgets.dart';

class Taskpage extends StatefulWidget {
  final Task task;

  Taskpage({@required this.task});

  @override
  _TaskpageState createState() => _TaskpageState();
}

class _TaskpageState extends State<Taskpage> {
  DatabaseHelper _dbHelper = DatabaseHelper();

  WeMapSearchAPI searchAPI = WeMapSearchAPI();
  // Timer? t;

  List<WeMapPlace> result = [];
  LatLng latLng = LatLng(20.037, 105.7876);

  int _taskId = 0;
  String _taskTitle = "";
  String _taskDescription = "";
  String _taskLocation = "";

  FocusNode _titleFocus;
  FocusNode _descriptionFocus;
  FocusNode _todoFocus;
  FocusNode _locationFocus;

  bool _contentVisile = false;

  @override
  void initState() {
    if (widget.task != null) {
      // Set visibility to true
      _contentVisile = true;

      _taskTitle = widget.task.title;
      _taskDescription = widget.task.description;
      _taskId = widget.task.id;
      _taskLocation = widget.task.location; // cho nay lam gi day ?
    }

    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _todoFocus = FocusNode();
    _locationFocus = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _todoFocus.dispose();
    _locationFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 24.0,
                      bottom: 6.0,
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Image(
                              image: AssetImage(
                                  'assets/images/back_arrow_icon.png'),
                            ),
                          ),
                        ),
                        Expanded(
                          //
                          child: TextField(
                            focusNode: _titleFocus,
                            onSubmitted: (value) async {
                              // Check if the field is not empty
                              if (value != "") {
                                // Check if the task is null
                                if (widget.task == null) {
                                  Task _newTask = Task(title: value);
                                  _taskId =
                                      await _dbHelper.insertTask(_newTask);
                                  setState(() {
                                    _contentVisile = true;
                                    _taskTitle = value;
                                  });
                                } else {
                                  await _dbHelper.updateTaskTitle(
                                      _taskId, value);
                                  print("Task Updated");
                                }
                                _descriptionFocus.requestFocus();
                              }
                            },
                            controller: TextEditingController()
                              ..text = _taskTitle,
                            decoration: InputDecoration(
                              hintText: "Tiêu đề",
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF211551),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Visibility(
                    // nhap vao description
                    visible: _contentVisile,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 12.0,
                      ),
                      child: TextField(
                        focusNode: _descriptionFocus,
                        onSubmitted: (value) async {
                          if (value != "") {
                            if (_taskId != 0) {
                              await _dbHelper.updateTaskDescription(
                                  _taskId, value);
                              _taskDescription = value;
                            }
                          }
                          _todoFocus.requestFocus();
                        },
                        controller: TextEditingController()
                          ..text = _taskDescription,
                        decoration: InputDecoration(
                          hintText: "Mô tả",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 24.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _contentVisile,
                    child: FutureBuilder(
                      initialData: [],
                      future: _dbHelper.getTodo(_taskId),
                      builder: (context, snapshot) {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () async {
                                  if (snapshot.data[index].isDone == 0) {
                                    await _dbHelper.updateTodoDone(
                                        snapshot.data[index].id, 1);
                                  } else {
                                    await _dbHelper.updateTodoDone(
                                        snapshot.data[index].id, 0);
                                  }
                                  setState(() {});
                                },
                                child: TodoWidget(
                                  text: snapshot.data[index].title,
                                  isDone: snapshot.data[index].isDone == 0
                                      ? false
                                      : true,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Visibility(
                    // doan nhap vao location
                    visible: _contentVisile,
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Địa điểm',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                            Text(
                              _taskLocation,
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ],
                        )),
                  ),
                  Visibility(
                      // doan nhap vao location
                      visible: _contentVisile,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.0, vertical: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nhập địa điểm tìm kiếm',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18.0),
                            ),
                            TextField(
                              decoration: InputDecoration(
                                hintText: "Tìm kiếm địa điểm",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                              ),
                              onChanged: (text) async {
                                // if (t != null) t!.cancel();
                                // t = Timer(Duration(seconds: 1), () async {
                                List<WeMapPlace> places =
                                    await searchAPI.getSearchResult(
                                        text, latLng, WeMapGeocoder.Pelias);
                                setState(() {
                                  result = places;
                                });
                                // });
                              },
                            ),
                          ],
                        ),
                      )),
                  Visibility(
                      // doan nhap vao location
                      visible: _contentVisile,
                      child: Expanded(
                          child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.0,
                        ),
                        child: ListView.builder(
                            itemCount: result.length,
                            itemBuilder: (BuildContext ctxt, int idx) {
                              return ListTile(
                                  onTap: () async {
                                    if (result[idx].placeName != "") {
                                      if (_taskId != 0) {
                                        await _dbHelper.updateTaskLocation(
                                            _taskId, result[idx].placeName);
                                        setState(() {
                                          _taskLocation = result[idx].placeName;
                                        });
                                      }
                                    }
                                    _todoFocus.requestFocus();
                                  },
                                  title: Text(result[idx].placeName ?? ""));
                            }),
                      ))),
                  Visibility(
                    visible: _contentVisile,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20.0,
                            height: 20.0,
                            margin: EdgeInsets.only(
                              right: 12.0,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(6.0),
                                border: Border.all(
                                    color: Color(0xFF86829D), width: 1.5)),
                            child: Image(
                              image: AssetImage('assets/images/check_icon.png'),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              focusNode: _todoFocus,
                              controller: TextEditingController()..text = "",
                              onSubmitted: (value) async {
                                // Check if the field is not empty
                                if (value != "") {
                                  if (_taskId != 0) {
                                    DatabaseHelper _dbHelper = DatabaseHelper();
                                    Todo _newTodo = Todo(
                                      title: value,
                                      isDone: 0,
                                      taskId: _taskId,
                                    );
                                    await _dbHelper.insertTodo(_newTodo);
                                    setState(() {});
                                    _todoFocus.requestFocus();
                                  } else {
                                    print("Task doesn't exist");
                                  }
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Nhập công việc",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),

              // icon google map
              // Visibility(
              //   visible: _contentVisile,
              //   child: Positioned(
              //     bottom: 24.0,
              //     right: 85.0,
              //     child: GestureDetector(
              //       // doan nay la kick vao no chuyen trang, can edit cho nay
              //       // onTap: () {
              //       //   Navigator.push(
              //       //     context,
              //       //     MaterialPageRoute(
              //       //         builder: (context) => SearchAPI(task: widget.task)),
              //       //   ).then((value) {
              //       //     setState(() {});
              //       //   });
              //       // },
              //       child: Container(
              //         width: 60.0,
              //         height: 60.0,
              //         decoration: BoxDecoration(
              //           gradient: LinearGradient(
              //               colors: [Color(0), Color(0)],
              //               begin: Alignment(0.0, -1.0),
              //               end: Alignment(0.0, 1.0)),
              //           borderRadius: BorderRadius.circular(20.0),
              //         ),
              //         child: Image(
              //           image: AssetImage(
              //             "assets/images/google-maps.png",
              //           ),
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
              Visibility(
                visible: _contentVisile,
                child: Positioned(
                  bottom: 24.0,
                  right: 24.0,
                  child: GestureDetector(
                    onTap: () async {
                      if (_taskId != 0) {
                        await _dbHelper.deleteTask(_taskId);
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        color: Color(0xFFFE3577),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Image(
                        image: AssetImage(
                          "assets/images/delete_icon.png",
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
