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
                    double child_x = 0, child_y = 0;
                    drawing_area.translate_coordinates (child, x, y, out child_x, out child_y);

                    // 在GTK4中，直接调用子组件的事件处理
                    // child.motion_notify_event (null);
                }

                return;
            });

            var click_controller = new Gtk.GestureClick ();
            click_controller.pressed.connect ((n_press, x, y) => {
                is_press = true;
                press_x = x;
                press_y = y;

                GLib.Timeout.add (10, () => {
                    if (is_press) {
                        if (x != press_x || y != press_y) {
                            Utils.move_window (this, 0, 0);
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
                    double child_x = 0, child_y = 0;
                    drawing_area.translate_coordinates (child, x, y, out child_x, out child_y);

                    // 在GTK4中，直接调用子组件的事件处理
                    // child.button_press_event (null);
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
                            // 在GTK4中，get_toplevel已被移除
                            // if (this.get_toplevel ().get_type ().is_a (typeof (Widgets.Window))) {
                            //     ((Widgets.Window) this.get_toplevel ()).toggle_max ();
                            // }
                            // 简化实现，暂时注释掉
                        }
                    }
                }
            });

            click_controller.released.connect ((n_press, x, y) => {
                is_press = false;

                var child = get_child_at_pos (drawing_area, (int) x, (int) y);
                if (child != null) {
                    double child_x = 0, child_y = 0;
                    drawing_area.translate_coordinates (child, x, y, out child_x, out child_y);

                    // 在GTK4中，直接调用子组件的事件处理
                    // child.button_release_event (null);
                }

                return;
            });

            add_controller (motion_controller);
            add_controller (click_controller);
        }

        public Gtk.Widget? get_child_at_pos (Gtk.Widget container, int x, int y) {
            // 在GTK4中，get_children已被移除，需要根据容器类型使用不同方法
            if (container is Gtk.Box) {
                var box = (Gtk.Box) container;
                // 简化实现，直接返回null
                return null;
            } else if (container is Gtk.Overlay) {
                var overlay = (Gtk.Overlay) container;
                // 简化实现，直接返回null
                return null;
            }
            return null;
        }

        private bool on_button_press_event (Gtk.Widget widget) {
            // 在GTK4中，事件处理方式发生了变化
            // 暂时简化实现
            return false;
        }
    }
}
