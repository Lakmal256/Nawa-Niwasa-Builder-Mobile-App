import 'package:flutter/material.dart';
import 'package:insee_builder/locator.dart';
import 'package:insee_builder/service/service.dart';
import 'package:insee_builder/ui/ui.dart';

import '../../../localizations.dart';
import '../../../util/util.dart';
import '../../indicators.dart';
import '../../popup.dart';

/// Team view

class ContractorTeamView extends StatefulWidget {
  const ContractorTeamView({super.key, required this.builder});

  final BuilderDto builder;

  @override
  State<ContractorTeamView> createState() => _ContractorTeamViewState();
}

class _ContractorTeamViewState extends State<ContractorTeamView> {
  late Future<List<CrewMemberDto>> future;

  handleAddNewCrewMember() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => StandaloneContractorAddBuilderFormView(
        builder: widget.builder,
        onDone: Navigator.of(context).pop,
        controller: CrewMemberFormController(
          initialValue: CrewMemberFormValue.empty(),
        ),
      ),
    ));
    refresh();
  }

  handleEditCrewMember(CrewMemberDto data) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => StandaloneContractorEditBuilderFormView(
        member: data,
        builder: widget.builder,
        onDone: Navigator.of(context).pop,
        controller: CrewMemberFormController(
          initialValue: CrewMemberFormValue.empty()
            ..name = data.displayName
            ..mobile = data.contactNumber
            ..nic = data.nicNumber,
        ),
      ),
    ));
    refresh();
  }

  handleDeleteCrewMember(CrewMemberDto data) async {
    try {
      locate<ProgressIndicatorController>().show();
      await locate<RestService>().deleteCrewMember(data.id!);
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Member Deleted",
          subtitle: "Crew member deleted successfully",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
      refresh();
    } on Exception {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Something went wrong",
          subtitle: "Sorry, something went wrong here",
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } finally {
      locate<ProgressIndicatorController>().hide();
    }
  }

  Future<List<CrewMemberDto>> fetchBuilders(int id) async => locate<RestService>().getAllCrewMembers(id);

  @override
  void initState() {
    future = fetchBuilders(widget.builder.id!);
    super.initState();
  }

  refresh() async {
    return setState(() {
      future = fetchBuilders(widget.builder.id!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.nN_270,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                FilledButton(
                  onPressed: handleAddNewCrewMember,
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                  child: Text(AppLocalizations.of(context)!.nN_271),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                var items = snapshot.data ?? [];
                return RefreshIndicator(
                  onRefresh: () => refresh(),
                  child: ListView.separated(
                    itemBuilder: (context, i) {
                      var item = items[i];
                      return TeamItemCard(
                        title: item.displayName,
                        subtitle1: "+94${item.contactNumber}",
                        subtitle2: item.nicNumber ?? "N/A",
                        onAction: (action) {
                          if (action == TeamItemAction.edit) handleEditCrewMember(item);
                          if (action == TeamItemAction.delete) handleDeleteCrewMember(item);
                        },
                      );
                    },
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    separatorBuilder: (context, i) => const SizedBox(height: 15),
                    itemCount: items.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Team Item
enum TeamItemAction { edit, delete }

class TeamItemCard extends StatelessWidget {
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String? avatarUrl;
  final List<String> skills;
  final Function(TeamItemAction) onAction;

  const TeamItemCard({
    super.key,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    required this.onAction,
    this.skills = const [],
    this.avatarUrl,
  });

  List<PopupMenuEntry<TeamItemAction>> renderMenuList(BuildContext context) {
    return TeamItemAction.values.map((action) {
      return switch (action) {
        TeamItemAction.edit => PopupMenuItem(
            value: action,
            // "Edit"
            child: Text(
              AppLocalizations.of(context)!.nN_1000,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        TeamItemAction.delete => PopupMenuItem(
            value: action,
            // "Delete"
            child: Text(
              AppLocalizations.of(context)!.nN_1001,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (avatarUrl != null) {
      imageProvider = NetworkImage(avatarUrl!);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0.0, 5),
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  foregroundImage: imageProvider,
                  backgroundColor: AppColors.red,
                  child: const Icon(Icons.perm_identity_rounded, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
                      Text(subtitle1),
                      const SizedBox(height: 5),
                      Text(
                        subtitle2,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: renderMenuList,
                  onSelected: onAction,
                  icon: const Icon(Icons.more_horiz_outlined),
                )
              ],
            ),
            if (skills.isNotEmpty) ...[
              const SizedBox(height: 5),
              // "Builder Skills"
              Text(
                AppLocalizations.of(context)!.nN_1002,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 5),
              Wrap(
                direction: Axis.horizontal,
                children: skills
                    .map((skill) => Container(
                          decoration: const ShapeDecoration(
                            color: Colors.black12,
                            shape: StadiumBorder(),
                          ),
                          margin: const EdgeInsets.only(right: 5),
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Text(skill),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StandaloneContractorAddBuilderFormView extends StatelessWidget {
  const StandaloneContractorAddBuilderFormView({
    super.key,
    required this.controller,
    required this.builder,
    this.onDone,
  });

  final CrewMemberFormController controller;
  final BuilderDto builder;
  final Function()? onDone;

  handleSaveBuilder() async {
    if (controller.validate()) {
      try {
        locate<ProgressIndicatorController>().show();
        var [firstName, secondName, lastName] = controller.value.nameParts;
        await locate<RestService>().createCrewMember(
          builder.id!,
          CrewMemberDto.fromJson(
            {
              "firstName": firstName,
              "secondName": secondName,
              "lastName": lastName,
              "nicNumber": controller.value.nic,
              "contactNumber": controller.value.mobile,
            },
          ),
        );
        if (onDone != null) onDone!();
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Member Added",
            subtitle: "Crew member added successfully",
            color: Colors.green,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } on ConflictedUserException {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Builder already exists",
            subtitle: "Sorry, Builder already exists",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } on Exception {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Something went wrong",
            subtitle: "Sorry, something went wrong here",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } finally {
        locate<ProgressIndicatorController>().hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Text(
                    // "Add Team Member",
                    AppLocalizations.of(context)!.nN_1003,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                FilledButton(
                  onPressed: handleSaveBuilder,
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                  child: Text(AppLocalizations.of(context)!.nN_272),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CrewMemberForm(
                controller: controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StandaloneContractorEditBuilderFormView extends StatelessWidget {
  const StandaloneContractorEditBuilderFormView({
    super.key,
    required this.controller,
    required this.builder,
    required this.member,
    this.onDone,
  });

  final CrewMemberFormController controller;
  final BuilderDto builder;
  final CrewMemberDto member;
  final Function()? onDone;

  handleSaveBuilder() async {
    if (controller.validate()) {
      try {
        locate<ProgressIndicatorController>().show();
        var [firstName, secondName, lastName] = controller.value.nameParts;
        await locate<RestService>().updateCrewMember(
          builder.id!,
          member.copyWith(
            firstName: firstName,
            secondName: secondName,
            lastName: lastName,
            nicNumber: controller.value.nic,
            contactNumber: controller.value.mobile,
          ),
        );
        if (onDone != null) onDone!();
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Member updated",
            subtitle: "Crew member updated successfully",
            color: Colors.green,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } on ConflictedUserException {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Builder already exists",
            subtitle: "Sorry, Builder already exists",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } on Exception {
        locate<PopupController>().addItemFor(
          DismissiblePopup(
            title: "Something went wrong",
            subtitle: "Sorry, something went wrong here",
            color: Colors.red,
            onDismiss: (self) => locate<PopupController>().removeItem(self),
          ),
          const Duration(seconds: 5),
        );
      } finally {
        locate<ProgressIndicatorController>().hide();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Text(
                    // "Edit Team Member",
                    AppLocalizations.of(context)!.nN_1004,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                FilledButton(
                  onPressed: handleSaveBuilder,
                  style: const ButtonStyle(visualDensity: VisualDensity.compact),
                  // "Save"
                  child: Text(AppLocalizations.of(context)!.nN_1005),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CrewMemberForm(
                controller: controller,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CrewMemberFormValue {
  String? name;
  String? mobile;
  String? nic;
  Map<String, String> errors = {};

  static String? countryCode = "+94";

  String? getError(String key) => errors[key];

  CrewMemberFormValue();
  CrewMemberFormValue.empty()
      : name = "",
        mobile = "",
        nic = "";

  copyWith({String? name, String? mobile, String? nic}) {
    return CrewMemberFormValue()
      ..name = name ?? this.name
      ..mobile = mobile ?? this.mobile
      ..nic = nic ?? this.nic;
  }

  List<String?> get nameParts {
    var parts = (name ?? '').replaceAll(RegExp(r'\s+'), ' ').split(' ');
    return List.generate(3, (index) => parts.length > index ? parts[index] : null);
  }

  /// With country code
  get fullMobile => "$countryCode$mobile";
}

class CrewMemberFormController extends FormController<CrewMemberFormValue> {
  CrewMemberFormController({required super.initialValue});

  bool validateSync() {
    value.errors.clear();

    if (StringValidators.isEmpty(value.name) || value.name == null) {
      value.errors.addAll({"name": "Builder name cannot be empty"});
    } else {
      try {
        StringValidators.isPureWithSingleWhiteSpace(value.name!);
      } on ArgumentError catch (_) {
        value.errors.addAll({"name": "Numbers and special characters are not allowed as the name"});
      }

      final [fName, mName, lName] = value.nameParts;

      if (fName == null) {
        value.errors.addAll({"name": "Fist name is requires"});
      } else {
        if (mName == null) {
          value.errors.addAll({"name": "Middle name is requires"});
        } else {
          if (lName == null) {
            value.errors.addAll({"name": "Last name is requires"});
          }
        }
      }
    }

    if (StringValidators.isEmpty(value.mobile)) {
      value.errors.addAll({"mobile": "Mobile number is required"});
    } else {
      try {
        /// Validating with the +94 prefix
        StringValidators.mobile(value.fullMobile);
      } on ArgumentError catch (err) {
        value.errors.addAll({"mobile": err.message});
      }
    }

    if (StringValidators.isEmpty(value.nic)) {
      value.errors.addAll({"nic": "NIC number is required"});
    } else {
      try {
        StringValidators.nic(value.nic!);
      } on ArgumentError catch (err) {
        value.errors.addAll({"nic": err.message});
      }
    }

    setValue(value);
    return value.errors.isEmpty;
  }

  @override
  bool validate() {
    return validateSync();
  }
}

class CrewMemberForm extends StatefulFormWidget {
  const CrewMemberForm({super.key, required super.controller});

  @override
  State<CrewMemberForm> createState() => _CrewMemberFormState();
}

class _CrewMemberFormState extends State<CrewMemberForm> with FormMixin {
  late TextEditingController nameTextEditingController;
  late TextEditingController mobileTextEditingController;
  late TextEditingController nicTextEditingController;

  @override
  void init() {
    nameTextEditingController = TextEditingController(text: controller.value.name);
    mobileTextEditingController = TextEditingController(text: controller.value.mobile);
    nicTextEditingController = TextEditingController(text: controller.value.nic);
    super.init();
  }

  @override
  void handleFormControllerEvent() {
    try {
      final value = controller.value;
      nameTextEditingController.value = nameTextEditingController.value.copyWith(text: value.name ?? "");
      mobileTextEditingController.value = mobileTextEditingController.value.copyWith(text: value.mobile ?? "");
      nicTextEditingController.value = nicTextEditingController.value.copyWith(text: value.nic ?? "");
    } on Exception {
      super.handleFormControllerEvent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, formValue, _) {
        return Column(
          children: [
            TextField(
              controller: nameTextEditingController,
              decoration: InputDecoration(
                // hintText: "Builder Name",
                hintText: AppLocalizations.of(context)!.nN_1006,
                label: Text(AppLocalizations.of(context)!.nN_1006),
                errorText: formValue.getError("name"),
              ),
              onChanged: (value) {
                controller.setValue(
                  controller.value..name = value,
                );
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: mobileTextEditingController,
              keyboardType: TextInputType.phone,
              maxLength: 9,
              decoration: InputDecoration(
                prefix: const Text("+94 "),
                // hintText: "Builder Mobile Number",
                hintText: AppLocalizations.of(context)!.nN_1007,
                label: Text(AppLocalizations.of(context)!.nN_1007),
                errorText: formValue.getError("mobile"),
              ),
              onChanged: (value) => controller.setValue(
                controller.value..mobile = value,
              ),
            ),
            TextField(
              controller: nicTextEditingController,
              decoration: InputDecoration(
                // hintText: "Builder NIC Number",
                hintText: AppLocalizations.of(context)!.nN_1008,
                label: Text(AppLocalizations.of(context)!.nN_1008),
                errorText: formValue.getError("nic"),
              ),
              onChanged: (value) {
                controller.setValue(
                  controller.value..nic = value,
                );
              },
            ),
          ],
        );
      },
    );
  }

  CrewMemberFormController get controller => widget.controller as CrewMemberFormController;
}
