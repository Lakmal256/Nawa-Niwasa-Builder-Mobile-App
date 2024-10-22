import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:insee_builder/locator.dart';
import 'package:insee_builder/router.dart';
import 'package:insee_builder/service/service.dart';

import '../../localizations.dart';
import '../indicators.dart';
import '../ui.dart';

class MainJobView extends StatefulWidget {
  const MainJobView({super.key});

  @override
  State<MainJobView> createState() => _MainJobViewState();
}

class _MainJobViewState extends State<MainJobView> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: TabBar(controller: tabController),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                StandaloneMyJobBoardView(),
                StandalonePublicJobBoardView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TabBar extends StatelessWidget {
  const TabBar({super.key, required this.controller});

  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedBuilder(
          animation: controller,
          builder: (context, snapshot) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TabItem(
                  title: AppLocalizations.of(context)!.nN_273,
                  onSelect: () => controller.animateTo(0),
                  isSelected: controller.index == 0,
                ),
                TabItem(
                  title: AppLocalizations.of(context)!.nN_274,
                  onSelect: () => controller.animateTo(1),
                  isSelected: controller.index == 1,
                ),
              ],
            );
          }),
    );
  }
}

class TabItem extends StatelessWidget {
  const TabItem({
    super.key,
    required this.onSelect,
    required this.isSelected,
    required this.title,
  });

  final Function() onSelect;
  final bool isSelected;
  final String title;

  @override
  Widget build(BuildContext context) {
    Color color = isSelected ? const Color(0xFFEE1C25) : Colors.transparent;
    TextStyle? style = isSelected ? const TextStyle(fontWeight: FontWeight.w600, color: Colors.white) : null;
    Widget child = Text(title, style: style);

    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }
}

/// Private Job views

class StandaloneMyJobBoardView extends StatefulWidget {
  const StandaloneMyJobBoardView({super.key});

  @override
  State<StandaloneMyJobBoardView> createState() => _StandaloneMyJobBoardViewState();
}

class _StandaloneMyJobBoardViewState extends State<StandaloneMyJobBoardView> {
  late Future<List<JobDto>> future;
  late String filterValue;

  @override
  initState() {
    filterValue = "";
    future = fetch();
    super.initState();
  }

  Future refresh() async {
    setState(() {
      future = fetch();
    });
  }

  Future<List<JobDto>> fetch() async {
    var types = await locate<RestService>().getAllJobTypes();
    locate<GlobalJobTypes>().setTypes(types ?? []);
    var id = locate<BuilderService>().value!.id!;
    return locate<RestService>().getAllPrivateJobs(id);
  }

  handleSelect(BuildContext context, JobDto job) {
    showPrivateJobBottomSheet(
      context,
      job: job,
      onAccept: () async {
        try {
          locate<ProgressIndicatorController>().show();
          await locate<RestService>().acceptJob(job.id!);
          refresh();
          if (context.mounted) Navigator.of(context).pop();
        } catch (err) {
          return;
        } finally {
          locate<ProgressIndicatorController>().hide();
        }
      },
      onReject: () async {
        try {
          locate<ProgressIndicatorController>().show();
          await locate<RestService>().rejectJob(job.id!);
          refresh();
          if (context.mounted) Navigator.of(context).pop();
        } catch (err) {
          return;
        } finally {
          locate<ProgressIndicatorController>().hide();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.hasData && snapshot.data!.isEmpty) {
          // "The list is empty"
          return Center(child: Text(AppLocalizations.of(context)!.nN_1012));
        }

        var jobs = (snapshot.data ?? [])
            .where((job) => (job.title?.toLowerCase() ?? "").contains(filterValue.toLowerCase()))
            .toList();

        return MyJobBoardView(
          jobs: jobs,
          onRefresh: refresh,
          onSelect: (job) => handleSelect(context, job),
          onSearchValueChange: (value) => setState(() => filterValue = value),
        );
      },
    );
  }
}

class MyJobBoardView extends StatelessWidget {
  const MyJobBoardView({
    super.key,
    required this.jobs,
    required this.onSelect,
    required this.onSearchValueChange,
    required this.onRefresh,
  });

  final List<JobDto> jobs;
  final Function(JobDto) onSelect;
  final Function(String) onSearchValueChange;
  final Future Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: AppSearchBar(
            onChange: onSearchValueChange,
            // hintText: 'SEARCH MY JOBS',
            hintText: AppLocalizations.of(context)!.nN_1013.toUpperCase(),
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 0, top: 15),
                itemCount: jobs.length,
                shrinkWrap: true,
                separatorBuilder: (context, i) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  var job = jobs[i];
                  var type = locate<GlobalJobTypes>().getJobTypeByName(job.jobType);
                  var icon = type.jobTypeImage == null
                      ? const Icon(Icons.image_not_supported_outlined)
                      : Image.network(type.jobTypeImage!);

