import 'package:flutter/material.dart';

import '../../../app/theme/resibo_theme.dart';
import '../../../core/state/game_controller.dart';
import '../../../domain/models/city_run_configuration.dart';
import '../../../l10n/l10n_extensions.dart';
import 'city_configuration_form.dart';
import 'game_overlay_shell.dart';

enum CitySlotsMode { start, continueRun }

Future<bool> showCitySlotsOverlay({
  required BuildContext context,
  required GameController controller,
  required CitySlotsMode mode,
}) async =>
    await showGameOverlay<bool>(
      context: context,
      builder: (overlayContext) =>
          _CitySlotsFlow(controller: controller, initialMode: mode),
    ) ??
    false;

enum _CitySlotsPage { slots, configure, confirmDelete }

class _CitySlotsFlow extends StatefulWidget {
  const _CitySlotsFlow({required this.controller, required this.initialMode});

  final GameController controller;
  final CitySlotsMode initialMode;

  @override
  State<_CitySlotsFlow> createState() => _CitySlotsFlowState();
}

class _CitySlotsFlowState extends State<_CitySlotsFlow> {
  late CitySlotsMode _mode;
  _CitySlotsPage _page = _CitySlotsPage.slots;
  int? _selectedSlotIndex;
  int? _deleteSlotIndex;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) => GameOverlayShell(
    kicker: _kicker,
    title: _title,
    backTooltip: _page == _CitySlotsPage.slots
        ? context.l10n.backToMainMenuTooltip
        : context.l10n.backToSaveSlots,
    onBack: _handleBack,
    child: AnimatedSwitcher(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 210),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: switch (_page) {
        _CitySlotsPage.slots => _buildSlotsPage(),
        _CitySlotsPage.configure => _buildConfigurePage(),
        _CitySlotsPage.confirmDelete => _buildDeletePage(),
      },
    ),
  );

  String get _kicker => switch (_page) {
    _CitySlotsPage.slots =>
      _mode == CitySlotsMode.start
          ? context.l10n.cityHallRecords
          : context.l10n.cityArchive,
    _CitySlotsPage.configure => context.l10n.newCityPermit,
    _CitySlotsPage.confirmDelete => context.l10n.recordsWarning,
  };

  String get _title => switch (_page) {
    _CitySlotsPage.slots =>
      _mode == CitySlotsMode.start
          ? context.l10n.startNewCity
          : context.l10n.continueCity,
    _CitySlotsPage.configure => context.l10n.configureNewCity,
    _CitySlotsPage.confirmDelete => context.l10n.deleteCityQuestion,
  };

  void _handleBack() {
    if (_page == _CitySlotsPage.slots) {
      Navigator.pop(context, false);
      return;
    }
    setState(() {
      _page = _CitySlotsPage.slots;
      _deleteSlotIndex = null;
    });
  }

  Widget _buildSlotsPage() => AnimatedBuilder(
    key: ValueKey('slots-${_mode.name}'),
    animation: widget.controller,
    builder: (context, _) {
      final slots = widget.controller.saveSlots;
      final hasEmptySlot = slots.any((slot) => slot == null);
      final hasSavedCity = slots.any((slot) => slot != null);
      return ListView(
        key: const Key('city_slots_page'),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _LedgerIntro(mode: _mode),
          if (widget.controller.hasPersistentStorage) ...[
            const SizedBox(height: 10),
            _LocalSaveStatus(controller: widget.controller),
          ],
          if (_notice != null) ...[
            const SizedBox(height: 10),
            _LedgerNotice(message: _notice!),
          ],
          const SizedBox(height: 14),
          for (var index = 0; index < slots.length; index++) ...[
            _SaveSlotCard(
              slotIndex: index,
              slot: slots[index],
              mode: _mode,
              isActive: widget.controller.activeSlotIndex == index,
              onOpen: slots[index] == null
                  ? _mode == CitySlotsMode.start
                        ? () => _configureSlot(index)
                        : null
                  : _mode == CitySlotsMode.continueRun
                  ? () => _continueCity(index)
                  : null,
              onDelete:
                  slots[index] != null && _mode == CitySlotsMode.continueRun
                  ? () => _confirmDelete(index)
                  : null,
            ),
            if (index != slots.length - 1) const SizedBox(height: 10),
          ],
          if (_mode == CitySlotsMode.start && !hasEmptySlot) ...[
            const SizedBox(height: 14),
            const _AllSlotsMessage(),
          ],
          if (_mode == CitySlotsMode.continueRun && !hasSavedCity) ...[
            const SizedBox(height: 14),
            ChunkyPaperButton(
              label: context.l10n.startANewCity,
              icon: Icons.add_business_rounded,
              color: const Color(0xFF3E783A),
              buttonKey: const Key('empty_archive_start_city'),
              onPressed: () => setState(() {
                _mode = CitySlotsMode.start;
                _notice = null;
              }),
            ),
          ],
        ],
      );
    },
  );

  Widget _buildConfigurePage() => CityConfigurationForm(
    slotIndex: _selectedSlotIndex!,
    onSubmit: _createCity,
    onBack: _handleBack,
  );

  Widget _buildDeletePage() {
    final index = _deleteSlotIndex!;
    final slot = widget.controller.saveSlots[index]!;
    return ListView(
      key: const Key('delete_city_confirmation'),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 26),
      children: [
        Center(
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0x1FAA3F4B),
              shape: BoxShape.circle,
              border: Border.all(color: ResiboColors.mutedRed, width: 3),
            ),
            child: const Icon(
              Icons.delete_forever_rounded,
              color: ResiboColors.mutedRed,
              size: 52,
            ),
          ),
        ),
        const SizedBox(height: 17),
        Text(
          context.l10n.shredCityQuestion(slot.cityName),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: ResiboColors.navy,
            fontFamily: 'LilitaOne',
            fontSize: 25,
            height: 1.1,
            letterSpacing: .5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.deleteCityBody(index + 1),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF43372B),
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: InkStamp(
            text: context.l10n.cannotBeUndone,
            color: ResiboColors.mutedRed,
            angle: -.025,
          ),
        ),
        const SizedBox(height: 25),
        ChunkyPaperButton(
          label: context.l10n.keepCityFile,
          icon: Icons.inventory_2_rounded,
          color: ResiboColors.navy,
          buttonKey: const Key('cancel_delete_city'),
          onPressed: _handleBack,
        ),
        const SizedBox(height: 12),
        ChunkyPaperButton(
          label: context.l10n.deleteForever,
          icon: Icons.delete_forever_rounded,
          color: ResiboColors.mutedRed,
          buttonKey: const Key('confirm_delete_city'),
          onPressed: () => _deleteCity(index, slot.cityName),
        ),
      ],
    );
  }

  void _configureSlot(int index) {
    setState(() {
      _selectedSlotIndex = index;
      _page = _CitySlotsPage.configure;
    });
  }

  void _createCity(CityRunConfiguration configuration) {
    widget.controller.createCity(
      slotIndex: _selectedSlotIndex!,
      configuration: configuration,
    );
    Navigator.pop(context, true);
  }

  void _continueCity(int index) {
    widget.controller.continueCity(index);
    Navigator.pop(context, true);
  }

  void _confirmDelete(int index) => setState(() {
    _deleteSlotIndex = index;
    _page = _CitySlotsPage.confirmDelete;
  });

  void _deleteCity(int index, String cityName) {
    widget.controller.deleteCity(index);
    setState(() {
      _deleteSlotIndex = null;
      _notice = context.l10n.cityRemovedNotice(cityName, index + 1);
      _page = _CitySlotsPage.slots;
    });
  }
}

