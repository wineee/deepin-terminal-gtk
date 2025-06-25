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
    public class TextButton : Widgets.ClickEventBox {
        public bool is_hover = false;
        public bool is_press = false;
        public Gdk.RGBA text_hover_color;
        public Gdk.RGBA text_normal_color;
        public Gdk.RGBA text_press_color;
        public int button_text_size = 10;
        public int height = 30;
        public string button_text;

        public TextButton (string text, string normal_color_string, string hover_color_string, string press_color_string) {
            set_size_request (-1, height);

            button_text = text;

            text_normal_color = Utils.hex_to_rgba (normal_color_string);
            text_hover_color = Utils.hex_to_rgba (hover_color_string);
            text_press_color = Utils.hex_to_rgba (press_color_string);

            // 使用EventController替代
            var motion_controller = new Gtk.EventControllerMotion ();
            motion_controller.enter.connect ((x, y) => {
                is_hover = true;
                queue_draw ();
            });
            motion_controller.leave.connect (() => {
                is_hover = false;
                queue_draw ();
            });
            add_controller (motion_controller);
            
            var click_controller = new Gtk.GestureClick ();
            click_controller.pressed.connect ((n_press, x, y) => {
                is_press = true;
                queue_draw ();
            });
            click_controller.released.connect ((n_press, x, y) => {
                is_press = false;
                queue_draw ();
            });
            add_controller (click_controller);

            // 在GTK4中，draw已被移除，使用snapshot方法
            // draw.connect (on_draw);
        }

        public override void snapshot (Gtk.Snapshot snapshot) {
            // 在GTK4中，使用snapshot替代draw
            var cr = snapshot.append_cairo ({{0, 0}, {get_width (), get_height ()}});

            if (is_hover) {
                if (is_press) {
                    Utils.set_context_color (cr, text_press_color);
                    Draw.draw_text (cr, button_text, 0, 0, get_width (), get_height (), button_text_size, Pango.Alignment.CENTER);
                } else {
                    Utils.set_context_color (cr, text_hover_color);
                    Draw.draw_text (cr, button_text, 0, 0, get_width (), get_height (), button_text_size, Pango.Alignment.CENTER);
                }
            } else {
                Utils.set_context_color (cr, text_normal_color);
                Draw.draw_text (cr, button_text, 0, 0, get_width (), get_height (), button_text_size, Pango.Alignment.CENTER);
            }
        }
    }

    public TextButton create_link_button (string text) {
        return new TextButton (text, "#0082FA", "#16B8FF", "#0060B9");
    }

    public TextButton create_delete_button (string text) {
        return new TextButton (text, "#FF5A5A", "#FF142D", "#AF0000");
    }
}
