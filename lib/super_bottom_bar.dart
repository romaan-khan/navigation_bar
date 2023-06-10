import 'package:flutter/material.dart';

class BrandBottomNavigationBar extends StatefulWidget {
  ///The Constructor of SuperBottomNavigationBar.
  ///items is required.

  const BrandBottomNavigationBar({
    super.key,
    this.currentIndex = 0,
    this.height = 70.0,
    this.padding = EdgeInsets.zero,
    this.curve = Curves.easeIn,
    this.duration = const Duration(milliseconds: 400),
    this.elevation = 8,
    this.onSelected,
  })  : assert(currentIndex >= 0),
        assert(height >= 25),
        assert(elevation >= 0.0);

  ///[currentIndex] The tab to display.
  final int currentIndex;

  ///[height] Height of the BottomNavigationBar.
  final double height;

  ///[curve] The transition curve.
  final Curve curve;

  ///[duration] The transition duration.
  final Duration duration;

  ///[padding] The padding surrounding the entire widget.
  ///
  /// You can use to adding floating effect.
  final EdgeInsets padding;

  ///[elevation] The elevation of the widget.
  final double elevation;

  ///[onSelected] Callback method , Return the index of the tab that was tapping.
  final Function? onSelected;

  @override

  /// Creating state fo SuperBottomNavigationBar.
  State<StatefulWidget> createState() => _BrandBottomNavigationBarState();
}

/// This class is represent BottomNavigationBar Widget.
class _BrandBottomNavigationBarState extends State<BrandBottomNavigationBar> {
  /// This class is represent BottomNavigationBar Widget.
  int selected = 0;

  @override

  /// using the widget.
  BrandBottomNavigationBar get widget => super.widget;

  @override

  /// When initialize the widget.
  void initState() {
    /// Super initialize.
    super.initState();
    selected = widget.currentIndex;
  }

  ///TODO change items here
  List<SuperBottomNavigationBarItem> makeNavItems() {
    return [
      SuperBottomNavigationBarItem(
        icon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.abc),
            Text('Dashboard',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        size: 30,
        backgroundShadowColor: Colors.white,
        borderBottomColor: Colors.white,
        borderBottomWidth: 1,
      ),
      SuperBottomNavigationBarItem(
        icon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.abc),
            Text(
              'Dashboard',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        size: 30,
        backgroundShadowColor: Colors.white,
        borderBottomColor: Colors.white,
        borderBottomWidth: 1,
      ),
      SuperBottomNavigationBarItem(
        icon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.abc),
            Text(
              'Dashboard',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        size: 30,
        backgroundShadowColor: Colors.white,
        borderBottomColor: Colors.white,
        borderBottomWidth: 1,
      ),
      SuperBottomNavigationBarItem(
        icon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.abc),
            Text(
              'Dashboard',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        size: 30,
        backgroundShadowColor: Colors.white,
        borderBottomColor: Colors.white,
        borderBottomWidth: 1,
      ),
      SuperBottomNavigationBarItem(
        icon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.abc),
            Text(
              'Dashboard',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        size: 30,
        backgroundShadowColor: Colors.white,
        borderBottomColor: Colors.white,
        borderBottomWidth: 1,
      ),
    ];
  }

  @override

  /// Building the widget.
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Material(
        ///TODO change background color here
        color: Colors.brown,
        elevation: widget.elevation,
        child: InkWell(
          child: Row(
            children: List.generate(
                makeNavItems().length,
                (index) => Expanded(
                      child: SuperNavItem(
                        item: makeNavItems()[index],
                        selected: selected == index,
                        height: widget.height,
                        curve: widget.curve,
                        duration: widget.duration,
                        changeIndex: () {
                          ///Change the state.
                          setState(() {});
                          selected = index;
                          widget.onSelected!(index);
                        },
                      ),
                    )),
          ),
        ),
      ),
    );
  }
}

/* SuperNavItem Widget Class */

