import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

class AppearanceManagerWidget extends StatefulWidget {
  const AppearanceManagerWidget({super.key});

  @override
  State<AppearanceManagerWidget> createState() => _AppearanceManagerWidgetState();
}

class _AppearanceManagerWidgetState extends State<AppearanceManagerWidget> {
  Position position = Position.bottomRight;

  final Future<bool> hasGradientFuture = AppearanceManagerHostApi().getTimerGradientEnable();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance Manager'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Story Reader close button position'),
          FractionallySizedBox(
            widthFactor: 1 / 2,
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                children: [
                  for (final position in Position.values)
                    TextButton(
                      onPressed: () {
                        AppearanceManagerHostApi().setClosePosition(position);
                      },
                      child: Text(position.name),
                    ),
                ],
              ),
            ),
          ),
          FutureBuilder(
            future: hasGradientFuture,
            builder: (_, snapshot) {
              if (snapshot.hasData) return GradientWidget(snapshot.requireData);
              if (snapshot.hasError) return Text('${snapshot.error}');
              return const LinearProgressIndicator();
            },
          ),
          const Divider(),
          const Text('ReaderBackground'),
          const ReaderBackgroundWidget(),
          const Divider(),
          const Text('ReaderRadius'),
          const ReaderRadiusWidget(),
        ],
      ),
    );
  }
}

class GradientWidget extends StatefulWidget {
  const GradientWidget(this.hasGradient, {super.key});

  final bool hasGradient;

  @override
  State<GradientWidget> createState() => _GradientWidgetState();
}

class _GradientWidgetState extends State<GradientWidget> {
  late bool hasGradient = widget.hasGradient;

  final gradients = [
    LinearGradient(colors: [Colors.red.withOpacity(.5), Colors.lightGreenAccent]),
    const LinearGradient(colors: [Colors.red, Colors.black], stops: [0.2, 0.8]),
    const LinearGradient(colors: [Colors.purple, Colors.amber], stops: [0.1, 0.3]),
  ];

  @override
  Widget build(BuildContext context) {
    final gradients = this.gradients.map(
          (it) => LinearGradient(
            colors: it.colors,
            stops: it.stops,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        );

    return Column(
      children: [
        Row(
          children: [
            const Text('setTimerGradientEnable'),
            Switch(
              value: hasGradient,
              onChanged: (isEnabled) {
                setState(() {
                  hasGradient = isEnabled;
                  AppearanceManagerHostApi().setTimerGradientEnable(hasGradient);
                });
              },
            ),
          ],
        ),
        Row(
          children: [
            for (final gradient in gradients)
              Expanded(
                flex: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(gradient: gradient),
                  child: TextButton(
                    onPressed: () {
                      AppearanceManagerHostApi().setTimerGradient(
                        colors: gradient.colors.map((it) => it.value).toList(),
                        locations: gradient.stops ?? [],
                      );
                    },
                    child: const Text('setTimerGradient'),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class ReaderBackgroundWidget extends StatefulWidget {
  const ReaderBackgroundWidget({super.key});

  @override
  State<ReaderBackgroundWidget> createState() => _ReaderBackgroundWidgetState();
}

class _ReaderBackgroundWidgetState extends State<ReaderBackgroundWidget> {
  @override
  Widget build(BuildContext context) {
    final colors = {
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.white,
      Colors.black,
    };

    return Row(
      children: [
        for (final color in colors)
          Expanded(
            flex: 1,
            child: ColoredBox(
              color: color,
              child: TextButton(
                onPressed: () {
                  AppearanceManagerHostApi().setReaderBackgroundColor(color.value);
                },
                child: const Text('setReaderBackgroundColor'),
              ),
            ),
          ),
      ],
    );
  }
}

class ReaderRadiusWidget extends StatefulWidget {
  const ReaderRadiusWidget({super.key});

  @override
  State<ReaderRadiusWidget> createState() => _ReaderRadiusWidgetState();
}

class _ReaderRadiusWidgetState extends State<ReaderRadiusWidget> {
  final double min = 2.0;
  final double max = 24.0;
  late double value = min;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$min'),
        Expanded(
          child: Slider(
            divisions: ((max - min) / 2).toInt(),
            value: value,
            min: min,
            max: max,
            label: '$value',
            onChanged: (newValue) {
              setState(() {
                value = newValue;
              });
              AppearanceManagerHostApi().setReaderCornerRadius(value.toInt());
            },
          ),
        ),
        Text('$max'),
      ],
    );
  }
}
