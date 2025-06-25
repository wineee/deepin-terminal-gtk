/* -*- Mode: Vala; indent-tabs-mode: nil; tab-width: 4 -*-
 * -*- coding: utf-8 -*-
 *
 * Copyright (C) 2011 ~ 2018 Deepin, Inc.
 *               2011 ~ 2018 Wang Yong
 *
 * Author:     Wang Yong <wangyong@deepin.com>
 * Maintainer: Wang Yong <wangyong@deepin.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;
using Widgets;

namespace Widgets {
    public class DropdownTextButton : Gtk.ComboBoxText {
        public DropdownTextButton () {
            // 在GTK4中，使用EventController替代scroll_event
            var scroll_controller = new Gtk.EventControllerScroll ();
            scroll_controller.scroll.connect ((x, y) => {
                on_scroll (this, x, y);
                return true;
            });
            add_controller (scroll_controller);
        }

        public bool on_scroll (Gtk.Widget widget, double x, double y) {
            return true;
        }
    }
}