                  return PrivateJobCard(
                    customerName: job.customerName ?? "N/A",
                    jobAssignedDate: job.justDate,
                    jobTitle: job.title ?? "N/A",
                    jobLocation: job.location ?? "N/A",
                    statusTag: JobStatusBadge(status: job.status),
                    icon: icon,
                    onSelect: () => onSelect(job),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PrivateJobCard extends StatelessWidget {
  const PrivateJobCard({
    super.key,
    required this.customerName,
    required this.jobTitle,
    required this.jobLocation,
    required this.jobAssignedDate,
    required this.statusTag,
    required this.icon,
    required this.onSelect,
  });

  final String customerName;
  final String jobTitle;
  final String jobLocation;
  final String jobAssignedDate;
  final Widget statusTag;
  final Widget icon;
  final Function() onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xF0F0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // "Customer name : $customerName",
              AppLocalizations.of(context)!.nN_1014(customerName),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Flexible(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // "Job : $jobTitle",
                        AppLocalizations.of(context)!.nN_1015(jobTitle),
                        style: const TextStyle(color: AppColors.red),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        // "Location : $jobLocation",
                        AppLocalizations.of(context)!.nN_1016(jobLocation),
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            // "Status : ",
                            AppLocalizations.of(context)!.nN_1017,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          statusTag
                        ],
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: icon,
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              // "Assign Date
              children: [Text(AppLocalizations.of(context)!.nN_1018(jobAssignedDate))],
            ),
          ],
        ),
      ),
    );
  }
}

class JobStatusBadge extends StatelessWidget {
  const JobStatusBadge({super.key, required this.status});

  final JobStatus status;

  @override
  Widget build(BuildContext context) {
    late String text;
    late Color color;

    switch (status) {
      case JobStatus.completed:
        color = const Color(0xFF12B418);
        text = "Completed";
        break;
      case JobStatus.inProgress:
        color = const Color(0xFF173C79);
        text = "In Progress";
        break;
      case JobStatus.rejected:
        color = const Color(0xFFEE1C25);
        text = "Rejected";
        break;
      case JobStatus.pending:
        color = const Color(0xFFFFA500);
        text = "Pending";
        break;
      default:
        color = const Color(0xFF000000);
        text = "Open";
        break;
    }

    return Row(
      children: [
        Container(
          decoration: ShapeDecoration(
            color: color,
            shape: const CircleBorder(),
          ),
          height: 10,
          width: 10,
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(color: Colors.black87),
        )
      ],
    );
  }
}

showPrivateJobBottomSheet(
  BuildContext context, {
  required JobDto job,
  required Function() onAccept,
  required Function() onReject,
}) =>
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => PrivateJobBottomSheetView(
        job: job,
        onAccept: onAccept,
        onReject: onReject,
      ),
    );

class PrivateJobBottomSheetView extends StatelessWidget {
  const PrivateJobBottomSheetView({
    super.key,
    required this.job,
    required this.onAccept,
    required this.onReject,
  });

  final JobDto job;
  final Function() onAccept;
  final Function() onReject;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.jobType ?? "N/A",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFEE1C25),
                              ),
                            ),
                            Text(
                              // "Customer Name: ${job.customerName ?? "N/A"}",
                              AppLocalizations.of(context)!.nN_1014(job.customerName ?? "N/A"),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              // "Location: ${job.location ?? "N/A"}",
                              AppLocalizations.of(context)!.nN_1016(job.location ?? "N/A"),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          pushLocation(context, Uri(
                            path: '/chat',
                            queryParameters: {
                              'id': job.customerId.toString(),
                              'name': job.customerName,
                              'email': job.customerEmail,
                            },
                          ).toString());
                        },
                        icon: const Icon(Icons.message_outlined),
                        // 'Chat'
                        label: Text(AppLocalizations.of(context)!.nN_1019),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ImageCarousel(values: job.images),
                  const SizedBox(height: 10),
                  // Image.network(),
                  Text(
                    job.jobDescription ?? "N/A",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (job.status == JobStatus.open || job.status == JobStatus.pending)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: SizedBox(
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onAccept,
                      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFFEE1C25))),
                      // "Accept"
                      child: Text(AppLocalizations.of(context)!.nN_1020),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: onReject,
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Color(0xFFD9D9D9)),
                        foregroundColor: MaterialStatePropertyAll(Colors.black),
                      ),
                      child: Text(AppLocalizations.of(context)!.nN_275),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Public Job views

class StandalonePublicJobBoardView extends StatefulWidget {
  const StandalonePublicJobBoardView({super.key});

  @override
  State<StandalonePublicJobBoardView> createState() => _StandalonePublicJobBoardViewState();
}

