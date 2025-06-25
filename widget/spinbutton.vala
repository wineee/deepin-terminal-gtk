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
using Utils;

namespace Widgets {
    public class SpinButton : Gtk.SpinButton {
        public Widgets.EntryMenu menu;

        public SpinButton () {
            // 在GTK4中，这些事件信号已被移除
            // button_press_event.connect ((w, e) => {
            //         if (Utils.is_right_button (e)) {
            //             menu = new Widgets.EntryMenu ();
            //             menu.create_entry_menu (this, (int) e.x_root, (int) e.y_root);

            //             return true;
            //         }

            //         return false;
            //     });

            // Prevent scroll event.
            // scroll_event.connect(   (w, e) => {
            //         return true;
            //     });
        }
    }
}
