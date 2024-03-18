import 'package:at_contact/at_contact.dart';
import 'package:atsign_atmosphere_pro/screens/group_contacts/widgets/groups_member_item_widget.dart';
import 'package:atsign_atmosphere_pro/view_models/trusted_sender_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupsMemberListView extends StatefulWidget {
  final Set<AtContact> members;

  const GroupsMemberListView({
    required this.members,
  });

  @override
  State<GroupsMemberListView> createState() => _GroupsMemberListViewState();
}

class _GroupsMemberListViewState extends State<GroupsMemberListView> {
  late TrustedContactProvider trustedContactProvider =
      context.read<TrustedContactProvider>();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 36, vertical: 28),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return GroupsMemberItemWidget(
          member: widget.members.elementAt(index),
          isTrusted: trustedContactProvider.trustedContacts.any(
            (element) =>
                element.atSign == widget.members.elementAt(index).atSign,
          ),
        );
      },
      separatorBuilder: (context, index) {
        return SizedBox(height: 16);
      },
      itemCount: widget.members.length,
    );
  }
}
