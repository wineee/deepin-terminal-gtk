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
    public class Dialog : Gtk.Window {
        public new Gdk.Display display;
        public Gtk.Box window_frame_box;
        public Gtk.Box window_widget_box;
        public Widgets.ConfigWindow transient_window;
        public new int option_widget_margin_end = 5;
        public new int option_widget_margin_top = 5;
        public int window_frame_margin_bottom = 60;
        public int window_frame_margin_end = 50;
        public int window_frame_margin_start = 50;
        public int window_frame_margin_top = 50;
        public int window_frame_radius = 5;
        public int window_init_height;
        public int window_init_width;

        public Dialog () {
            // GTK4: set_app_paintable 已被移除，透明度通过CSS处理
            display = Gdk.Display.get_default ();

            // GTK4: 这些方法已被移除，使用CSS或其他方式处理
            set_modal (true);
            set_resizable (false);
            set_decorated (false);

            window_frame_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            window_widget_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            window_frame_box.append (window_widget_box);

            // GTK4: 使用 EventController 替代信号连接
            var focus_controller = new Gtk.EventControllerFocus ();
            focus_controller.enter.connect (() => {
                window_frame_box.get_style_context ().remove_class ("dialog_shadow_inactive");
                window_frame_box.get_style_context ().add_class ("dialog_shadow_active");
                window_frame_box.get_style_context ().remove_class ("dialog_noshadow_inactive");
                window_frame_box.get_style_context ().add_class ("dialog_noshadow_active");
            });
            focus_controller.leave.connect (() => {
                window_frame_box.get_style_context ().remove_class ("dialog_shadow_active");
                window_frame_box.get_style_context ().add_class ("dialog_shadow_inactive");
                window_frame_box.get_style_context ().remove_class ("dialog_noshadow_active");
                window_frame_box.get_style_context ().add_class ("dialog_noshadow_inactive");
            });

            var key_controller = new Gtk.EventControllerKey ();
            key_controller.key_pressed.connect ((keyval, keycode, state) => {
                if (keyval == Gdk.Key.Escape) {
                    close ();
                }
                return false;
            });

            // GTK4: 使用 override snapshot 替代 snapshot.connect
            // this.snapshot.connect ((snapshot) => {
            //     on_draw (this, snapshot);
            // });
        }

        public void set_init_size (int width, int height) {
            // 在GTK4中，合成检测需要不同的方法
            bool is_composited = true; // 假设现代桌面环境都支持合成
            if (!is_composited) {
                window_init_width = width - window_frame_margin_start - window_frame_margin_end;
                window_init_height = height - window_frame_margin_top - window_frame_margin_bottom;
            } else {
                window_init_width = width;
                window_init_height = height;
            }
        }

        public void transient_for_window (Widgets.ConfigWindow window) {
            transient_window = window;

            set_default_size (window_init_width, window_init_height);

            set_transient_for (window);
            
            // GTK4: get_position 已被移除，使用其他方法
            // int x, y;
            // window.get_position (out x, out y);
            int window_width = window.get_width ();
            int window_height = window.get_height ();

            // GTK4: set_position 已被移除，使用其他方法
            // set_position (Gtk.WindowPosition.CENTER_ON_PARENT);
        }

        public void shadow_active () {
            // 在GTK4中，合成检测需要不同的方法
            bool is_composited = true; // 假设现代桌面环境都支持合成
            if (is_composited) {
                window_frame_box.get_style_context ().remove_class ("dialog_shadow_inactive");
                window_frame_box.get_style_context ().add_class ("dialog_shadow_active");
            } else {
                window_frame_box.get_style_context ().remove_class ("dialog_noshadow_inactive");
                window_frame_box.get_style_context ().add_class ("dialog_noshadow_active");
            }
        }

        public void shadow_inactive () {
            // 在GTK4中，合成检测需要不同的方法
            bool is_composited = true; // 假设现代桌面环境都支持合成
            if (is_composited) {
                window_frame_box.get_style_context ().remove_class ("dialog_shadow_active");
                window_frame_box.get_style_context ().add_class ("dialog_shadow_inactive");
            } else {
                window_frame_box.get_style_context ().remove_class ("dialog_noshadow_active");
                window_frame_box.get_style_context ().add_class ("dialog_noshadow_inactive");
            }
        }

        public void draw_window_widgets (Cairo.Context cr) {
            Utils.propagate_draw (this, cr);
        }

        public void add_widget (Gtk.Widget widget) {
            window_widget_box.append (widget);
        }

        public void draw_window_below (Cairo.Context cr) {
            // GTK4: get_allocation 已被移除，使用 get_width/get_height
            int width = window_frame_box.get_width ();
            int height = window_frame_box.get_height ();

            cr.set_source_rgba (1, 1, 1, 1);
            // 在GTK4中，合成检测需要不同的方法
            bool is_composited = true; // 假设现代桌面环境都支持合成
            if (is_composited) {
                Draw.fill_rounded_rectangle (cr, window_frame_margin_start, window_frame_margin_top, width, height, window_frame_radius);
            } else {
                Draw.fill_rounded_rectangle (cr, 0, 0, width, height, 0);
            }
        }

        public void grid_attach (Gtk.Grid grid, Gtk.Widget child, int left, int top, int width, int height) {
            child.margin_top = option_widget_margin_top;
            child.margin_bottom = option_widget_margin_end;
            grid.attach (child, left, top, width, height);
        }

        public void grid_attach_next_to (Gtk.Grid grid, Gtk.Widget child, Gtk.Widget sibling, Gtk.PositionType side, int width, int height) {
            child.margin_top = option_widget_margin_top;
            child.margin_bottom = option_widget_margin_end;
            grid.attach_next_to (child, sibling, side, width, height);
        }

        public void draw_window_frame (Cairo.Context cr) {

        }

        public void update_frame () {
            // 在GTK4中，合成检测需要不同的方法
            bool is_composited = true; // 假设现代桌面环境都支持合成
            if (is_composited) {
                // GTK4: set_shadow_width 已被移除，使用CSS处理阴影
                window_frame_box.margin_top = window_frame_margin_top;
                window_frame_box.margin_bottom = window_frame_margin_bottom;
                window_frame_box.margin_start = window_frame_margin_start;
                window_frame_box.margin_end = window_frame_margin_end;
            } else {
                // GTK4: set_shadow_width 已被移除，使用CSS处理阴影
                window_frame_box.margin_top = 0;
                window_frame_box.margin_bottom = 0;
                window_frame_box.margin_start = 0;
                window_frame_box.margin_end = 0;
            }

            window_widget_box.margin_top = 0;
            window_widget_box.margin_bottom = 0;
            window_widget_box.margin_start = 0;
            window_widget_box.margin_end = 0;
        }

        public virtual void draw_window_above (Cairo.Context cr) {

        }
    }
}
