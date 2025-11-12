import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todonodejs/core/utils.dart';

class DateSelector extends StatefulWidget {
  DateTime selectedDate;
  final Function(DateTime) onTap;
  DateSelector({super.key, required this.selectedDate, required this.onTap});

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  int weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    final weekDates = generateWeekDates(weekOffset);
    String monthName = DateFormat.MMMM().format(weekDates.first);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    weekOffset--;
                  });
                },
                icon: Icon(Icons.arrow_back_ios),
              ),
              Text(
                monthName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    weekOffset++;
                  });
                },
                icon: Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              itemCount: weekDates.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                bool isSelected =
                    DateFormat.d().format(widget.selectedDate) ==
                        DateFormat.d().format(weekDates[index]) &&
                    DateFormat.M().format(widget.selectedDate) ==
                        DateFormat.M().format(weekDates[index]) &&
                    DateFormat.y().format(widget.selectedDate) ==
                        DateFormat.y().format(weekDates[index]);
                return GestureDetector(
                  onTap: () => widget.onTap(weekDates[index]),
                  child: Container(
                    width: 70,
                    margin: EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepOrangeAccent
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Colors.deepOrangeAccent
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat.d().format(weekDates[index]),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat.E().format(weekDates[index]),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
