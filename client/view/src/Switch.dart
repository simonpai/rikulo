//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Mon, Jun 18, 2012  9:46:29 AM
// Author: tomyeh

/**
 * A switch button.
 *
 * ##Events
 *
 * + change: an instance of [ChangeEvent] indicates the check state is changed.
 *
 * ##Styles
 *
 * To create a smaller switch, you can assign `"v-small"` to it. For example,
 *
 *     new Switch().classes.add("v-small");
 */
class Switch extends View implements Input<bool> {
  String _onLabel, _offLabel;
  DragGesture _dg;
  bool _value = false, _disabled = false;

  /** Instantaites a switch.
   */
  Switch([bool value, String onLabel, String offLabel]) {
    _value = value !== null && value;
    _onLabel = onLabel !== null ? onLabel: "ON";
    _offLabel = offLabel !== null ? offLabel: "OFF";
  }
  //@Override
  String get className() => "Switch"; //TODO: replace with reflection if Dart supports it

  /** Returns whether it is value (i.e., the switch is ON).
   *
   * Default: false.
   */
  bool get value() => _value;
  /** Sets whether it is value (i.e., the switch is ON).
   */
  void set value(bool value) {
    _setValue(value);
  }

  /** Returns whether it is disabled.
   *
   * Default: false.
   */
  bool get disabled() => _disabled;
  /** Sets whether it is disabled.
   */
  void set disabled(bool disabled) {
    _disabled = disabled;

    if (disabled)
      classes.add("v-disabled");
    else
      classes.remove("v-disabled");
  }

  /** Returns the label to indicate the switch is ON.
   */
  String get onLabel() => _onLabel;
  /** Returns the label to indicate the switch is OFF.
   */
  String get offLabel() => _offLabel;

  Element get _sdNode() => getNode('sd');
  Element get _bgNode() => getNode('bg');
  int get _marginDiff() => 1 - (outerHeight >> 1); //-(radius - 1) (border)
  /** X offset for the OFF label. */
  int get _x_off() => outerWidth - outerHeight; //-(width - 2 * radius)
  void _setValue(bool value, [bool bAnimate=false, bool bSendEvent=false]) {
    final bool bChanged = _value != value;
    _value = value;
    if (inDocument) {
      final int nofs = _value ? 0 : -_x_off;
      if (bAnimate) {
        final int sofs = _translate3dXValue(_sdNode.style.transform);
        final int dofs = nofs - sofs;
        new EasingMotion((num x) {
          int cofs = sofs + (dofs * x).toInt();
          _sdNode.style.transform = CSS.translate3d(cofs, 0);
          _updateBg(cofs);
        }, duration: 150);
      } else {
        _sdNode.style.transform = CSS.translate3d(nofs, 0);
        _updateBg(nofs);
      }
    }
    if (bSendEvent && bChanged)
      sendEvent(new ChangeEvent(_value));
  }
  void _updateBg(int delta) {
    _bgNode.style.marginLeft = CSS.px(delta + _marginDiff);
  }
  int _translate3dXValue(String str) => str == null ? 0 : CSS.intOf(str.substring(12));
  
  void mount_() {
    super.mount_();

    _setValue(_value);
    _dg = new DragGesture(_sdNode, transform: true,
      range: () => new Rectangle(-_x_off, 0, 0, 0),
      start: (state) {
        state.data = CSS.intOf(_bgNode.style.marginLeft) - _marginDiff;
        return state.gesture.owner;
      },
      moving: (state) {
        _updateBg(state.delta.x + state.data);
        return false;
      },
      end: (state) {
        _setValue(state.moved ?
					(state.delta.x + state.data) > (-(_x_off>>1)): !_value,
					true, true);
        return true; //no more move
      });
  }
  void unmount_() {
    _dg.destroy();
    super.unmount_();
  }
  void onLayout_() { //Issue 5: if its parent's hidden is changed
    //we call it before super.onLayout_, i.e., before sending event out
    //Note: overriding doLayout_ can't control between layouted and send event
    _setValue(_value);
    super.onLayout_();
  }

  void domInner_(StringBuffer out) {
    out.add('<div class="v-bg"><div class="v-bgi" id="')
      .add(uuid).add('-bg"></div></div><div class="v-slide" id="')
      .add(uuid).add('-sd"><div class="v-text-on v-button">')
      .add(onLabel).add('</div><div class="v-text-off v-button">')
      .add(offLabel).add('</div><div class="v-knot"></div></div>');
  }

  /** Returns false to indicate this view doesn't allow any child views.
   */
  bool isViewGroup() => false;
  String toString() => "$className($value)";
}
