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
    public class ThemePanel : Gtk.Box {
        public Widgets.ConfigWindow parent_window;
        public Widgets.Switcher switcher;
        public WorkspaceManager workspace_manager;
        public Workspace workspace;
        public Gdk.RGBA background_color;
        public Gdk.RGBA line_dark_color;
        public Gdk.RGBA line_light_color;
        public Gtk.Box home_page_box;
        public Gtk.ScrolledWindow scrolledwindow;
        public Gtk.Widget focus_widget;
        public KeyFile config_file;
        public int back_button_margin_start = 8;
        public int back_button_margin_top = 6;
        public int split_line_margin_start = 1;
        public int theme_button_padding = 5;
        public int theme_list_margin_bottom = 5;
        public int theme_list_margin_top = 5;
        public int width = Constant.THEME_SLIDER_WIDTH;
        public string config_file_path;
        public Gtk.ScrolledWindow home_page_scrolledwindow = null;

        public delegate void UpdatePageAfterEdit ();

        public ThemePanel (Workspace space, WorkspaceManager manager) {
            Object (orientation: Gtk.Orientation.HORIZONTAL, spacing: 0);
            Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);

            workspace = space;
            workspace_manager = manager;

            config_file = new KeyFile ();
            config_file_path = Utils.get_config_file_path ("theme.conf");

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
            // draw.connect (on_draw);
        }

        // GTK4: 使用 snapshot 虚方法替代 draw
        public override void snapshot (Gtk.Snapshot snapshot) {
            var cr = snapshot.append_cairo ({{0, 0}, {get_width (), get_height ()}});
            on_draw (this, cr);
            cr.get_target ().flush ();
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
            try {
                scrolledwindow = new ScrolledWindow ();
                scrolledwindow.get_style_context ().add_class ("scrolledwindow");
                scrolledwindow.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
                // scrolledwindow.set_shadow_type (Gtk.ShadowType.NONE); // GTK4已废弃
                scrolledwindow.get_vscrollbar ().get_style_context ().add_class ("light_scrollbar");
                home_page_box.append (scrolledwindow);

                realize.connect ((w) => {
                        init_scrollbar ();
                    });

                var theme_name = parent_window.config.config_file.get_string ("general", "theme");
                var theme_list = new ThemeList (theme_name);
                theme_list.margin_top = theme_list_margin_top;
                theme_list.margin_bottom = theme_list_margin_bottom;
                theme_list.active_theme.connect ((active_theme_name) => {
                        parent_window.config.set_theme (active_theme_name);

                        init_scrollbar ();

                        queue_draw ();
                    });

                scrolledwindow.set_child (theme_list);

                switcher.add_to_left_box (home_page_box);

                show.connect ((w) => {
                        GLib.Timeout.add (100, () => {
                                double widget_x = 0, widget_y = 0;
                                theme_list.active_theme_button.translate_coordinates (theme_list, 0, 0, out widget_x, out widget_y);

                                int rect_width = get_width ();
                                int rect_height = get_height ();

                                var adjust = scrolledwindow.get_vadjustment ();
                                adjust.set_value ((int)widget_y - (rect_height - Constant.THEME_BUTTON_HEIGHT) / 2);

                                return false;
                            });
                    });

                show();
            } catch (Error e) {
                print ("ThemePanel show_home_page: %s\n", e.message);
            }
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
                    add_group_item (option, config_file);
                }
            } catch (Error e) {
                if (!FileUtils.test (config_file_path, FileTest.EXISTS)) {
                    print ("ThemePanel create_home_page: %s\n", e.message);
                }
            }

            // GTK4: 暂时注释掉 create_scrolled_window 调用
            // home_page_scrolledwindow = create_scrolled_window ();
            // home_page_box.append (home_page_scrolledwindow);
        }

        public void add_group_item (string option, KeyFile config_file) {
            // 实现添加组项目的逻辑
            // 这里可以根据需要添加具体的实现
        }
    }
}
