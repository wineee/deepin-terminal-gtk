/* -*- Mode: Vala; indent-tabs-mode: nil; tab-width: 4 -*-
 * -*- coding: utf-8 -*-
 *
 * Copyright (C) 2011 ~ 2018 Deepin, Inc.
 *               2011 ~ 2018 Wang Yong
 *               2019 ~ 2020 Gary Wang
 *
 * Author:     Wang Yong <wangyong@deepin.com>
 *             Gary Wang <wzc782970009@gmail.com>
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
    public class WindowEventArea : Gtk.Widget {
        public FilterDoubleClick? filter_double_click_callback = null;
        public Gtk.Widget drawing_area;
        public Gtk.Widget? child_before_leave;
        public bool is_double_clicked = false;
        public bool is_press = false;
        public double press_x = 0;
        public double press_y = 0;
        public int double_clicked_max_delay = 150;

        public delegate bool FilterDoubleClick (int x, int y);

        public WindowEventArea (Gtk.Widget area) {
            drawing_area = area;

            // 在GTK4中，使用EventController替代add_events
            var motion_controller = new Gtk.EventControllerMotion ();
            motion_controller.motion.connect ((x, y) => {
                var child = get_child_at_pos (drawing_area, (int) x, (int) y);
                child_before_leave = child;

                if (child != null) {
                    int child_x, child_y;
                    drawing_area.translate_coordinates (child, (int) x, (int) y, out child_x, out child_y);

                    // 在GTK4中，直接调用子组件的事件处理
                    child.motion_notify_event (null);
                }

                return true;
            });

            var click_controller = new Gtk.GestureClick ();
            click_controller.pressed.connect ((n_press, x, y) => {
                is_press = true;
                press_x = x;
                press_y = y;

                GLib.Timeout.add (10, () => {
                    if (is_press) {
                        if (x != press_x || y != press_y) {
                            Utils.move_window (this, null);
                            return false;
                        } else {
                            return true;
                        }
                    } else {
                        return false;
                    }
                });

                var child = get_child_at_pos (drawing_area, (int) x, (int) y);
                if (child != null) {
                    int child_x, child_y;
                    drawing_area.translate_coordinates (child, (int) x, (int) y, out child_x, out child_y);

                    // 在GTK4中，直接调用子组件的事件处理
                    child.button_press_event (null);
                }

                if (n_press == 1) {
                    is_double_clicked = true;

                    // Add timeout to avoid long-long-long time double clicked to cause toggle maximize action.
                    GLib.Timeout.add(   double_clicked_max_delay, () => {
                            is_double_clicked = false;

                            return false;
                        });
                } else if (n_press == 2) {
                    if (is_double_clicked) {
                        if (filter_double_click_callback == null || !filter_double_click_callback ((int) x, (int) y)) {
                            if (this.get_toplevel ().get_type ().is_a (typeof (Widgets.Window))) {
                                ((Widgets.Window) this.get_toplevel ()).toggle_max ();
                            }
                        }
                    }
                }

                return true;
            });

            click_controller.released.connect ((n_press, x, y) => {
                is_press = false;

                var child = get_child_at_pos (drawing_area, (int) x, (int) y);
                if (child != null) {
                    int child_x, child_y;
                    drawing_area.translate_coordinates (child, (int) x, (int) y, out child_x, out child_y);

                    // 在GTK4中，直接调用子组件的事件处理
                    child.button_release_event (null);
                }

                return true;
            });

            add_controller (motion_controller);
            add_controller (click_controller);
        }

        public Gtk.Widget? get_child_at_pos (Gtk.Widget container, int x, int y) {
            if (container.get_children ().length () > 0) {
                foreach (Gtk.Widget child in container.get_children ()) {
                    // 在GTK4中，使用get_width()和get_height()
                    int child_width = child.get_width ();
                    int child_height = child.get_height ();

                    int child_x, child_y;
                    child.translate_coordinates (container, 0, 0, out child_x, out child_y);

                    if (x >= child_x && x <= child_x + child_width && y >= child_y && y <= child_y + child_height) {
                        return child;
                    }
                }
            }

            return null;
        }
    }
}