class _LedgerIntro extends StatelessWidget {
  const _LedgerIntro({required this.mode});

  final CitySlotsMode mode;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(14, 11, 14, 12),
    decoration: BoxDecoration(
      color: const Color(0x1A16263B),
      border: Border.all(color: ResiboColors.navy, width: 2),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      children: [
        Icon(
          mode == CitySlotsMode.start
              ? Icons.note_add_rounded
              : Icons.folder_copy_rounded,
          color: ResiboColors.navy,
          size: 29,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            mode == CitySlotsMode.start
                ? context.l10n.startCityIntro
                : context.l10n.continueCityIntro,
            style: const TextStyle(
              color: ResiboColors.navy,
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _SaveSlotCard extends StatelessWidget {
  const _SaveSlotCard({
    required this.slotIndex,
    required this.slot,
    required this.mode,
    required this.isActive,
    required this.onOpen,
    required this.onDelete,
  });

  final int slotIndex;
  final CitySaveSlot? slot;
  final CitySlotsMode mode;
  final bool isActive;
  final VoidCallback? onOpen;
  final VoidCallback? onDelete;

  bool get _isEmpty => slot == null;

  @override
  Widget build(BuildContext context) {
    final actionKey = _isEmpty
        ? Key('start_city_slot_$slotIndex')
        : Key('continue_city_slot_$slotIndex');
    return Container(
      constraints: const BoxConstraints(minHeight: 104),
      decoration: BoxDecoration(
        color: _isEmpty ? const Color(0xA8F5E4BC) : const Color(0xFFFDF2D5),
        border: Border.all(color: const Color(0xFF17212A), width: 3),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(color: Color(0x5C5D3C20), offset: Offset(3, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 54,
                color: _isEmpty ? const Color(0xFF6E6657) : ResiboColors.navy,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.slot.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFFD77B),
                        fontFamily: 'LilitaOne',
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      (slotIndex + 1).toString().padLeft(2, '0'),
                      style: const TextStyle(
                        color: Color(0xFFFFF1C9),
                        fontFamily: 'LuckiestGuy',
                        fontSize: 25,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    key: actionKey,
                    onTap: onOpen,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
                      child: _isEmpty
                          ? _EmptySlotCopy(canCreate: onOpen != null)
                          : _OccupiedSlotCopy(slot: slot!, isActive: isActive),
                    ),
                  ),
                ),
              ),
              if (_isEmpty && onOpen != null)
                const SizedBox(
                  width: 43,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: ResiboColors.navy,
                    size: 31,
                  ),
                )
              else if (!_isEmpty && mode == CitySlotsMode.start)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Center(
                    child: InkStamp(
                      text: context.l10n.occupied,
                      color: ResiboColors.mutedRed,
                    ),
                  ),
                )
              else if (!_isEmpty && mode == CitySlotsMode.continueRun)
                SizedBox(
                  width: 58,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Material(
                          color: const Color(0xFF2C70A8),
                          child: InkWell(
                            key: Key('open_city_slot_$slotIndex'),
                            onTap: onOpen,
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Color(0xFFFFF0C8),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: ResiboColors.mutedRed,
                        child: InkWell(
                          key: Key('delete_city_slot_$slotIndex'),
                          onTap: onDelete,
                          child: const SizedBox(
                            height: 43,
                            child: Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFFFF0C8),
                              size: 23,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptySlotCopy extends StatelessWidget {
  const _EmptySlotCopy({required this.canCreate});

  final bool canCreate;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        context.l10n.emptyCityFile.toUpperCase(),
        style: TextStyle(
          color: canCreate ? ResiboColors.navy : const Color(0xFF6D6254),
          fontFamily: 'LilitaOne',
          fontSize: 17,
          letterSpacing: .45,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        canCreate
            ? context.l10n.tapToRegisterCity
            : context.l10n.noSavedCityHere,
        style: const TextStyle(
          color: Color(0xFF6A5842),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _OccupiedSlotCopy extends StatelessWidget {
  const _OccupiedSlotCopy({required this.slot, required this.isActive});

  final CitySaveSlot slot;
  final bool isActive;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Flexible(
            child: Text(
              slot.cityName.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: ResiboColors.navy,
                fontFamily: 'LilitaOne',
                fontSize: 18,
                height: 1,
                letterSpacing: .4,
              ),
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 7),
            InkStamp(
              text: context.l10n.current,
              color: Color(0xFF3E783A),
              angle: -.02,
            ),
          ],
        ],
      ),
      const SizedBox(height: 7),
      Text(
        context.l10n.caseTermLabel(slot.scenarioName, slot.term).toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF785A35),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: .65,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        context.l10n.runProgressLabel(slot.progress),
        style: const TextStyle(
          color: Color(0xFF44372A),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _LedgerNotice extends StatelessWidget {
  const _LedgerNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: const Color(0x183E783A),
      border: Border.all(color: const Color(0xFF3E783A), width: 2),
      borderRadius: BorderRadius.circular(3),
    ),
    child: Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF3E783A)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: ResiboColors.navy,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _LocalSaveStatus extends StatelessWidget {
  const _LocalSaveStatus({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final hasError = controller.persistenceError != null;
    final saving = controller.isSaving;
    final color = hasError ? ResiboColors.mutedRed : const Color(0xFF3E783A);
    return Container(
      key: const Key('local_save_status'),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          if (saving && !hasError)
            SizedBox.square(
              dimension: 19,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
            )
          else
            Icon(
              hasError ? Icons.sync_problem_rounded : Icons.save_rounded,
              color: color,
              size: 21,
            ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              hasError
                  ? context.l10n.citySaveProblem
                  : saving
                  ? context.l10n.savingCityFiles
                  : context.l10n.savedOnDevice,
              style: const TextStyle(
                color: ResiboColors.navy,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (hasError)
            IconButton(
              key: const Key('retry_save'),
              tooltip: context.l10n.retrySave,
              visualDensity: VisualDensity.compact,
              onPressed: controller.retryPersistence,
              icon: const Icon(Icons.sync_rounded),
            ),
        ],
      ),
    );
  }
}

class _AllSlotsMessage extends StatelessWidget {
  const _AllSlotsMessage();

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(Icons.info_outline_rounded, color: ResiboColors.mutedRed),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          context.l10n.allSlotsOccupied,
          style: const TextStyle(
            color: Color(0xFF5F382F),
            fontSize: 12,
            height: 1.3,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    ],
  );
}
