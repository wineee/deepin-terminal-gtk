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
    public class FileButton : Gtk.Box {
        public Gtk.Box box;
        public Gtk.Box button_box;
        public ImageButton file_add_button;
        public Widgets.Entry entry;
        public int height = 26;

        public FileButton () {
            Object (orientation: Gtk.Orientation.HORIZONTAL, spacing: 0);
            Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);

            set_size_request (-1, height);

            box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            entry = new Widgets.Entry ();
            entry.margin_top = 1;
            entry.margin_bottom = 1;

            file_add_button = new ImageButton ("file_add");

            button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            box.append (entry);
            box.append (button_box);

            entry.get_style_context ().add_class ("file_add_entry");
            button_box.append (file_add_button);

            var chooser = new Gtk.FileDialog ();
            chooser.set_title (_("Select File"));
            chooser.set_modal (true);

            file_add_button.clicked.connect (() => {
                // GTK4: open 方法需要 Gtk.Window 作为 parent，使用 get_root() 获取父窗口
                var parent_window = get_root () as Gtk.Window;
                chooser.open.begin (parent_window, null, (obj, res) => {
                    try {
                        var file = chooser.open.end (res);
                        if (file != null) {
                            entry.set_text (file.get_path ());
                        }
                    } catch (Error e) {
                        print ("Error opening file: %s\n", e.message);
                    }
                });
            });

            // GTK4: 继承自 Gtk.Box，直接使用 append
            append (box);
        }

        public void select_private_key_file () {
            var chooser = new Gtk.FileDialog ();
            chooser.set_title (_("Select the private key file"));
            
            // GTK4: 需要获取父窗口，使用 get_root() 获取根窗口
            var parent_window = get_root () as Gtk.Window;
            chooser.open.begin (parent_window, null, (obj, res) => {
                try {
                    var file = chooser.open.end (res);
                    if (file != null) {
                        entry.set_text (file.get_path ());
                    }
                } catch (Error e) {
                    // 用户取消选择
                }
            });
        }
    }
}
