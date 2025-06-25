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
    public class Entry : Gtk.Entry {
        public Widgets.EntryMenu menu;

        public Entry () {
            // GTK4: 使用 EventController 替代 button_press_event
            var click_controller = new Gtk.GestureClick ();
            click_controller.pressed.connect ((n_press, x, y) => {
                // GTK4: 简化实现，暂时注释掉右键菜单功能
                // if (Utils.is_right_button (e)) {
                //     menu = new Widgets.EntryMenu ();
                //     menu.create_entry_menu (this, (int) e.x_root, (int) e.y_root);
                //     return true;
                // }
            });
            add_controller (click_controller);
        }
    }
}
