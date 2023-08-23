import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/timer_model.dart';

class TimerListPage extends StatefulWidget {
  const TimerListPage({super.key});

  @override
  _TimerListPageState createState() => _TimerListPageState();
}

class _TimerListPageState extends State<TimerListPage> {
  List<CustomTimer> timers = [];
  TextEditingController minuteController = TextEditingController();
  TextEditingController secondController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late Timer timer;

  @override
  void initState() {
    if (mounted) {
      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {});
        },
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    minuteController.dispose();
    secondController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text("Timer List App"),
            ),
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(children: [
                      Column(
                        children: [
                          TextFormField(
                            controller: minuteController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              labelText: 'Minutes',
                            ),
                            textInputAction: TextInputAction.next,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter minutes';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              if (int.parse(value) > 59) {
                                return 'minutes cannot be greater than 59';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            textInputAction: TextInputAction.done,
                            controller: secondController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              labelText: 'Seconds',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter seconds';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              if (int.parse(value) > 60) {
                                return 'Seconds cannot be greater than 60';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.02,
                      ),
                      FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            fixedSize: Size(
                              MediaQuery.sizeOf(context).width,
                              MediaQuery.sizeOf(context).height * 0.05,
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text("Add Timer"),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (timers.length >= 10) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'You can only add 10 timers at a time'),
                                  ),
                                );
                              } else {
                                int? minutes = minuteController.text.isEmpty
                                    ? null
                                    : int.parse(minuteController.text);
                                int seconds = int.parse(secondController.text);

                                setState(() {
                                  timers.add(CustomTimer(Duration(
                                      seconds: seconds,
                                      minutes: minutes ?? 0)));
                                });
                              }
                            }
                          }),
                    ]),
                  ),
                ),
              ),
            ),
            timers.isEmpty
                ? const SliverToBoxAdapter(
                    child: Center(child: Text("No timers added yet")))
                : SliverList.separated(
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: timers.length,
                    itemBuilder: (context, index) {
                      WidgetsBinding.instance.addPostFrameCallback((value) {
                        if (timers.isNotEmpty) {
                          if (timers[index].remainingDuration.inSeconds == 0) {
                            _removeTimer(index);
                          }
                        }
                      });
                      return ListTile(
                        key: ValueKey(
                            timers[index].initialDuration.inSeconds + index),
                        title: ValueListenableBuilder<String>(
                          valueListenable: timers[index].displayTime,
                          builder: (context, time, child) {
                            return Text(
                              time,
                              style: TextStyle(
                                color: !timers[index].isRunning
                                    ? Colors.yellow.shade700
                                    : timers[index]
                                                .remainingDuration
                                                .inSeconds <
                                            30
                                        ? Colors.red
                                        : Colors.green,
                                fontSize: 35,
                              ),
                            );
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                timers[index].isRunning
                                    ? Icons.pause_circle
                                    : Icons.play_arrow_rounded,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                if (timers[index].isRunning) {
                                  _stopTimer(index);
                                } else {
                                  _startTimer(index);
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _removeTimer(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _removeTimer(int index) {
    setState(() {
      timers[index].timer.cancel();
      timers.removeAt(index);
    });
  }

  void _stopTimer(int index) {
    setState(() {
      timers[index].stop();
    });
  }

  void _startTimer(int index) {
    setState(() {
      timers[index].start();
    });
  }
}
