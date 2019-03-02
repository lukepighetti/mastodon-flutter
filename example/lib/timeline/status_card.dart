import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mastodon/mastodon.dart' hide Card;
import 'package:feather_icons_flutter/feather_icons_flutter.dart';

import 'package:url_launcher/url_launcher.dart';

class StatusCard extends StatelessWidget {
  final Status status;

  StatusCard({@required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: _PosterSection(status: status),
    );
  }
}

class _PosterSection extends StatelessWidget {
  final Status status;

  const _PosterSection({
    Key key,
    @required this.status,
  }) : super(key: key);

  String get name => status?.account?.displayName ?? status?.account?.username;
  String get timestamp => timeago.format(status?.createdAt, locale: "en_short");
  String get iconUrl => status?.account?.avatarStatic.toString();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        /// Card Left
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                backgroundImage: NetworkImage(iconUrl),
              ),
            ],
          ),
        ),

        /// Card Right
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: Theme.of(context).textTheme.title,
                ),
                Html(
                  data: status.content,
                  onLinkTap: (url) => launch(url),
                  blockSpacing: 4,
                ),
                _Actions(
                  status: status,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final Status status;

  _Actions({@required this.status});

  int get toots => status.repliesCount;
  int get boosts => status.reblogsCount;
  int get favourites => status.favouritesCount;

  bool get isBoosted => status.reblogged;
  bool get isFavourited => status.favourited;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Table(
              children: <TableRow>[
                TableRow(
                  children: <Widget>[
                    _StatsButton(
                      iconData: FeatherIcons.messageSquare,
                      value: toots,
                    ),
                    _StatsButton(
                      iconData: FeatherIcons.repeat,
                      isHighlighted: isBoosted,
                      value: boosts,
                    ),
                    _StatsButton(
                      iconData: FeatherIcons.heart,
                      isHighlighted: isFavourited,
                      value: favourites,
                    ),
                  ],
                )
              ],
            ),
          ),
          _StatsButton(
            iconData: FeatherIcons.moreVertical,
          )
        ],
      ),
    );
  }
}

class _StatsButton extends StatelessWidget {
  final IconData iconData;
  final bool isHighlighted;
  final String value;

  _StatsButton({
    @required this.iconData,
    this.isHighlighted = false,
    int value = 0,
  }) : value = value > 0 ? value.toString() : "";

  @override
  Widget build(BuildContext context) {
    final _color = Theme.of(context).disabledColor;
    final _highlightedColor = Theme.of(context).primaryColor;

    final double _size = 20;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Icon(
          iconData,
          size: _size,
          color: isHighlighted ? _highlightedColor : _color,
        ),
        SizedBox(
          width: 8,
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlighted ? _highlightedColor : _color,
          ),
        ),
      ],
    );
  }
}