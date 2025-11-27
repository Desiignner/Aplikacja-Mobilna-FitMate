import 'package:fitmate/models/set_details.dart';

class Exercise {
  String name;
  int rest;
  List<SetDetails> sets;

  Exercise({
    this.name = '',
    this.rest = 60,
    List<SetDetails>? sets,
  }) : sets = sets ?? [];
}