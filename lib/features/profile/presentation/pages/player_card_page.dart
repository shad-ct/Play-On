import 'package:flutter/material.dart';
import 'package:playon/features/profile/data/models/player_card_data.dart';
import 'package:playon/features/profile/presentation/widgets/card_rarity_theme.dart';
import 'package:playon/features/profile/presentation/widgets/player_card_3d_wrapper.dart';
import 'package:playon/features/profile/presentation/widgets/rarity_progress_bar.dart';

class PlayerCardPage extends StatefulWidget {
  final PlayerCardData data;

  const PlayerCardPage({super.key, required this.data});

  @override
  State<PlayerCardPage> createState() => _PlayerCardPageState();
}

class _PlayerCardPageState extends State<PlayerCardPage> {
  late CardRarity _selectedRarity;
  SpecialEdition _selectedEdition = SpecialEdition.none;
  late PlayerCardData _displayData;
  bool _reducedMotion = false;

  // Rating representative of each tier for the demo tab selector
  static const _rarityRatings = {
    CardRarity.bronze: 52,
    CardRarity.silver: 67,
    CardRarity.gold: 82,
    CardRarity.elite: 93,
  };

  @override
  void initState() {
    super.initState();
    _selectedRarity = widget.data.rarity;
    _displayData = widget.data;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dpr = MediaQuery.of(context).devicePixelRatio;
    _reducedMotion = dpr < 2.0;
  }

  void _onRaritySelected(CardRarity rarity) {
    final demoRating = _rarityRatings[rarity]!;
    setState(() {
      _selectedRarity = rarity;
      _selectedEdition = SpecialEdition.none;
      // Keep base stats, just override rating so rarity+progress bar update
      _displayData = widget.data.copyWith(rating: demoRating);
    });
  }

  void _onEditionSelected(SpecialEdition edition) {
    setState(() => _selectedEdition = edition);
  }

  @override
  Widget build(BuildContext context) {
    final theme = getCardTheme(_selectedRarity, _selectedEdition);
    final bgColor = Color.lerp(
      const Color(0xFF0A0A0A),
      theme.backBgBase,
      0.7,
    )!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.borderColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'MY CARD',
          style: TextStyle(
            color: theme.ratingColor,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Rarity Tabs ────────────────────────────────────────────
            _RarityTabs(
              selected: _selectedRarity,
              onSelect: _onRaritySelected,
            ),
            // ── Special Edition Chips (Elite only) ─────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: _selectedRarity == CardRarity.elite
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: _EditionChips(
                        selected: _selectedEdition,
                        onSelect: _onEditionSelected,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            // ── 3D Card ────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: PlayerCard3dWrapper(
                  key: ValueKey('${_selectedRarity}_$_selectedEdition'),
                  data: _displayData,
                  edition: _selectedEdition,
                  reducedMotion: _reducedMotion,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // ── Progress Bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: RarityProgressBar(
                rating: _displayData.rating,
                edition: _selectedEdition,
              ),
            ),
            const SizedBox(height: 8),
            // ── Hint ───────────────────────────────────────────────────
            Text(
              'TAP TO FLIP  •  DRAG TO TILT',
              style: TextStyle(
                color: theme.borderColor.withValues(alpha: 0.4),
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Rarity Tabs ───────────────────────────────────────────────────────────────
class _RarityTabs extends StatelessWidget {
  final CardRarity selected;
  final ValueChanged<CardRarity> onSelect;
  const _RarityTabs({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (CardRarity.bronze, 'Bronze'),
      (CardRarity.silver, 'Silver'),
      (CardRarity.gold, 'Gold'),
      (CardRarity.elite, 'Elite'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: tabs.map((t) {
          final theme = getCardTheme(t.$1, SpecialEdition.none);
          final isSelected = selected == t.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.borderColor.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? theme.borderColor
                        : Colors.white.withValues(alpha: 0.1),
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: Text(
                  t.$2.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? theme.borderColor : Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Special Edition Chips ─────────────────────────────────────────────────────
class _EditionChips extends StatelessWidget {
  final SpecialEdition selected;
  final ValueChanged<SpecialEdition> onSelect;
  const _EditionChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const chips = [
      (SpecialEdition.none, 'Standard'),
      (SpecialEdition.inForm, 'In-Form'),
      (SpecialEdition.legend, 'Legend'),
      (SpecialEdition.streetKing, 'Street King'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: chips.map((c) {
          final theme = getCardTheme(CardRarity.elite, c.$1);
          final isSelected = selected == c.$1;
          return GestureDetector(
            onTap: () => onSelect(c.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.borderColor.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? theme.borderColor
                      : Colors.white.withValues(alpha: 0.1),
                  width: isSelected ? 1.5 : 0.5,
                ),
              ),
              child: Text(
                c.$2,
                style: TextStyle(
                  color: isSelected ? theme.borderColor : Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
