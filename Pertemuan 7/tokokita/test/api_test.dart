// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Test Fetch from FakeStore API', () async {
    final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
    print('Status: ${response.statusCode}');
    print('Body Length: ${response.body.length}');
    final List<dynamic> data = jsonDecode(response.body);
    print('Total Products from API: ${data.length}');
    if (data.isNotEmpty) {
      print('First Product: ${data.first}');
    }
    expect(response.statusCode, 200);
    expect(data.length, greaterThan(0));
  });
}