class _StandalonePublicJobBoardViewState extends State<StandalonePublicJobBoardView> {
  late Future<List<JobDto>> future;
  late String filterValue;

  @override
  initState() {
    filterValue = "";
    future = fetch();
    super.initState();
  }

  Future refresh() async {
    setState(() {
      future = fetch();
    });
  }

  Future<List<JobDto>> fetch() async {
    var types = await locate<RestService>().getAllJobTypes();
    locate<GlobalJobTypes>().setTypes(types ?? []);
    var builder = locate<BuilderService>().value;
    return locate<RestService>().getAllPublicJobs(builder!.id!);
  }

  handleApply(JobDto job) async {
    try {
      locate<ProgressIndicatorController>().show();
      var id = locate<BuilderService>().value!.id!;
      await locate<RestService>().applyForJob(id, job.id!);
      refresh();
    } catch (err) {
      return;
    } finally {
      locate<ProgressIndicatorController>().hide();
    }
  }

  handleDismiss(JobDto job) async {
    try {
      locate<ProgressIndicatorController>().show();
      var id = locate<BuilderService>().value!.id!;
      await locate<RestService>().dismissPublicJob(id, job.id!);
      refresh();
    } catch (err) {
      return;
    } finally {
      locate<ProgressIndicatorController>().hide();
    }
  }

  handleSelect(BuildContext context, JobDto job) {
    showPublicJobBottomSheet(
      context,
      job: job,
      onApply: () async {
        await handleApply(job);
        if (context.mounted) Navigator.of(context).pop();
      },
      onDismiss: () async {
        handleDismiss(job);
        if (context.mounted) Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        if (snapshot.hasData && snapshot.data!.isEmpty) {
          // "The list is empty"
          return Center(child: Text(AppLocalizations.of(context)!.nN_1012));
        }

        var jobs = (snapshot.data ?? [])
            .reversed
            .where((job) => (job.title?.toLowerCase() ?? "").contains(filterValue.toLowerCase()))
            .toList();

        return PublicJobBoardView(
          jobs: jobs,
          onSelect: (job) => handleSelect(context, job),
          onRefresh: refresh,
          onApply: (job) async {
            await handleApply(job);
          },
          onDismiss: (job) async {
            await handleDismiss(job);
          },
          onSearchValueChange: (value) => setState(() => filterValue = value),
        );
      },
    );
  }
}

class PublicJobBoardView extends StatelessWidget {
  const PublicJobBoardView({
    super.key,
    required this.jobs,
    required this.onSelect,
    required this.onSearchValueChange,
    required this.onApply,
    required this.onDismiss,
    required this.onRefresh,
  });

  final List<JobDto> jobs;
  final Function(JobDto) onSelect;
  final Function(JobDto) onApply;
  final Function(JobDto) onDismiss;
  final Function(String) onSearchValueChange;
  final Future Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: AppSearchBar(
            onChange: onSearchValueChange,
            // hintText: 'SEARCH MY JOBS',
            hintText: AppLocalizations.of(context)!.nN_1021.toUpperCase(),
          ),
        ),
        const SizedBox(height: 5),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 0, top: 15),
                itemCount: jobs.length,
                shrinkWrap: true,
                separatorBuilder: (context, i) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  var job = jobs[i];
                  var type = locate<GlobalJobTypes>().getJobTypeByName(job.jobType);
                  // var type = locate<GlobalJobTypes>().value.first;
                  var icon = type.jobTypeImage == null
                      ? const Icon(Icons.image_not_supported_outlined)
                      : Image.network(type.jobTypeImage!);

                  return PublicJobCard(
                    customerName: job.customerName ?? "N/A",
                    lastModifiedData: job.justDate,
                    jobTitle: job.title ?? "N/A",
                    jobDescription: job.jobDescription ?? "N/A",
                    jobLocation: job.location ?? "N/A",
                    statusTag: JobStatusBadge(status: job.status),
                    icon: icon,
                    onSelect: () => onSelect(job),
                    onApply: () => onApply(job),
                    onDismiss: () => onDismiss(job),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PublicJobCard extends StatelessWidget {
  const PublicJobCard({
    super.key,
    required this.customerName,
    required this.jobTitle,
    required this.jobDescription,
    required this.jobLocation,
    required this.lastModifiedData,
    required this.statusTag,
    required this.icon,
    required this.onSelect,
    required this.onApply,
    required this.onDismiss,
  });

  final String customerName;
  final String jobTitle;
  final String jobDescription;
  final String jobLocation;
  final String lastModifiedData;
  final Widget statusTag;
  final Widget icon;
  final Function() onSelect;
  final Function() onApply;
  final Function() onDismiss;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xF0F0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  flex: 4,
                  fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // "Job : $jobTitle",
                        AppLocalizations.of(context)!.nN_1015(jobTitle),
                        style: const TextStyle(color: AppColors.red),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        // "Location : $jobLocation",
                        AppLocalizations.of(context)!.nN_1016(jobLocation),
                        style: const TextStyle(color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      ExpandableTextArea(text: jobDescription),
                      const SizedBox(height: 10),
                      // Row(
                      //   children: [
                      //     const Text(
                      //       "Status : ",
                      //       style: TextStyle(color: Colors.black87),
                      //     ),
                      //     statusTag
                      //   ],
                      // ),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: onApply,
                              style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFFEE1C25))),
                              // "Apply"
                              child: Text(AppLocalizations.of(context)!.nN_1022),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: onDismiss,
                              style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(Color(0xFFD9D9D9)),
                                foregroundColor: MaterialStatePropertyAll(Colors.black),
                              ),
                              child: Text(AppLocalizations.of(context)!.nN_276),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: icon,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandableTextArea extends StatefulWidget {
  const ExpandableTextArea({super.key, required this.text});

  final String text;

  @override
  State<ExpandableTextArea> createState() => _ExpandableTextAreaState();
}

