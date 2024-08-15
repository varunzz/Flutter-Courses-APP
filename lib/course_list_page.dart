import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CourseListPage extends StatefulWidget {
  @override
  _CourseListPageState createState() => _CourseListPageState();
}

class _CourseListPageState extends State<CourseListPage> {
  List<dynamic> _courses = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('https://test.gslstudent.lilacinfotech.com'));
      if (response.statusCode == 200) {
        List<dynamic> fetchedCourses = json.decode(response.body)['data'];

        setState(() {
          _courses.addAll(fetchedCourses);
          _currentPage++;
          _isLoading = false;
          _hasMore = fetchedCourses.isNotEmpty;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching courses: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
      ),
      body: _courses.isEmpty && _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _courses.length + 1,
              itemBuilder: (context, index) {
                if (index == _courses.length) {
                  if (_isLoading) {
                    return Center(child: CircularProgressIndicator());
                  } else if (_hasMore) {
                    return ElevatedButton(
                      onPressed: _fetchCourses,
                      child: Text('Load More'),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Text('No more courses')),
                    );
                  }
                }

                return ListTile(
                  title: Text(_courses[index]['title']),
                  subtitle: Text(_courses[index]['description']),
                );
              },
            ),
    );
  }
}
