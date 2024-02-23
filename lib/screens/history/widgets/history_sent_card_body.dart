import 'package:atsign_atmosphere_pro/data_models/file_transfer.dart';
import 'package:atsign_atmosphere_pro/screens/history/widgets/history_file_list.dart';
import 'package:atsign_atmosphere_pro/services/common_utility_functions.dart';
import 'package:atsign_atmosphere_pro/utils/colors.dart';
import 'package:atsign_atmosphere_pro/utils/text_styles.dart';
import 'package:atsign_atmosphere_pro/utils/vectors.dart';
import 'package:atsign_atmosphere_pro/view_models/history_provider.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:atsign_atmosphere_pro/widgets/custom_ellipsis_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HistorySentCardBody extends StatefulWidget {
  final FileHistory fileHistory;

  const HistorySentCardBody({
    required this.fileHistory,
  });

  @override
  State<HistorySentCardBody> createState() => _HistorySentCardBodyState();
}

class _HistorySentCardBodyState extends State<HistorySentCardBody> {
  late TrustedContactProvider trustedContactProvider =
      context.read<TrustedContactProvider>();
  late HistoryProvider historyProvider = context.read<HistoryProvider>();

  @override
  Widget build(BuildContext context) {
    return Selector<HistoryProvider, bool>(
      builder: (context, value, child) {
        return value
            ? Column(
                children: [
                  buildAtSignListText,
                  SizedBox(height: 4),
                  CustomEllipsisTextWidget(
                    text: widget.fileHistory.notes ?? '',
                    ellipsis: '... "',
                    style: CustomTextStyles.darkSliverW40012,
                  ),
                  SizedBox(height: 12),
                  HistoryFileList(
                    type: widget.fileHistory.type,
                    fileTransfer: widget.fileHistory.fileDetails,
                  ),
                ],
              )
            : buildCollapsedContent;
      },
      selector: (_, p) =>
          p.listExpandedFiles.contains(widget.fileHistory.fileDetails?.key),
    );
  }

  Widget get buildAtSignListText {
    return RichText(
      text: TextSpan(
        children: listInlineSpan,
      ),
    );
  }

  List<InlineSpan> get listInlineSpan {
    List<InlineSpan> result = [];

    widget.fileHistory.sharedWith?.forEach((element) async {
      final nickname = await CommonUtilityFunctions()
          .getNickname(widget.fileHistory.fileDetails?.sender ?? '');
      final isTrust = trustedContactProvider.trustedContacts
          .any((e) => e.atSign == element.atsign);
      result.add(
        TextSpan(
          children: [
            if (nickname.isNotEmpty)
              TextSpan(
                text: '$nickname ',
                style: CustomTextStyles.blackW60013,
              ),
            TextSpan(
              text: element.atsign,
              style: CustomTextStyles.blackW40013,
            ),
            if (isTrust)
              WidgetSpan(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 4),
                    SvgPicture.asset(
                      AppVectors.icTrustActivated,
                      width: 16,
                      height: 16,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            if (element.atsign != widget.fileHistory.sharedWith?.last.atsign)
              TextSpan(
                text: ',',
                style: CustomTextStyles.blackW40013,
              ),
          ],
        ),
      );
    });

    return result;
  }

  Widget get buildCollapsedContent {
    final numberOfFiles = widget.fileHistory.fileDetails?.files?.length ?? 0;
    final numberOfContacts = widget.fileHistory.fileDetails?.files?.length ?? 0;

    return Row(
      children: [
        SizedBox(width: 12),
        Text(
          '$numberOfFiles ${numberOfFiles > 1 ? 'Files' : 'File'} to $numberOfContacts ${numberOfContacts > 1 ? 'Contacts' : 'Contact'}',
          style: CustomTextStyles.darkSliverW40012,
        ),
        Spacer(),
        InkWell(
          onTap: () {
            historyProvider
                .setExpandedFile(widget.fileHistory.fileDetails?.key ?? '');
          },
          child: Row(
            children: [
              Text(
                'Expand Details',
                style: CustomTextStyles.raisinBlackW50012,
              ),
              SizedBox(width: 4),
              SvgPicture.asset(
                AppVectors.icArrowDownOutline,
                height: 8,
                width: 12,
                fit: BoxFit.cover,
                color: ColorConstants.raisinBlack,
              )
            ],
          ),
        ),
      ],
    );
  }
}
