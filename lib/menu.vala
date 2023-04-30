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

namespace Menu {
    public class MenuItem : Object {
        public string menu_item_id;
        public string menu_item_text;
        public List<MenuItem> menu_item_submenu;

        public MenuItem (string item_id, string item_text) {
            menu_item_id = item_id;
            menu_item_text = item_text;

            menu_item_submenu = new List<MenuItem> ();
        }

        public void add_submenu_item (MenuItem item) {
            menu_item_submenu.append (item);
        }
    }

    public class Menu : Object {
        private bool inited = false;

        public signal void click_item (string item_id);
        public signal void destroy ();

        public Menu () {}

        private void init () {
            if (inited) return;

            inited = true;
        }

        public void popup_at_position (List<MenuItem> menu_content, int x, int y) {
            init ();
            show_gtk_menu_at_pointer (menu_content);
        }

        private Gtk.Menu create_gtk_menu (List<MenuItem> menu_content) {
            Gdk.Screen screen = Gdk.Screen.get_default ();
            CssProvider provider = new Gtk.CssProvider ();
            try {
                provider.load_from_data (Utils.get_menu_css ());
            } catch (GLib.Error e) {
                    warning ("Something bad happened with CSS load %s", e.message);
            }
            Gtk.StyleContext.add_provider_for_screen (screen,provider,Gtk.STYLE_PROVIDER_PRIORITY_USER);
            Gtk.Menu result = new Gtk.Menu ();

            foreach (unowned MenuItem menu_item in menu_content) {
                var item = create_gtk_menu_item (menu_item.menu_item_id, menu_item.menu_item_text);
                if (menu_item.menu_item_submenu.length () > 0) {
                    Gtk.Menu submenu = create_gtk_menu (menu_item.menu_item_submenu);
                    item.set_submenu (submenu);
                }
                result.append (item);
            }

            return result;
        }

        private Gtk.MenuItem create_gtk_menu_item (string item_id, string item_text) {
            Gtk.MenuItem item = (item_text == "") ? new Gtk.SeparatorMenuItem(   ) : new Gtk.MenuItem.with_label(   item_text);

            item.activate.connect (() => {
                click_item (item_id);
            });

            return item;
        }

        private void show_gtk_menu_at_pointer (List<MenuItem> menu_content) {
            var gtk_menu = create_gtk_menu (menu_content);
            gtk_menu.show_all ();
            gtk_menu.popup_at_pointer ();
        }

        private string get_items_node (List<MenuItem> menu_content) {
            Json.Builder builder = new Json.Builder ();

            builder.begin_object ();

            builder.set_member_name ("items");
            builder.begin_array ();
            foreach (MenuItem item in menu_content) {
                builder.add_value (get_item_node (item));
            }
            builder.end_array ();

            builder.end_object ();

            Json.Generator generator = new Json.Generator ();
            generator.set_root (builder.get_root ());

            return generator.to_data (null);
        }

        private Json.Node get_item_node (MenuItem item) {
            Json.Builder builder = new Json.Builder ();

            builder.begin_object ();

            builder.set_member_name ("itemId");
            builder.add_string_value (item.menu_item_id);

            builder.set_member_name ("itemText");
            builder.add_string_value (item.menu_item_text);

            builder.set_member_name ("itemIcon");
            builder.add_string_value ("");

            builder.set_member_name ("itemIconHover");
            builder.add_string_value ("");

            builder.set_member_name ("itemIconInactive");
            builder.add_string_value ("");

            builder.set_member_name ("itemExtra");
            builder.add_string_value ("");

            builder.set_member_name ("isActive");
            builder.add_boolean_value (true);

            builder.set_member_name ("checked");
            builder.add_boolean_value (false);

            builder.set_member_name ("itemSubMenu");
            unowned List<MenuItem> submenu_items = item.menu_item_submenu;

            if (submenu_items.length () == 0) {
                builder.add_null_value ();
            } else {
                Json.Builder _builder = new Json.Builder ();

                _builder.begin_object ();

                _builder.set_member_name ("items");

                _builder.begin_array ();
                foreach (MenuItem _item in submenu_items) {
                    _builder.add_value (get_item_node (_item));
                }
                _builder.end_array ();

                _builder.end_object ();

                builder.add_value (_builder.get_root ());
            }

            builder.end_object ();

            return builder.get_root ();
        }
    }
}
