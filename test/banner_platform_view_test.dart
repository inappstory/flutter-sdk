import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:inappstory_plugin/src/widgets/base/banner_platform_view.dart';
import 'package:inappstory_plugin/src/widgets/decorators/banner_grid_decoration.dart';
import 'package:inappstory_plugin/src/widgets/decorators/banner_list_decoration.dart';

class _CapturingBannerPlatformView extends BannerPlatformView {
  const _CapturingBannerPlatformView({
    required this.onBuild,
    required super.layoutType,
    super.gridDecoration,
    super.listDecoration,
  }) : super(
          bannerWidgetId: 'test-widget',
          placeId: 'test-place',
          onPlatformViewCreated: _onPlatformViewCreated,
          autoLoad: false,
        );

  final void Function(Map<String, dynamic> creationParams) onBuild;

  static void _onPlatformViewCreated() {}

  @override
  Widget buildPlatformView(
    BuildContext context,
    String viewType,
    Map<String, dynamic> creationParams,
  ) {
    onBuild(creationParams);
    return const SizedBox.shrink();
  }
}

void main() {
  group('$BannerPlatformView', () {
    Map<String, dynamic>? creationParams;

    setUp(() => creationParams = null);

    testWidgets(
        'WHEN configured as a grid THEN layout and grid decoration reach native creation parameters',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _CapturingBannerPlatformView(
            layoutType: 'grid',
            gridDecoration: const BannerGridDecoration(
              horizontalGap: 12.5,
              verticalGap: 16.5,
              cornerRadius: 4,
            ),
            onBuild: (params) => creationParams = params,
          ),
        ),
      );

      expect(creationParams?['layoutType'], 'grid');
      expect(creationParams?['gridHorizontalGap'], 12.5);
      expect(creationParams?['gridVerticalGap'], 16.5);
      expect(creationParams?['gridCornerRadius'], 4.0);
      expect(creationParams?['gridColumns'], 2);
    });

    testWidgets(
        'WHEN configured as a grid with custom columns THEN columns count reaches native creation parameters',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _CapturingBannerPlatformView(
            layoutType: 'grid',
            gridDecoration: const BannerGridDecoration(
              columns: 3,
            ),
            onBuild: (params) => creationParams = params,
          ),
        ),
      );

      expect(creationParams?['layoutType'], 'grid');
      expect(creationParams?['gridColumns'], 3);
    });

    testWidgets(
        'WHEN configured as a carousel THEN grid parameters are not sent',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _CapturingBannerPlatformView(
            layoutType: 'carousel',
            onBuild: (params) => creationParams = params,
          ),
        ),
      );

      expect(
        creationParams?.keys,
        isNot(anyOf(
          contains('gridHorizontalGap'),
          contains('gridVerticalGap'),
          contains('gridCornerRadius'),
          contains('gridColumns'),
        )),
      );
    });

    testWidgets(
        'WHEN configured as a list THEN the native layout is vertical list',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _CapturingBannerPlatformView(
            layoutType: 'list',
            onBuild: (params) => creationParams = params,
          ),
        ),
      );

      expect(creationParams?['layoutType'], 'list');
      expect(
        creationParams?.keys,
        isNot(anyOf(
          contains('gridHorizontalGap'),
          contains('gridVerticalGap'),
          contains('gridCornerRadius'),
          contains('gridColumns'),
          contains('listEdgePadding'),
          contains('listVerticalGap'),
          contains('listCornerRadius'),
        )),
      );
    });

    testWidgets(
        'WHEN configured with list decoration THEN appearance reaches native creation parameters',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: _CapturingBannerPlatformView(
            layoutType: 'list',
            listDecoration: const BannerListDecoration(
              edgePadding: 12.5,
              verticalGap: 16.5,
              cornerRadius: 4,
            ),
            onBuild: (params) => creationParams = params,
          ),
        ),
      );

      expect(creationParams?['listEdgePadding'], 12.5);
      expect(creationParams?['listVerticalGap'], 16.5);
      expect(creationParams?['listCornerRadius'], 4.0);
    });
  });
}
