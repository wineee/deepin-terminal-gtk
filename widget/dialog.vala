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
        public Gdk.Display display;
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
            set_app_paintable (true); // set_app_paintable is necessary step to make window transparent.
            display = Gdk.Display.get_default ();
            // 在GTK4中，set_visual已被移除，透明度通过CSS处理

            set_skip_taskbar_hint (true);
            set_skip_pager_hint (true);
            set_modal (true);
            set_resizable (false);
            set_type_hint (Gdk.WindowTypeHint.DIALOG);  // DIALOG hint will give right window effect

            set_decorated (false);

            window_frame_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            window_widget_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            add (window_frame_box);
            window_frame_box.pack_start (window_widget_box, true, true, 0);

            // 在GTK4中，composited_changed信号已被移除，我们需要使用其他方法检测合成

            focus_in_event.connect ((w) => {
                    shadow_active ();

                    return false;
                });

            focus_out_event.connect ((w) => {
                    shadow_inactive ();

                    return false;
                });

            configure_event.connect ((w) => {
                    int width, height;
                    get_size (out width, out height);

                    // 在GTK4中，合成检测需要不同的方法
                    bool is_composited = true; // 假设现代桌面环境都支持合成
                    if (is_composited) {
                        Cairo.RectangleInt rect;
                        get_window ().get_frame_extents (out rect);

                        rect.x = window_frame_margin_start;
                        rect.y = window_frame_margin_top;
                        rect.width = width - window_frame_margin_start - window_frame_margin_end;
                        rect.height = height - window_frame_margin_top - window_frame_margin_bottom;

                        var shape = new Cairo.Region.rectangle (rect);
                        get_window ().input_shape_combine_region (shape, 0, 0);
                    }

                    queue_draw ();

                    return false;
                });

            window_state_event.connect ((w, e) => {
                    update_frame ();

                    return false;
                });


            key_press_event.connect ((w, e) => {
                    string keyname = Keymap.get_keyevent_name (e.keyval, e.state);
                    if (keyname == "Esc") {
                        this.destroy ();
                    }

                    return false;
                });

            draw.connect_after ((w, cr) => {
                    draw_window_below (cr);

                    draw_window_widgets (cr);

                    draw_window_frame (cr);

                    draw_window_above (cr);

                    return true;
                });
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
            
            // 在GTK4中，使用不同的方法获取窗口位置
            int x, y;
            window.get_position (out x, out y);
            int window_width, window_height;
            window.get_size (out window_width, out window_height);

            move (x + (window_width - window_init_width) / 2,
                 y + (window_height - window_init_height) / 2);

            show_all ();
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
            window_widget_box.pack_start (widget, true, true, 0);
        }

        public void draw_window_below (Cairo.Context cr) {
            Gtk.Allocation window_rect;
            window_frame_box.get_allocation (out window_rect);

            cr.set_source_rgba (1, 1, 1, 1);
            // 在GTK4中，合成检测需要不同的方法
            bool is_composited = true; // 假设现代桌面环境都支持合成
            if (is_composited) {
                Draw.fill_rounded_rectangle (cr, window_frame_margin_start, window_frame_margin_top, window_rect.width, window_rect.height, window_frame_radius);
            } else {
                Draw.fill_rounded_rectangle (cr, 0, 0, window_rect.width, window_rect.height, 0);
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
                get_window ().set_shadow_width (window_frame_margin_start, window_frame_margin_end, window_frame_margin_top, window_frame_margin_bottom);

                window_frame_box.margin_top = window_frame_margin_top;
                window_frame_box.margin_bottom = window_frame_margin_bottom;
                window_frame_box.margin_start = window_frame_margin_start;
                window_frame_box.margin_end = window_frame_margin_end;
            } else {
                get_window ().set_shadow_width (0, 0, 0, 0);

                window_frame_box.margin_top = 0;
                window_frame_box.margin_bottom = 0;
                window_frame_box.margin_start = 0;
                window_frame_box.margin_end = 0;
            }

            window_widget_box.margin = 0;
        }

        public virtual void draw_window_above (Cairo.Context cr) {

        }
    }
}
