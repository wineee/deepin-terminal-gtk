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
    public class ProgressBar : Gtk.Widget {
        public double draw_percent;
        public double percent;
        public int height = 22;
        public Cairo.ImageSurface pointer_surface;
        public Gdk.RGBA background_color;
        public Gdk.RGBA foreground_color;
        public int draw_pointer_offset = 3;
        public int line_height = 2;
        public int line_margin_top = 10;
        public int width = Constant.PREFERENCE_WIDGET_WIDTH;

        public signal void update (double percent);

        public ProgressBar (double init_percent) {
            percent = init_percent;
            set_size_request (width, height);

            foreground_color = Utils.hex_to_rgba ("#2ca7f8");
            background_color = Utils.hex_to_rgba ("#A4A4A4");
            pointer_surface = Utils.create_image_surface ("progress_pointer.svg");

            // 在GTK4中，使用EventController替代事件处理
            var click_controller = new Gtk.GestureClick ();
            click_controller.pressed.connect ((n_press, x, y) => {
                set_percent (x * 1.0 / get_width ());
                return true;
            });

            var motion_controller = new Gtk.EventControllerMotion ();
            motion_controller.motion.connect ((x, y) => {
                set_percent (x * 1.0 / get_width ());
                return true;
            });

            add_controller (click_controller);
            add_controller (motion_controller);

            show_all ();
        }

        public void set_percent (double new_percent) {
            percent = double.max (double.min ((1 - Constant.TERMINAL_MIN_OPACITY) * new_percent + Constant.TERMINAL_MIN_OPACITY, 1), Constant.TERMINAL_MIN_OPACITY);
            draw_percent = double.max (double.min (new_percent, 1), 0);

            update (percent);

            queue_draw ();
        }

        public override void snapshot (Gtk.Snapshot snapshot) {
            var cr = snapshot.append_cairo ({{0, 0}, {get_width (), get_height ()}});

            int left_offset = 0;
            int right_offset = 0;

            // Because pointer surface opacity at side.
            // So we adjust background line offset to avoid user see background line at two side when percent is 0 or 1.
            if (draw_percent == 0) {
                left_offset = pointer_surface.get_width () / 2;
                right_offset = pointer_surface.get_width () / 2;
            } else if (draw_percent == 1) {
                left_offset = 0;
                right_offset = draw_pointer_offset;
            }

            Utils.set_context_color (cr, background_color);
            Draw.draw_rectangle (cr, left_offset, line_margin_top, get_width () - right_offset, line_height);

            if (draw_percent > 0) {
                cr.set_source_rgba (1, 0, 1, 1);
                Utils.set_context_color (cr, foreground_color);
                Draw.draw_rectangle (cr, left_offset, line_margin_top, (int) (get_width () * draw_percent) - right_offset, line_height);
            }

            Draw.draw_surface (cr,
                              pointer_surface,
                              int.max (-draw_pointer_offset,
                                      int.min ((int) (get_width () * draw_percent) - pointer_surface.get_width () / 2 / 2,
                                              get_width () - pointer_surface.get_width () + draw_pointer_offset)),
                              0);
        }
    }
}
