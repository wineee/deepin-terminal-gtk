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
    public class ThemePanel : Gtk.HBox {
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

        public delegate void UpdatePageAfterEdit ();

        public ThemePanel (Workspace space, WorkspaceManager manager) {
            Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);

            workspace = space;
            workspace_manager = manager;

            config_file = new KeyFile ();

            line_dark_color = Utils.hex_to_rgba ("#ffffff", 0.1);
            line_light_color = Utils.hex_to_rgba ("#000000", 0.1);

            focus_widget = ((Gtk.Window) workspace.get_toplevel ()).get_focus ();
            parent_window = (Widgets.ConfigWindow) workspace.get_toplevel ();

            switcher = new Widgets.Switcher (width);

            home_page_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            set_size_request (width, -1);
            home_page_box.set_size_request (width, -1);

            pack_start (switcher, true, true, 0);

            show_home_page ();

            draw.connect (on_draw);
        }

        private bool on_draw (Gtk.Widget widget, Cairo.Context cr) {
            bool is_light_theme = ((Widgets.ConfigWindow) get_toplevel ()).is_light_theme ();

            Gtk.Allocation rect;
            widget.get_allocation (out rect);

            try {
                background_color = Utils.hex_to_rgba (parent_window.config.config_file.get_string ("theme", "background"));
            } catch (Error e) {
                print ("ThemePanel init: %s\n", e.message);
            }
            cr.set_source_rgba (background_color.red, background_color.green, background_color.blue, 0.8);
            Draw.draw_rectangle (cr, 1, 0, rect.width - 1, rect.height);

            if (is_light_theme) {
                Utils.set_context_color (cr, line_light_color);
            } else {
                Utils.set_context_color (cr, line_dark_color);
            }
            Draw.draw_rectangle (cr, 0, 0, 1, rect.height);

            return false;
        }

        public void show_home_page (Gtk.Widget? start_widget=null) {
            try {
                scrolledwindow = new ScrolledWindow (null, null);
                scrolledwindow.get_style_context ().add_class ("scrolledwindow");
                scrolledwindow.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
                scrolledwindow.set_shadow_type (Gtk.ShadowType.NONE);
                scrolledwindow.get_vscrollbar ().get_style_context ().add_class ("light_scrollbar");
                home_page_box.pack_start (scrolledwindow, true, true, 0);

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

                scrolledwindow.add (theme_list);

                switcher.add_to_left_box (home_page_box);

                show.connect ((w) => {
                        GLib.Timeout.add (100, () => {
                                int widget_x, widget_y;
                                theme_list.active_theme_button.translate_coordinates (theme_list, 0, 0, out widget_x, out widget_y);

                                Gtk.Allocation rect;
                                get_allocation (out rect);

                                var adjust = scrolledwindow.get_vadjustment ();
                                adjust.set_value (widget_y - (rect.height - Constant.THEME_BUTTON_HEIGHT) / 2);

                                return false;
                            });
                    });

                show_all ();
            } catch (Error e) {
                print ("ThemePanel show_home_page: %s\n", e.message);
            }
        }

        public void init_scrollbar () {
            scrolledwindow.get_vscrollbar ().get_style_context ().remove_class ("light_scrollbar");
            scrolledwindow.get_vscrollbar ().get_style_context ().remove_class ("dark_scrollbar");
            bool is_light_theme = ((Widgets.ConfigWindow) get_toplevel ()).is_light_theme ();
            if (is_light_theme) {
                scrolledwindow.get_vscrollbar ().get_style_context ().add_class ("light_scrollbar");
            } else {
                scrolledwindow.get_vscrollbar ().get_style_context ().add_class ("dark_scrollbar");
            }
        }
    }
}
