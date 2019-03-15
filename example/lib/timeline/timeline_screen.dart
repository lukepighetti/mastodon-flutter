import 'package:flutter/material.dart';

import 'package:mastodon/mastodon.dart' hide Card;
import 'package:provider/provider.dart';

import 'status_card.dart';

class TimelineScreen extends StatelessWidget {
  final Account account;

  TimelineScreen({@required this.account});

  @override
  Widget build(BuildContext context) {
    return Provider<Account>(
      value: account,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Timeline"),
        ),
        body: _TimelineTabBar(),
      ),
    );
  }
}

class _TimelineTabBar extends StatefulWidget {
  @override
  __TimelineTabBarState createState() => __TimelineTabBarState();
}

class __TimelineTabBarState extends State<_TimelineTabBar>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    _controller = TabController(vsync: this, length: 4);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mastodon = Provider.of<Mastodon>(context);
    final account = Provider.of<Account>(context);

    return Column(
      children: <Widget>[
        TabBar(
          controller: _controller,
          labelPadding: EdgeInsets.symmetric(vertical: 12.0),
          tabs: <Widget>[
            Text("Feed"),
            Text("Local"),
            Text("Public"),
            Text("Wall"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _controller,
            children: <Widget>[
              _Timeline(
                fetchStatuses: (_maxId) => mastodon.timeline(maxId: _maxId),
              ),
              _Timeline(
                fetchStatuses: (_maxId) =>
                    mastodon.publicTimeline(local: true, maxId: _maxId),
              ),
              _Timeline(
                fetchStatuses: (_maxId) =>
                    mastodon.publicTimeline(local: false, maxId: _maxId),
              ),
              _Timeline(
                fetchStatuses: (_maxId) =>
                    mastodon.statuses(account?.id, maxId: _maxId),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _Timeline extends StatefulWidget {
  final StatusGetter fetchStatuses;

  _Timeline({@required this.fetchStatuses});

  @override
  __TimelineState createState() => __TimelineState();
}

class __TimelineState extends State<_Timeline>
    with AutomaticKeepAliveClientMixin {
  final _controller = ScrollController();
  TimelineBloc _bloc;

  @override
  didChangeDependencies() {
    _bloc = TimelineBloc(widget.fetchStatuses);

    _controller.addListener(_listener);

    super.didChangeDependencies();
  }

  _listener() {
    final pixelsRemaining =
        _controller.position.maxScrollExtent - _controller.offset;

    if (pixelsRemaining < 3000) {
      _bloc.requestingMoreSink.add(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: StreamBuilder<List<Status>>(
        stream: _bloc.statuses,
        initialData: null,
        builder: (_, snap) {
          final statuses = snap?.data;

          if (statuses == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            controller: _controller,
            children: statuses.map((s) => StatusCard(status: s)).toList(),
            cacheExtent: 1000,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