/// A tab to display in SuperBottomNavigationBar.
class SuperNavItem extends StatelessWidget {
  ///The Constructor of SuperNavItem.
  ///All variables is required.
  const SuperNavItem(
      {super.key,
      required this.item,
      required this.selected,
      required this.height,
      required this.curve,
      required this.duration,
      required this.changeIndex});

  ///[item] SuperNavItem object which contains all of data to display.
  final SuperBottomNavigationBarItem item;

  ///[selected] To check how to show the tab when it is selected.
  final bool selected;

  ///[height] Height of the tab.
  final double height;

  ///[duration] The transition duration.
  final Duration duration;

  ///[curve] The transition curve.
  final Curve curve;

  ///[changeIndex] The callback method the change the state.
  final GestureTapCallback changeIndex;

  @override

  /// Building the widget
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: changeIndex,
        highlightColor: item.highlightColor.withOpacity(0.6),
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Ink(
          child: Stack(
            children: [
              AnimatedContainer(
                margin: const EdgeInsets.only(bottom: 5),
                height: height,
                duration: duration,
                curve: curve,
                // decoration: BoxDecoration(
                //   border: selected
                //       ? Border(
                //       bottom: BorderSide(
                //           color: item.borderBottomColor,
                //           width: item.borderBottomWidth))
                //       : const Border(
                //       bottom: BorderSide(color: Colors.transparent, width: 0)),
                //   gradient: selected
                //       ? LinearGradient(
                //     colors: [
                //       item.backgroundShadowColor.withOpacity(0.1),
                //       Colors.transparent,
                //
                //       // Color(0xFF6c5ce7).withOpacity(0.5),
                //       // Color(0xFF897dec).withOpacity(0.01)
                //     ],
                //     begin: Alignment.bottomCenter,
                //     end: Alignment.topCenter,
                //   )
                //       : const LinearGradient(
                //     colors: [Colors.transparent, Colors.transparent],
                //     begin: Alignment.bottomCenter,
                //     end: Alignment.topCenter,
                //   ),
                // ),
                child: Center(
                  child: item.icon,
                ),
              ),

              ///TODO change bottom shadow here.
              selected
                  ? Positioned(
                      bottom: 10,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 1,
                        decoration: const BoxDecoration(color: Colors.white),
                      ))
                  : const SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}

/* Model Class */

/// A tab to display in SuperBottomNavigationBar.
class SuperBottomNavigationBarItem {
  ///The Constructor of SuperBottomNavigationBarItem.
  const SuperBottomNavigationBarItem(
      {this.icon = const SizedBox.shrink(),
      this.size = 30,
      this.highlightColor = Colors.transparent, //Colors.grey.withOpacity(0.6)
      this.splashColor = Colors.transparent,
      this.hoverColor = Colors.transparent, //Colors.grey.withOpacity(0.6)
      this.borderBottomColor = const Color(0xFF6c5ce7),
      this.borderBottomWidth = 3,
      this.backgroundShadowColor = const Color(0xFF6c5ce7)})
      : assert(size >= 7),
        assert(borderBottomWidth >= 1);

  /* Variables */

  ///[icon] The icon of the tab when tab is selected.
  final Widget icon;

  ///[size] The size of the tab.
  final double size;

  ///[highlightColor] The highlight color of the ink response when pressed.
  ///You can use it to add ripple effect.
  final Color highlightColor;

  ///[splashColor] The splash color of the ink response.
  ///You can use it to add ripple effect.
  final Color splashColor;

  ///[hoverColor] The color of the ink response when a pointer is hovering over it.
  ///You can use it to add ripple effect.
  final Color hoverColor;

  ///[borderBottomColor] The color of borderBottom.
  final Color borderBottomColor;

  ///[borderBottomWidth] The width of borderBottom.
  final double borderBottomWidth;

  ///[backgroundShadowColor] The shadow color behind the icon.
  final Color backgroundShadowColor;
}
