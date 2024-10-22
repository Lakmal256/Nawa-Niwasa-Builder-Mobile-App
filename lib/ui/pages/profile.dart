import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:insee_builder/ui/indicators.dart';
import 'package:intl/intl.dart';
import 'package:pinput/pinput.dart';

import '../../localizations.dart';
import '../../locator.dart';
import '../../service/service.dart';
import '../../ui/ui.dart';
import '../../util/util.dart';
import '../popup.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late Future<bool> action;
  ProfileEditorFormController? controller;

  @override
  void initState() {
    action = initiateController();
    super.initState();
  }

  Future<bool> initiateController() async {
    final mobile = locate<BuilderService>().value?.contactNumber;
    final builder = await locate<RestService>().getBuilderByMobile(mobile!);
    if (builder == null) throw Exception();

    if (controller == null) {
      controller = ProfileEditorFormController(initialValue: builder);
    } else {
      await controller!.fetchAndUpdate();
    }
    return true;
  }

  handleProfileEdit(BuildContext context, BuilderDto? profileData) {
    if (profileData != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileEditor(
            controller: controller!,
            onDone: (_) => Navigator.of(context).pop,
            onError: (_) {},
          ),
        ),
      );
    }
  }

  handleManageCrew(BuildContext context) async {
    if (controller != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ContractorTeamView(builder: controller!.value),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double avatarRadius = 45;
    double avatarBorderSize = 5;
    double backdropOffsetY = (avatarRadius + avatarBorderSize) + 10;

    return Scaffold(
      backgroundColor: Colors.white,
      body: PageActionHandler(
        action: action,
        progressBuilder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // "An error was occurred"
                Text(AppLocalizations.of(context)!.nN_1034, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(error.toString(), textAlign: TextAlign.center),
                TextButton(
                  onPressed: () {
                    setState(() {
                      action = initiateController();
                    });
                  },
                  // "Try Again"
                  child: Text(AppLocalizations.of(context)!.nN_1035),
                ),
              ],
            ),
          );
        },
        builder: (context, _) {
          return ValueListenableBuilder(
            valueListenable: controller!,
            builder: (context, data, child) {
              double rating = data.rating ?? 0.0;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.nN_258,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              action = initiateController();
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                        FilledButton(
                          onPressed: () => handleProfileEdit(context, data),
                          style: const ButtonStyle(visualDensity: VisualDensity.compact),
                          // "Edit"
                          child: Text(AppLocalizations.of(context)!.nN_1000),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Profile header
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Column(
                                children: [
                                  AspectRatio(
                                    aspectRatio: 2.78,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black12,
                                      ),
                                      child: Image.asset(
                                        "assets/images/profile_cover_bg.png",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: backdropOffsetY),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AvatarWithBorder(
                                      borderSize: avatarBorderSize,
                                      avatarRadius: avatarRadius,
                                      image: data.profileImageUrl != null ? NetworkImage(data.profileImageUrl!) : null,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: backdropOffsetY),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data.fullNameLong,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(fontWeight: FontWeight.w600),
                                                  ),
                                                  AvailabilityIndicator(
                                                    type: data.status == "ACTIVE"
                                                        ? AvailabilityType.available
                                                        : AvailabilityType.notAvailable,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                                // "Jobs: ${data.jobCount}",
                                                AppLocalizations.of(context)!.nN_1036(data.jobCount),
                                                style: Theme.of(context).textTheme.labelLarge),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Center(
                              child: Text(
                                // "Job description not found"
                                data.jobDescription ?? AppLocalizations.of(context)!.nN_1037,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          const Divider(thickness: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${AppLocalizations.of(context)!.nN_268} :",
                                      style: Theme.of(context).textTheme.labelLarge,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Wrap(
                                        spacing: 5,
                                        runSpacing: 5,
                                        children: data.primarySkills
                                            .map(
                                              (item) => TextLabel(text: item),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      "${AppLocalizations.of(context)!.nN_260} :",
                                      style: Theme.of(context).textTheme.labelLarge,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Row(
                                        children: List.generate(
                                          5,
                                          (index) {
                                            if (index < rating.floor()) {
                                              return const Icon(Icons.star, color: Color(0xFFDFB300), size: 16);
                                            } else if (index == rating.floor() && rating % 1 != 0) {
                                              return const Icon(Icons.star_half, color: Color(0xFFDFB300), size: 16);
                                            } else {
                                              return const Icon(Icons.star, color: Color(0xFF50555C), size: 16);
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.local_phone_outlined),
                                    const SizedBox(width: 10),
                                    Text(data.contactNumber ?? "N/A"),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      "${AppLocalizations.of(context)!.nN_261} :",
                                      style: Theme.of(context).textTheme.labelLarge,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(data.availability ?? "N/A"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const Divider(thickness: 1),
                          if (controller?.value.type == BuilderType.contractor) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: FilledButton(
                                onPressed: () => handleManageCrew(context),
                                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                                // "Manage Crew"
                                child: Text(AppLocalizations.of(context)!.nN_1038),
                              ),
                            ),
                            const Divider(thickness: 1),
                          ],
                          AspectRatio(
                            aspectRatio: 2,
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: controller?.value.displayBuilderWorkImageUrls.length ?? 0,
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              itemBuilder: (_, index) => Image.network(
                                (controller?.value.displayBuilderWorkImageUrls ?? [])[index],
                              ),
                              separatorBuilder: (_, index) => const SizedBox(width: 10),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // const Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: 15),
                          //   child: UserDeactivateButton(),
                          // ),
                          // const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class AvatarWithBorder extends StatelessWidget {
  const AvatarWithBorder({
    super.key,
    required this.borderSize,
    required this.avatarRadius,
    required this.image,
  });

  final double borderSize;
  final double avatarRadius;
  final ImageProvider? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(borderSize),
      decoration: const ShapeDecoration(
        shape: CircleBorder(),
        color: Colors.white,
      ),
      child: CircleAvatar(
        radius: avatarRadius + borderSize,
        backgroundColor: Colors.black26,
        backgroundImage: image,
      ),
    );
  }
}

enum AvailabilityType { available, notAvailable }

class AvailabilityIndicator extends StatelessWidget {
  const AvailabilityIndicator({super.key, required this.type});

  final AvailabilityType type;

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (type) {
      case AvailabilityType.available:
        {
          color = const Color(0xFF12B418);
          text = "AVAILABLE";
          break;
        }
      case AvailabilityType.notAvailable:
        {
          color = Colors.red;
          text = "NOT AVAILABLE";
          break;
        }
    }

    return Row(
      children: [
        Container(
          height: 10,
          width: 10,
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            color: color,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

/// Profile Editor

class ProfileEditor extends StatelessWidget {
  const ProfileEditor({
    super.key,
    required this.onDone,
    required this.onError,
    required this.controller,
  });

  final ProfileEditorFormController controller;
  final Function(BuilderDto builder) onDone;
  final Function(Error error) onError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ProfileEditorForm(
        controller: controller,
      ),
    );
  }
}

class ProfileEditorFormController extends FormController<BuilderDto> {
  ProfileEditorFormController({required super.initialValue});

  Future fetchAndUpdate() async {
    final data = await locate<RestService>().getBuilderByMobile(value.contactNumber!);
    if (data != null) {
      value = data;
      notifyListeners();
    }
  }
}

enum ProfileItem {
  name,
  contactNumber,
  location,
  nvq,
  sSkills,
  images,
  availability,
  description,
}

class ProfileEditorForm extends StatefulFormWidget<BuilderDto> {
  const ProfileEditorForm({super.key, required super.controller});

  @override
  State<ProfileEditorForm> createState() => _ProfileEditorFormState();
}

class _ProfileEditorFormState extends State<ProfileEditorForm> with FormMixin {
  renderItem(
    BuildContext context, {
    required String fieldName,
    required String value,
    required Function() onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: "$fieldName : ",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: value,
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_right_rounded),
              ],
            ),
          ),
        ),
        const Divider(thickness: 1),
      ],
    );
  }

  handleRequestException() {
    locate<PopupController>().addItemFor(
      DismissiblePopup(
        title: "Something went wrong",
        subtitle: "Sorry, something went wrong here",
        color: Colors.red,
        onDismiss: (self) => locate<PopupController>().removeItem(self),
      ),
      const Duration(seconds: 5),
    );
  }

  handleProfileUpdateRequest(BuilderDto updatedValue) async {
    try {
      locate<ProgressIndicatorController>().show();
      await locate<RestService>().createBuilderProfileChangeRequest(updatedValue);
      (widget.controller as ProfileEditorFormController).fetchAndUpdate();
      locate<ProgressIndicatorController>().hide();
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Profile Change requested",
          subtitle: "The change request was created successfully",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } on PendingApprovalException catch (error) {
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Pending Approval",
          subtitle: error.message,
          color: Colors.red,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } catch (_) {
      handleRequestException();
    } finally {
      locate<ProgressIndicatorController>().hide();
    }
  }

  handleDescriptionFormOnDone(BuilderDto updatedValue) async {
    try {
      locate<ProgressIndicatorController>().show();
      await locate<RestService>().createBuilderProfileChangeRequest(updatedValue);
      locate<ProgressIndicatorController>().hide();
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Description Changed",
          subtitle: "The profile description has been changed",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } on Exception {
      handleRequestException();
    } finally {
      locate<ProgressIndicatorController>().hide();
    }
  }

  handleAvailabilityFormOnDone(BuilderDto updatedValue) async {
    try {
      locate<ProgressIndicatorController>().show();
      await locate<RestService>().createBuilderProfileChangeRequest(updatedValue);
      locate<ProgressIndicatorController>().hide();
      locate<PopupController>().addItemFor(
        DismissiblePopup(
          title: "Call Availability Changed",
          subtitle: "The call availability has been changed",
          color: Colors.green,
          onDismiss: (self) => locate<PopupController>().removeItem(self),
        ),
        const Duration(seconds: 5),
      );
    } on Exception {
      handleRequestException();
    } finally {
      locate<ProgressIndicatorController>().hide();
    }
  }

  handleProfileImageChange() async {
    try {
      Source? source = await showSourceSelector(context);
      if (source == null) return;

      File? file = await pickFile(source, extensions: ["jpg", "jpeg", "png"]);
      if (file == null) return;

      locate<ProgressIndicatorController>().show();
      final bytes = await file.readAsBytes();
      final base64EncodedFile = base64Encode(bytes);
      final result = await locate<RestService>().uploadBase64EncodeAsync(
        "data:image/png;base64,$base64EncodedFile",
      );
      await handleProfileUpdateRequest(
        widget.controller.value.copyWith(profileImage: result),
      );
    } catch (_) {
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

  handleItemSelect(BuildContext context, ProfileItem key) async {
    handleFormOnDone(BuilderDto updatedValue) async {
      try {
        await handleProfileUpdateRequest(updatedValue);
        if (context.mounted) Navigator.of(context).pop();
      } catch (err) {
        return;
      }
    }

    switch (key) {
      case ProfileItem.description:
        {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Material(
                child: DescriptionForm(
                  initialValue: widget.controller.value,
                  onDone: handleDescriptionFormOnDone,
                ),
              ),
            ),
          );
          break;
        }
      case ProfileItem.name:
        {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Material(
                child: NameEditorForm(
                  initialValue: widget.controller.value,
                  onDone: handleFormOnDone,
                ),
              ),
            ),
          );
          break;
        }
      case ProfileItem.contactNumber:
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Material(
                child: MobileEditorForm(
                  initialValue: widget.controller.value,
                  onDone: handleFormOnDone,
                ),
              ),
            ),
          );
          break;
        }
      case ProfileItem.location:
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Material(
                child: LocationEditorForm(
                  initialValue: widget.controller.value,
                  onDone: handleFormOnDone,
                ),
              ),
            ),
          );
          break;
        }
      case ProfileItem.nvq:
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Material(
                child: NVQsEditorForm(
                  initialValue: widget.controller.value,
                  onDone: handleFormOnDone,
                ),
              ),
            ),
          );
          break;
        }
      case ProfileItem.sSkills:
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Material(
                child: SkillsEditorForm(
                  initialValue: widget.controller.value,
                  onDone: handleFormOnDone,
                ),
              ),
            ),
          );
          break;
        }
      case ProfileItem.images:
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Material(
                child: MyImageEditorForm(
                  initialValue: widget.controller.value,
                  onDone: handleFormOnDone,
                ),
              ),
            ),
          );
          break;
          // MyImageEditorForm
        }
      case ProfileItem.availability:
        {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => Material(
                child: AvailabilityTimeframeForm(
                  initialValue: widget.controller.value,
                  onDone: handleAvailabilityFormOnDone,
                ),
              ),
            ),
          );
          break;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ProfileHeaderWidget(title: AppLocalizations.of(context)!.nN_258),
        ),
        ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, data, child) {
            return Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      fit: StackFit.loose,
                      alignment: Alignment.bottomRight,
                      children: [
                        AvatarWithBorder(
                          borderSize: 5,
                          avatarRadius: 50,
                          image: data.profileImageUrl != null ? NetworkImage(data.profileImageUrl!) : null,
                        ),
                        GestureDetector(
                          onTap: handleProfileImageChange,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const ShapeDecoration(
                              shape: CircleBorder(),
                              color: Colors.white,
                              shadows: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.mode_edit_outline_outlined,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    renderItem(
                      context,
                      fieldName: AppLocalizations.of(context)!.nN_249,
                      onSelect: () => handleItemSelect(context, ProfileItem.description),
                      value: data.jobDescription ?? "",
                    ),
                    renderItem(
                      context,
                      // fieldName: "Name",
                      fieldName: AppLocalizations.of(context)!.nN_1039,
                      onSelect: () => handleItemSelect(context, ProfileItem.name),
                      value: data.fullNameLong,
                    ),
                    renderItem(
                      context,
                      // fieldName: "Contact Number",
                      fieldName: AppLocalizations.of(context)!.nN_1040,
                      onSelect: () => handleItemSelect(context, ProfileItem.contactNumber),
                      value: data.contactNumber ?? "N/A",
                    ),
                    renderItem(
                      context,
                      fieldName: AppLocalizations.of(context)!.nN_262,
                      onSelect: () => handleItemSelect(context, ProfileItem.location),
                      value: data.preferredLocation ?? "N/A",
                    ),
                    renderItem(context,
                        fieldName: AppLocalizations.of(context)!.nN_251,
                        onSelect: () => handleItemSelect(context, ProfileItem.nvq),
                        // value: data.nvqQualifications.length.toString(),
                        value: data.nvqQualifications.isNotEmpty
                            ? data.nvqQualifications.reduce((value, element) => "$value, $element")
                            : "N/A"),
                    renderItem(
                      context,
                      fieldName: AppLocalizations.of(context)!.nN_268,
                      onSelect: () => handleItemSelect(context, ProfileItem.sSkills),
                      value: data.primarySkills.isNotEmpty
                          ? data.primarySkills.reduce((value, element) => "$value, $element")
                          : "N/A",
                    ),
                    renderItem(
                      context,
                      fieldName: AppLocalizations.of(context)!.nN_263,
                      onSelect: () => handleItemSelect(context, ProfileItem.images),
                      value: data.builderWorkImageUrls.length.toString(),
                    ),
                    renderItem(
                      context,
                      fieldName: AppLocalizations.of(context)!.nN_261,
                      onSelect: () => handleItemSelect(context, ProfileItem.availability),
                      value: data.availability ?? "N/A",
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: GoRouter.of(context).pop,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}

/// Profile filed editor forms

// class ProfileFiledForm<T> {
//   final T initialValue;
//   final Function() onDone;
//
//   ProfileFiledForm({
//     required this.initialValue,
//     required this.onDone,
//   });
// }

class ProfileFiled extends StatelessWidget {
  const ProfileFiled({
    super.key,
    required this.child,
    required this.name,
  });

  final String name;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

class NameEditorForm extends StatelessWidget {
  NameEditorForm({
    super.key,
    required BuilderDto initialValue,
    required this.onDone,
  })  : value = initialValue,
        firstNameFieldController = TextEditingController(text: initialValue.firstName),
        secondNameFieldController = TextEditingController(text: initialValue.secondName),
        lastNameFieldController = TextEditingController(text: initialValue.lastName);

  final BuilderDto value;

  final Function(BuilderDto value) onDone;

  final TextEditingController firstNameFieldController;
  final TextEditingController secondNameFieldController;
  final TextEditingController lastNameFieldController;
  final PageAlertController pageAlertController = PageAlertController();

  handleSubmit() {
    pageAlertController.clear();
    final errors = List<String>.empty(growable: true);

    final firstName = firstNameFieldController.text;
    if (StringValidators.isEmpty(firstName)) {
      errors.add("First name cannot be empty");
    } else {
      if (firstName.length < 5) {
        errors.add("Fist name length must be at least 5 characters long");
      } else if (firstName.length > 100) {
        errors.add("Fist name length must be less than or equal to 100 characters");
      }
      try {
        StringValidators.isPure(firstName);
      } on ArgumentError catch (_) {
        errors.add("Numbers and special characters are not allowed as the first name");
      }
    }

    /// Second name can be empty
    final secondName = secondNameFieldController.text;
    if (!StringValidators.isEmpty(secondName)) {
      if (secondName.length < 5) {
        errors.add("Second name length must be at least 5 characters long");
      } else if (secondName.length > 100) {
        errors.add("Second name length must be less than or equal to 100 characters");
      }
      try {
        StringValidators.isPure(secondName);
      } on ArgumentError catch (_) {
        errors.add("Numbers and special characters are not allowed as the second name");
      }
    }

    final lastName = lastNameFieldController.text;
    if (StringValidators.isEmpty(lastName)) {
      errors.add("Last name cannot be empty");
    } else {
      if (lastName.length < 5) {
        errors.add("Last name length must be at least 5 characters long");
      } else if (lastName.length > 100) {
        errors.add("Last name length must be less than or equal to 100 characters");
      }
      try {
        StringValidators.isPure(lastName);
      } on ArgumentError catch (_) {
        errors.add("Numbers and special characters are not allowed as the last name");
      }
    }

    pageAlertController.addAll(errors
        .map((error) => PageAlert(
              error,
              type: AlertType.error,
            ))
        .toList());

    if (errors.isNotEmpty) return;

    onDone(
      value.copyWith(
        firstName: firstNameFieldController.text,
        secondName: secondNameFieldController.text,
        lastName: lastNameFieldController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            // "Edit Name"
            child: ProfileHeaderWidget(title: AppLocalizations.of(context)!.nN_1041),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      child: Text(
                        // "Change the name that you want to appear as your user name.",
                        AppLocalizations.of(context)!.nN_1042,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    PageAlertContainer(
                      controller: pageAlertController,
                    ),
                    ProfileFiled(
                      // name: "First Name",
                      name: AppLocalizations.of(context)!.nN_1043,
                      child: TextField(
                        controller: firstNameFieldController,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ProfileFiled(
                      // name: "Second Name",
                      name: AppLocalizations.of(context)!.nN_1044,
                      child: TextField(
                        controller: secondNameFieldController,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ProfileFiled(
                      // name: "Last Name",
                      name: AppLocalizations.of(context)!.nN_1045,
                      child: TextField(
                        controller: lastNameFieldController,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: FilledButton(
              onPressed: handleSubmit,
              style: ButtonStyle(
                visualDensity: VisualDensity.standard,
                minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                backgroundColor: MaterialStateProperty.all(AppColors.red),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
              // "Submit"
              child: Text(AppLocalizations.of(context)!.nN_1046),
            ),
          )
        ],
      ),
    );
  }
}

class MobileEditorForm extends StatelessWidget {
  MobileEditorForm({
    super.key,
    required BuilderDto initialValue,
    required this.onDone,
  })  : value = initialValue,
        numberFieldController = TextEditingController(text: initialValue.contactNumber);

  final BuilderDto value;

  final Function(BuilderDto value) onDone;

  final TextEditingController numberFieldController;
  final PageAlertController pageAlertController = PageAlertController();

  handleSubmit() {
    pageAlertController.clear();
    final errors = List<String>.empty(growable: true);

    final number = numberFieldController.text;
    if (StringValidators.isEmpty(number)) {
      errors.add("Contact number cannot be empty");
    } else {
      try {
        StringValidators.mobile(number);
      } on ArgumentError catch (error) {
        errors.add(error.message);
      }
    }

    pageAlertController.addAll(errors
        .map((error) => PageAlert(
              error,
              type: AlertType.error,
            ))
        .toList());

    if (errors.isNotEmpty) return;

    onDone(
      value.copyWith(contactNumber: numberFieldController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ProfileHeaderWidget(
              // title: "Edit Contact Number",
              title: AppLocalizations.of(context)!.nN_1047,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: Text(
                      // "Change the number you want to appear for customer’s to contact you.",
                      AppLocalizations.of(context)!.nN_1048,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  PageAlertContainer(
                    controller: pageAlertController,
                  ),
                  ProfileFiled(
                    // name: "Contact Number",
                    name: AppLocalizations.of(context)!.nN_1040,
                    child: TextField(
                      controller: numberFieldController,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: FilledButton(
              onPressed: handleSubmit,
              style: ButtonStyle(
                visualDensity: VisualDensity.standard,
                minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                backgroundColor: MaterialStateProperty.all(AppColors.red),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
              // "Submit"
              child: Text(AppLocalizations.of(context)!.nN_1046),
            ),
          )
        ],
      ),
    );
  }
}

class LocationEditorForm extends StatelessWidget {
  LocationEditorForm({
    super.key,
    required BuilderDto initialValue,
    required this.onDone,
  })  : value = initialValue,
        locationFieldController = TextEditingController(text: initialValue.preferredLocation);

  final BuilderDto value;

  final Function(BuilderDto value) onDone;

  final TextEditingController locationFieldController;
  final PageAlertController pageAlertController = PageAlertController();

  handleSubmit() {
    pageAlertController.clear();
    final errors = List<String>.empty(growable: true);

    final location = locationFieldController.text;
    if (StringValidators.isEmpty(location)) {
      errors.add("Location cannot be empty");
    }

    pageAlertController.addAll(errors
        .map((error) => PageAlert(
              error,
              type: AlertType.error,
            ))
        .toList());

    if (errors.isNotEmpty) return;

    onDone(
      value.copyWith(preferredLocation: locationFieldController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ProfileHeaderWidget(
              // title: "Edit Location",
              title: AppLocalizations.of(context)!.nN_1049,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: Text(
                      // "Change your preferred location",
                      AppLocalizations.of(context)!.nN_1050,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  PageAlertContainer(
                    controller: pageAlertController,
                  ),
                  ProfileFiled(
                    // name: "Location",
                    name: AppLocalizations.of(context)!.nN_1051,
                    child: TextField(
                      controller: locationFieldController,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: FilledButton(
              onPressed: handleSubmit,
              style: ButtonStyle(
                visualDensity: VisualDensity.standard,
                minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                backgroundColor: MaterialStateProperty.all(AppColors.red),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                ),
              ),
              // "Submit"
              child: Text(AppLocalizations.of(context)!.nN_1046),
            ),
          )
        ],
      ),
    );
  }
}

class NVQsEditorForm extends StatefulWidget {
  const NVQsEditorForm({
    super.key,
    required BuilderDto initialValue,
    required this.onDone,
  }) : value = initialValue;

  final BuilderDto value;

  final Function(BuilderDto value) onDone;

  @override
  State<NVQsEditorForm> createState() => _NVQsEditorFormState();
}

class _NVQsEditorFormState extends State<NVQsEditorForm> {
  List<String> nvqs = [];

  late Future<List<NvqLevelDto>?> action;

  @override
  void initState() {
    nvqs = List.from(widget.value.nvqQualifications);
    action = fetchNvqLevels();
    super.initState();
  }

  fetchNvqLevels() {
    return locate<RestService>().getAllNvqLevels();
  }

  handleNvqSelectFromAllList(String item) {
    nvqs.add(item);
    setState(() {
      nvqs = nvqs;
    });
  }

  handleNvqSelectFromMyList(String item) {
    setState(() {
      nvqs = nvqs.where((value) => value != item).toList();
    });
  }

  handleSubmit() {
    widget.onDone(
      widget.value.copyWith(nvqQualifications: nvqs),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageActionHandler<List<NvqLevelDto>?>(
        action: action,
        progressBuilder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    // An error was occurred
                    AppLocalizations.of(context)!.nN_1052,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(error.toString(), textAlign: TextAlign.center),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        action = fetchNvqLevels();
                      });
                    },
                    // "Try Again"
                    child: Text(AppLocalizations.of(context)!.nN_1053),
                  ),
                ],
              ),
            ),
          );
        },
        builder: (context, data) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: ProfileHeaderWidget(
                  // title: "Edit NVQ Certifications",
                  title: AppLocalizations.of(context)!.nN_1054,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        child: Text(
                          AppLocalizations.of(context)!.nN_264,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // "All NVQ Levels",
                              AppLocalizations.of(context)!.nN_1055,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: 10,
                              runSpacing: 5,
                              children: (data ?? [])
                                  .map((item) => item.name)
                                  .where((item) => !nvqs.contains(item))
                                  .map(
                                    (item) => GestureDetector(
                                      onTap: () => handleNvqSelectFromAllList(item),
                                      child: TextLabel(text: item!),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Icon(Icons.swap_vert_rounded),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // "My NVQ Levels",
                              AppLocalizations.of(context)!.nN_1056,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: 10,
                              runSpacing: 5,
                              children: nvqs
                                  .map(
                                    (item) => TextLabel(
                                      text: item,
                                      onClose: () => handleNvqSelectFromMyList(item),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: FilledButton(
                  onPressed: handleSubmit,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.standard,
                    minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                    backgroundColor: MaterialStateProperty.all(AppColors.red),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                  // "Submit"
                  child: Text(AppLocalizations.of(context)!.nN_1046),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class SkillsEditorForm extends StatefulWidget {
  const SkillsEditorForm({
    super.key,
    required BuilderDto initialValue,
    required this.onDone,
  }) : value = initialValue;

  final BuilderDto value;

  final Function(BuilderDto value) onDone;

  @override
  State<SkillsEditorForm> createState() => _SkillsEditorFormState();
}

class _SkillsEditorFormState extends State<SkillsEditorForm> {
  List<String> skills = [];

  late Future<List<SkillDto>?> action;

  @override
  void initState() {
    skills = List.from(widget.value.primarySkills);
    action = fetchAllSkills();
    super.initState();
  }

  fetchAllSkills() {
    return locate<RestService>().getAllSkills();
  }

  handleSkillSelectFromAllList(String item) {
    skills.add(item);
    setState(() {
      skills = skills;
    });
  }

  handleSkillSelectFromMyList(String item) {
    setState(() {
      skills = skills.where((value) => value != item).toList();
    });
  }

  handleSubmit() {
    widget.onDone(
      widget.value.copyWith(primarySkills: skills),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageActionHandler<List<SkillDto>?>(
        action: action,
        progressBuilder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    // "An error was occurred",
                    AppLocalizations.of(context)!.nN_1052,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(error.toString(), textAlign: TextAlign.center),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        action = fetchAllSkills();
                      });
                    },
                    // "Try Again"
                    child: Text(AppLocalizations.of(context)!.nN_1053),
                  ),
                ],
              ),
            ),
          );
        },
        builder: (context, data) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: ProfileHeaderWidget(
                  // title: "Edit Secondary Skills",
                  title: AppLocalizations.of(context)!.nN_1057,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 25),
                        child: Text(
                          AppLocalizations.of(context)!.nN_265,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // "All Secondary skills",
                              AppLocalizations.of(context)!.nN_1058,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: 10,
                              runSpacing: 5,
                              children: (data ?? [])
                                  // .where((item) => item.isPrimary)
                                  .map((item) => item.name)
                                  .where((item) => !skills.contains(item))
                                  .map(
                                    (item) => GestureDetector(
                                      onTap: () => handleSkillSelectFromAllList(item),
                                      child: TextLabel(text: item!),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Icon(Icons.swap_vert_rounded),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              // "My Secondary skills",
                              AppLocalizations.of(context)!.nN_1059,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Wrap(
                              direction: Axis.horizontal,
                              spacing: 10,
                              runSpacing: 5,
                              children: skills
                                  .map(
                                    (item) => TextLabel(
                                      text: item,
                                      onClose: () => handleSkillSelectFromMyList(item),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: FilledButton(
                  onPressed: handleSubmit,
                  style: ButtonStyle(
                    visualDensity: VisualDensity.standard,
                    minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
                    backgroundColor: MaterialStateProperty.all(AppColors.red),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                  ),
                  // "Submit"
                  child: Text(AppLocalizations.of(context)!.nN_1046),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class AvailabilityTimeframeForm extends StatefulWidget {
  const AvailabilityTimeframeForm({
    super.key,
    required BuilderDto initialValue,
    required this.onDone,
  }) : value = initialValue;

  final BuilderDto value;

  final Function(BuilderDto value) onDone;

  @override
  State<AvailabilityTimeframeForm> createState() => _AvailabilityTimeframeFormState();
}

class _AvailabilityTimeframeFormState extends State<AvailabilityTimeframeForm> {
  late DateTimeRange timeframe;

  /// Ex: 4.00 AM - 4.00 PM
  DateTimeRange stringToDateTimeRange(String? value) {
    final times = (value ?? "00.00 AM - 00.00 AM").split("-");

    /// Format spaces are important!
    final start = DateFormat('h.mm a ').parse(times[0]);
    final end = DateFormat(' h.mm a').parse(times[1]);

    return DateTimeRange(
      start: DateTime.now().copyWith(hour: start.hour, minute: start.minute),
      end: DateTime.now().copyWith(hour: end.hour, minute: end.minute),
    );
  }

  @override
  void initState() {
    timeframe = stringToDateTimeRange(widget.value.availability);
    super.initState();
  }

  Future<TimeOfDay?> handleTimeSelect(BuildContext context, DateTime time) async {
    final tod = TimeOfDay.fromDateTime(time);
    return await showTimePicker(
      context: context,
      initialTime: tod,
    );
  }

  handleSubmit() {
    widget.onDone(
      widget.value.copyWith(availability: sTimeframe),
    );
  }

  Widget buildTimeSelector(
    BuildContext context, {
    required String title,
    required DateTime time,
    required Function(TimeOfDay value) onChange,
  }) {
    return InkWell(
      onTap: () async {
        final tod = await handleTimeSelect(context, time);
        if (tod == null) return;
        onChange(tod);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1, color: Colors.black26),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black38,
              ),
            ),
            AspectRatio(
              aspectRatio: 3,
              child: FittedBox(
                child: Text(
                  DateFormat.jm().format(time),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ProfileHeaderWidget(
            // title: "Edit Timeframe",
            title: AppLocalizations.of(context)!.nN_1060,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: Text(
                    // "Adjust your availability timeframe by setting the start and end time",
                    AppLocalizations.of(context)!.nN_1061,
                    textAlign: TextAlign.center,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: buildTimeSelector(
                            context,
                            onChange: (time) {
                              final value = timeframe.start.copyWith(
                                hour: time.hour,
                                minute: time.minute,
                              );
                              if (value.isAfter(timeframe.end)) return;
                              setState(
                                () => timeframe = DateTimeRange(
                                  start: value,
                                  end: timeframe.end,
                                ),
                              );
                            },
                            // title: "Start",
                            title: AppLocalizations.of(context)!.nN_1062,
                            time: timeframe.start,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: buildTimeSelector(
                            context,
                            onChange: (time) {
                              final value = timeframe.start.copyWith(
                                hour: time.hour,
                                minute: time.minute,
                              );
                              if (value.isBefore(timeframe.start)) return;
                              setState(
                                () => timeframe = DateTimeRange(
                                  start: timeframe.start,
                                  end: value,
                                ),
                              );
                            },
                            // title: "End",
                            title: AppLocalizations.of(context)!.nN_1063,
                            time: timeframe.end,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: FilledButton(
            onPressed: handleSubmit,
            style: ButtonStyle(
              visualDensity: VisualDensity.standard,
              minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
              backgroundColor: MaterialStateProperty.all(AppColors.red),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            // "Update"
            child: Text(AppLocalizations.of(context)!.nN_1064),
          ),
        )
      ],
    );
  }

  String get sTimeframe =>
      "${DateFormat("h.mm a").format(timeframe.start)} - ${DateFormat("h.mm a").format(timeframe.end)}";
}

class DescriptionForm extends StatefulWidget {
  const DescriptionForm({
    super.key,
    required BuilderDto initialValue,
    required this.onDone,
  }) : value = initialValue;

  final BuilderDto value;

  final Function(BuilderDto value) onDone;

  @override
  State<DescriptionForm> createState() => _DescriptionFormState();
}

class _DescriptionFormState extends State<DescriptionForm> {
  late TextEditingController descriptionEditingController;
  final PageAlertController pageAlertController = PageAlertController();

  @override
  void initState() {
    descriptionEditingController = TextEditingController(text: widget.value.jobDescription);
    super.initState();
  }

  handleSubmit() {
    pageAlertController.clear();
    final errors = List<String>.empty(growable: true);

    final description = descriptionEditingController.text;
    if (StringValidators.isEmpty(description)) {
      errors.add("Description cannot be empty");
    } else if (description.length < 5) {
      errors.add("Description length must be at least 5 characters long");
    } else if (description.length > 250) {
      errors.add("Description length must be less than or equal to 250 characters");
    }

    pageAlertController.addAll(errors
        .map((error) => PageAlert(
              error,
              type: AlertType.error,
            ))
        .toList());

    if (errors.isNotEmpty) return;

    widget.onDone(
      widget.value.copyWith(jobDescription: descriptionEditingController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ProfileHeaderWidget(
            // title: "Edit Job Description",
            title: AppLocalizations.of(context)!.nN_1065,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: Text(
                      // "Change your job description",
                      AppLocalizations.of(context)!.nN_1067,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  PageAlertContainer(
                    controller: pageAlertController,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: descriptionEditingController,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: FilledButton(
            onPressed: handleSubmit,
            style: ButtonStyle(
              visualDensity: VisualDensity.standard,
              minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
              backgroundColor: MaterialStateProperty.all(AppColors.red),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            // "Update"
            child: Text(AppLocalizations.of(context)!.nN_1064),
          ),
        )
      ],
    );
  }
}

class MyImageEditorForm extends StatefulWidget {
  const MyImageEditorForm({
    super.key,
    required BuilderDto initialValue,
    required this.onDone,
  }) : value = initialValue;

  final BuilderDto value;

  final Function(BuilderDto value) onDone;

  @override
  State<MyImageEditorForm> createState() => _MyImageEditorFormState();
}

class _MyImageEditorFormState extends State<MyImageEditorForm> {
  final PageAlertController pageAlertController = PageAlertController();
  final ImageBoxController imageBoxController = ImageBoxController();

  Future? imageFuture;

  Future<List<ImageBoxItem>> _generateDisplayableImageList() async {
    final futures = widget.value.builderWorkImageUrls.map((path) async {
      final displayablePath = await locate<RestService>().getFullFilePath(path);
      return NetworkImageBoxItem(path, url: displayablePath!, data: path);
    });
    final List<ImageBoxItem> displayableImageList = List.empty(growable: true);
    for (var future in futures) {
      displayableImageList.add(await future);
    }
    return displayableImageList;
  }

  initImages() async {
    final images = await _generateDisplayableImageList();
    imageBoxController.addAll(images);
  }

  @override
  initState() {
    imageFuture = initImages();
    super.initState();
  }

  handleSubmit() async {
    locate<ProgressIndicatorController>().show();

    /// Filter out local files
    var localFiles = imageBoxController.value.items.whereType<FileImageBoxItem>().toList();

    /// Try to upload all local files
    try {
      upload(FileImageBoxItem item) async {
        var bytes = await fileToBase64(item.file);
        var pathUrl = await locate<RestService>().uploadBase64EncodeAsync(bytes);
        if (pathUrl == null) return;

        /// Replace with a [NetworkImageBoxItem]
        var fileName = Uri.parse(pathUrl).pathSegments.last;
        final displayImagePath = await locate<RestService>().getFullFilePath(pathUrl);
        imageBoxController.replaceAll(imageBoxController.value.items
            .map((i0) => i0 == item ? NetworkImageBoxItem(fileName, url: displayImagePath!, data: pathUrl) : i0)
            .toList());
      }

      await Future.forEach(localFiles, upload);

      widget.onDone(
        widget.value.copyWith(
          builderWorkImageUrls:
              imageBoxController.value.items.whereType<NetworkImageBoxItem>().map((item) => item.data!).toList(),
        ),
      );
    } catch (err) {
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

  handleFileSelect() async {
    var source = await showSourceSelector(context);
    if (source == null) return;

    final extensions = ["jpg", "jpeg", "png"];
    var file = await pickFile(source, extensions: extensions);
    if (file == null) return;

    var isAlreadyAdded = imageBoxController.value.items.any((item) => item.name == file.name);
    if (isAlreadyAdded) return;

    imageBoxController.addImage(FileImageBoxItem(file.name, file: file));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: imageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }

            return const SizedBox.shrink();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: ProfileHeaderWidget(
            // title: "Edit Images",
            title: AppLocalizations.of(context)!.nN_1068,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.nN_266,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  PageAlertContainer(
                    controller: pageAlertController,
                  ),
                  Text(
                    // "My Images",
                    AppLocalizations.of(context)!.nN_1069,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  FileImageBox(controller: imageBoxController),
                  const SizedBox(height: 10),
                  Text(
                    // "Add Images",
                    AppLocalizations.of(context)!.nN_1070,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: handleFileSelect,
                    style: const ButtonStyle(
                        foregroundColor: MaterialStatePropertyAll(Colors.black),
                        backgroundColor: MaterialStatePropertyAll(Colors.black12)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // "Upload"
                        Text(AppLocalizations.of(context)!.nN_1071),
                        SizedBox(width: 10),
                        Icon(Icons.file_upload_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: FilledButton(
            onPressed: handleSubmit,
            style: ButtonStyle(
              visualDensity: VisualDensity.standard,
              minimumSize: MaterialStateProperty.all(const Size.fromHeight(50)),
              backgroundColor: MaterialStateProperty.all(AppColors.red),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
            ),
            // "Submit"
            child: Text(AppLocalizations.of(context)!.nN_1046),
          ),
        )
      ],
    );
  }
}

class TextLabel extends StatelessWidget {
  const TextLabel({super.key, required this.text, this.onClose});

  final String text;
  final Function()? onClose;

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const ShapeDecoration(
        shape: StadiumBorder(),
        color: Color(0xFF3F3F3F),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
          if (onClose != null)
            const Padding(
              padding: EdgeInsets.only(left: 5),
              child: Icon(
                Icons.clear,
                color: Colors.white,
                size: 12,
              ),
            ),
        ],
      ),
    );

    if (onClose != null) {
      return GestureDetector(
        onTap: onClose,
        child: child,
      );
    }

    return child;
  }
}

/// Page Alerts

enum AlertType { error }

class PageAlert {
  AlertType type;
  final String message;

  PageAlert(this.message, {this.type = AlertType.error});
}

class PageAlertController extends ValueNotifier<List<PageAlert>> {
  PageAlertController({List<PageAlert>? initialValue}) : super(initialValue ?? []);

  PageAlertController add(PageAlert alert) {
    value.add(alert);
    notifyListeners();
    return this;
  }

  PageAlertController addAll(List<PageAlert> alerts) {
    value.addAll(alerts);
    notifyListeners();
    return this;
  }

  PageAlertController clear() {
    value.clear();
    notifyListeners();
    return this;
  }
}

class PageAlertContainer extends StatelessWidget {
  const PageAlertContainer({super.key, required this.controller});

  final PageAlertController controller;

  Widget buildErrorAlert(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.black12,
        ),
        borderRadius: BorderRadius.circular(5),
        // color: Colors.redAccent,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
                // color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, snapshot, child) {
        return ListView(
          shrinkWrap: true,
          children: snapshot
              .map((alert) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: buildErrorAlert(context, alert.message),
                  ))
              .toList(),
        );
      },
    );
  }
}

class UserDeactivateButton extends StatefulWidget {
  const UserDeactivateButton({super.key});

  @override
  State<UserDeactivateButton> createState() => _UserDeactivateButtonState();
}

class _UserDeactivateButtonState extends State<UserDeactivateButton> {
  Future<bool>? action;

  handleAction() async {
    setState(() {
      action = locate<RestService>().deactivateUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FutureBuilder(
          future: action,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }

            return const SizedBox.shrink();
          },
        ),
        Text(
          // "Delete Account",
          AppLocalizations.of(context)!.nN_1072,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          // "This action will delete your account.",
          AppLocalizations.of(context)!.nN_1073,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 15),
        OutlinedButton(
          onPressed: handleAction,
          style: ButtonStyle(
            padding: const MaterialStatePropertyAll(EdgeInsets.symmetric(vertical: 20)),
            visualDensity: VisualDensity.standard,
            // backgroundColor: const MaterialStatePropertyAll(Colors.red),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                side: const BorderSide(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          child: Text(
            // "Delete",
            AppLocalizations.of(context)!.nN_1074,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
