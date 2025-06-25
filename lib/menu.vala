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

using GLib;

namespace Menu {
    public class MenuItem {
        public string id;
        public string text;
        public List<MenuItem> submenu;

        public MenuItem (string item_id, string item_text) {
            id = item_id;
            text = item_text;
            submenu = new List<MenuItem> ();
        }
    }

    public class MenuBuilder {
        private Gtk.Popover create_gtk_menu (List<MenuItem> menu_content) {
            var popover = new Gtk.Popover ();
            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            popover.set_child (box);

            foreach (MenuItem menu_item in menu_content) {
                if (menu_item.submenu.length () > 0) {
                    var submenu_popover = create_gtk_menu (menu_item.submenu);
                    var submenu_button = create_gtk_menu_button (menu_item.id, menu_item.text, submenu_popover);
                    box.append (submenu_button);
                } else {
                    var menu_button = create_gtk_menu_button (menu_item.id, menu_item.text, null);
                    box.append (menu_button);
                }
            }

            return popover;
        }

        private Gtk.Widget create_gtk_menu_button (string item_id, string item_text, Gtk.Popover? submenu) {
            Gtk.Widget widget;
            
            if (item_text == "") {
                widget = new Gtk.Separator(Gtk.Orientation.HORIZONTAL);
            } else {
                var button = new Gtk.Button.with_label (item_text);
                button.clicked.connect (() => {
                    // 处理菜单项点击事件
                    print ("Menu item clicked: %s\n", item_id);
                });
                widget = button;
            }

            if (submenu != null) {
                var submenu_button = new Gtk.MenuButton ();
                submenu_button.set_popover (submenu);
                submenu_button.set_label (item_text);
                return submenu_button;
            }

            return widget;
        }

        public Gtk.Popover create_menu (List<MenuItem> menu_content) {
            return create_gtk_menu (menu_content);
        }
    }
}