class _ExpandableTextAreaState extends State<ExpandableTextArea> {
  bool isExpanded = false;

  toggle() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextSpan textSpan = TextSpan(
      text: isExpanded ? " see less" : " see more",
      recognizer: TapGestureRecognizer()..onTap = toggle,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );

    Widget child = Row(
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: Text(
            widget.text,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text.rich(textSpan),
      ],
    );

    if (isExpanded) {
      child = Text.rich(
        TextSpan(
          children: [
            TextSpan(text: widget.text),
            textSpan,
          ],
        ),
      );
    }

    return child;
  }
}

showPublicJobBottomSheet(
  BuildContext context, {
  required JobDto job,
  required Function() onApply,
  required Function() onDismiss,
}) =>
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => PublicJobBottomSheetView(
        job: job,
        onApply: onApply,
        onDismiss: onDismiss,
      ),
    );

class PublicJobBottomSheetView extends StatelessWidget {
  const PublicJobBottomSheetView({
    super.key,
    required this.job,
    required this.onApply,
    required this.onDismiss,
  });

  final JobDto job;
  final Function() onApply;
  final Function() onDismiss;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Text(
                    job.jobType ?? "N/A",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEE1C25),
                    ),
                  ),
                  Text(
                    // "Location: ${job.location ?? "N/A"}",
                    AppLocalizations.of(context)!.nN_1016(job.location ?? "N/A"),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  ImageCarousel(values: job.images),
                  const SizedBox(height: 10),
                  // Image.network(),
                  Text(
                    job.jobDescription ?? "N/A",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (job.status == JobStatus.open)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: SizedBox(
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onApply,
                      style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Color(0xFFEE1C25))),
                      // "Apply",
                      child: Text(AppLocalizations.of(context)!.nN_1022),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: onDismiss,
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Color(0xFFD9D9D9)),
                        foregroundColor: MaterialStatePropertyAll(Colors.black),
                      ),
                      child: Text(AppLocalizations.of(context)!.nN_276),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class ImageCarousel extends StatefulWidget {
  final List<String> values;

  const ImageCarousel({super.key, this.values = const []});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late int index;

  @override
  void initState() {
    index = 0;
    super.initState();
  }

  Widget buildImageLoader(context, child, frame, wasSynchronouslyLoaded) {
    if (wasSynchronouslyLoaded) return child;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: frame != null ? child : const CircularProgressIndicator(),
    );
  }

  Widget buildItem(BuildContext context, String item) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.network(
        item,
        frameBuilder: buildImageLoader,
        errorBuilder: (context, _, __) => const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded),
              const SizedBox(width: 10),
              // "No pictures provided"
              Text(AppLocalizations.of(context)!.nN_1023),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            enableInfiniteScroll: false,
            viewportFraction: 0.8,
            aspectRatio: 1.3,
            onPageChanged: (i, _) => setState(() => index = i),
          ),
          items: widget.values.map((value) => buildItem(context, value)).toList(),
        ),
        const SizedBox(height: 10),
        CarouselDots(
          length: widget.values.length,
          index: index,
        ),
      ],
    );
  }
}

class CarouselDots extends StatelessWidget {
  final int length;
  final int index;

  const CarouselDots({super.key, required this.length, required this.index});

  Widget buildDot(BuildContext context, bool isSelected) {
    Color color = isSelected ? Colors.black : Colors.black12;
    return Container(
      height: 8,
      width: 8,
      decoration: ShapeDecoration(
        shape: const CircleBorder(),
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        length,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: buildDot(context, index == i),
        ),
      ),
    );
  }
}
