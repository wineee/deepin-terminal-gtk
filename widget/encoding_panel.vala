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

using Gee;
using Gtk;
using Utils;
using Widgets;

namespace Widgets {
    public class EncodingPanel : Gtk.Box {
        public Widgets.Switcher switcher;
        public Widgets.ConfigWindow parent_window;
        public Workspace workspace;
        public WorkspaceManager workspace_manager;
        public Gdk.RGBA background_color;
        public Gdk.RGBA line_dark_color;
        public Gdk.RGBA line_light_color;
        public Gtk.Box home_page_box;
        public Gtk.ScrolledWindow scrolledwindow;
        public Gtk.Widget focus_widget;
        public KeyFile config_file;
        public Term focus_term;
        public int back_button_margin_start = 8;
        public int back_button_margin_top = 6;
        public int encoding_button_padding = 5;
        public int encoding_list_margin_bottom = 5;
        public int encoding_list_margin_top = 5;
        public int split_line_margin_start = 1;
        public int width = Constant.ENCODING_SLIDER_WIDTH;
        public string config_file_path;
        public Gtk.ScrolledWindow home_page_scrolledwindow = null;

        public delegate void UpdatePageAfterEdit ();

        public EncodingPanel (Workspace space, WorkspaceManager manager) {
            Object (orientation: Gtk.Orientation.HORIZONTAL, spacing: 0);
            Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);

            workspace = space;
            workspace_manager = manager;

            config_file = new KeyFile ();
            config_file_path = Utils.get_config_file_path ("encoding.conf");

            // 在GTK4中，get_toplevel已被移除
            // focus_widget = ((Gtk.Window) workspace.get_toplevel ()).get_focus ();
            // parent_window = (Widgets.ConfigWindow) workspace.get_toplevel ();
            focus_widget = null;
            parent_window = null;

            line_dark_color = Utils.hex_to_rgba ("#ffffff", 0.1);
            line_light_color = Utils.hex_to_rgba ("#000000", 0.1);

            switcher = new Widgets.Switcher (width);

            home_page_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            set_size_request (width, -1);
            home_page_box.set_size_request (width, -1);

            append (switcher);

            show_home_page ();

            // GTK4: 使用 override snapshot 替代 draw.connect
        }

        private bool on_draw (Gtk.Widget widget, Cairo.Context cr) {
            // 在GTK4中，get_toplevel已被移除
            // bool is_light_theme = ((Widgets.ConfigWindow) get_toplevel ()).is_light_theme ();
            bool is_light_theme = true; // 简化实现

            // GTK4: get_allocation 已被移除，使用 get_width/get_height
            int rect_width = widget.get_width ();
            int rect_height = widget.get_height ();

            if (is_light_theme) {
                cr.set_source_rgba (0, 0, 0, 0.1);
            } else {
                cr.set_source_rgba (1, 1, 1, 0.1);
            }

            cr.paint ();

            return true;
        }

        public void show_home_page (Gtk.Widget? start_widget=null) {
            scrolledwindow = new ScrolledWindow ();
            scrolledwindow.get_style_context ().add_class ("scrolledwindow");
            scrolledwindow.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
            scrolledwindow.get_vscrollbar ().get_style_context ().add_class ("light_scrollbar");
            home_page_box.append (scrolledwindow);

            realize.connect ((w) => {
                    init_scrollbar ();
                });

            var encoding_list = new EncodingList (focus_term.term.get_encoding (), parent_window.config.encoding_names, workspace);
            encoding_list.margin_top = encoding_list_margin_top;
            encoding_list.margin_bottom = encoding_list_margin_bottom;
            encoding_list.active_encoding.connect ((active_encoding_name) => {
                    try {
                        focus_term.term.set_encoding (active_encoding_name);
                    } catch (Error e) {
                        print ("EncodingPanel set_encoding error: %s\n", e.message);
                    }

                    init_scrollbar ();

                    queue_draw ();
                });

            scrolledwindow.set_child (encoding_list);

            switcher.add_to_left_box (home_page_box);

            show.connect ((w) => {
                    GLib.Timeout.add (100, () => {
                            double widget_x = 0, widget_y = 0;
                            encoding_list.active_encoding_button.translate_coordinates (encoding_list, 0, 0, out widget_x, out widget_y);

                            int rect_width = get_width ();
                            int rect_height = get_height ();

                            var adjust = scrolledwindow.get_vadjustment ();
                            adjust.set_value ((int)widget_y - (rect_height - Constant.ENCODING_BUTTON_HEIGHT) / 2);

                            return false;
                        });
                });

            show();
        }

        public void init_scrollbar () {
            scrolledwindow.get_vscrollbar ().get_style_context ().remove_class ("light_scrollbar");
            scrolledwindow.get_vscrollbar ().get_style_context ().remove_class ("dark_scrollbar");

            // 在GTK4中，get_toplevel已被移除
            // bool is_light_theme = ((Widgets.ConfigWindow) get_toplevel ()).is_light_theme ();
            bool is_light_theme = true; // 简化实现

            if (is_light_theme) {
                scrolledwindow.get_vscrollbar ().get_style_context ().add_class ("light_scrollbar");
            } else {
                scrolledwindow.get_vscrollbar ().get_style_context ().add_class ("dark_scrollbar");
            }
        }

        public void load_config () {
            var file = File.new_for_path (config_file_path);
            if (!file.query_exists ()) {
                Utils.touch_dir (Utils.get_config_dir ());
                Utils.create_file (config_file_path);
            } else {
                try {
                    config_file.load_from_file (config_file_path, KeyFileFlags.NONE);
                } catch (Error e) {
                    if (!FileUtils.test (config_file_path, FileTest.EXISTS)) {
                        print ("Config: %s\n", e.message);
                    }
                }
            }
        }

        public void create_home_page () {
            Utils.destroy_all_children (home_page_box);
            home_page_scrolledwindow = null;

            try {
                load_config ();

                foreach (unowned string option in config_file.get_groups ()) {
                    // GTK4: 暂时注释掉 add_group_item 调用
                    // add_group_item (option, config_file);
                }
            } catch (Error e) {
                if (!FileUtils.test (config_file_path, FileTest.EXISTS)) {
                    print ("EncodingPanel create_home_page: %s\n", e.message);
                }
            }

            // GTK4: 暂时注释掉 create_scrolled_window 调用
            // home_page_scrolledwindow = create_scrolled_window ();
            // home_page_box.append (home_page_scrolledwindow);
        }
    }
}
