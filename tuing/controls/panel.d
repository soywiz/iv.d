/* Invisible Vector Library
 * simple FlexBox-based TUI engine
 *
 * coded by Ketmar // Invisible Vector <ketmar@ketmar.no-ip.org>
 * Understanding is not required. Only obedience.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
// framed boxes, non-shrinking
module iv.tuing.controls.panel;

import iv.strex;
import iv.rawtty2;

import iv.tuing.eventbus;
import iv.tuing.events;
import iv.tuing.layout;
import iv.tuing.tty;
import iv.tuing.tui;
import iv.tuing.types;


// ////////////////////////////////////////////////////////////////////////// //
public class FuiPanel : FuiControl {
  alias onMyEvent = super.onMyEvent;
  this (FuiControl aparent) {
    this.connectListeners();
    super(aparent);
    vertical = true;
    aligning = Align.Start;
  }
  protected override void drawSelf (XtWindow win) {
    win.color = palColor!"def"();
    win.frame!true(0, 0, win.width, win.height);
  }
}

public class FuiHPanel : FuiPanel {
  alias onMyEvent = super.onMyEvent;
  this (FuiControl aparent) { this.connectListeners(); super(aparent); horizontal = true; }
}

public class FuiVPanel : FuiPanel {
  alias onMyEvent = super.onMyEvent;
  this (FuiControl aparent) { this.connectListeners(); super(aparent); vertical = true; }
}