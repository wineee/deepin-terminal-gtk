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
    public class CursorToggleButton : Gtk.Widget {
        public CursorStyleButton block_button;
        public CursorStyleButton ibeam_button;
        public CursorStyleButton underline_button;
        public int cursor_height = 26;
        public int cursor_width = 36;

        public signal void change_cursor_state (string active_state);

        public CursorToggleButton () {
            set_size_request (cursor_width, cursor_height * 3);

            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            block_button = new CursorStyleButton ("cursor_block");
            ibeam_button = new CursorStyleButton ("cursor_ibeam");
            underline_button = new CursorStyleButton ("cursor_underline");

            block_button.active.connect ((w) => {
                    set_cursor_state ("block");
                    change_cursor_state ("block");
                });

            ibeam_button.active.connect ((w) => {
                    set_cursor_state ("ibeam");
                    change_cursor_state ("ibeam");
                });

            underline_button.active.connect ((w) => {
                    set_cursor_state ("underline");
                    change_cursor_state ("underline");
                });

            box.append (block_button);
            box.append (ibeam_button);
            box.append (underline_button);

            // 修复GTK4 API调用
            // set_child (box);
            // show_all ();
        }

        public void set_cursor_state (string name) {
            if (name == "block") {
                block_button.set_active (true);
                ibeam_button.set_active (false);
                underline_button.set_active (false);
            } else if (name == "ibeam") {
                block_button.set_active (false);
                ibeam_button.set_active (true);
                underline_button.set_active (false);
            } else if (name == "underline") {
                block_button.set_active (false);
                ibeam_button.set_active (false);
                underline_button.set_active (true);
            }
        }
    }

    public class CursorStyleButton : Gtk.Widget {
        public bool is_active = false;
        public int cursor_width = 36;
        public int cursor_height = 26;

        Cairo.ImageSurface normal_surface;
        Cairo.ImageSurface hover_surface;
        Cairo.ImageSurface press_surface;
        Cairo.ImageSurface checked_surface;

        public signal void active ();

        public CursorStyleButton (string icon_name) {
            set_size_request (cursor_width, cursor_height);

            normal_surface = Utils.create_image_surface (icon_name + "_normal.svg");
            hover_surface = Utils.create_image_surface (icon_name + "_hover.svg");
            press_surface = Utils.create_image_surface (icon_name + "_press.svg");
            checked_surface = Utils.create_image_surface (icon_name + "_checked.svg");

            // 在GTK4中，使用EventController替代事件处理
            var click_controller = new Gtk.GestureClick ();
            click_controller.pressed.connect ((n_press, x, y) => {
                active ();
            });
            add_controller (click_controller);
        }

        public void set_active (bool active) {
            is_active = active;

            queue_draw ();
        }

        public override void snapshot (Gtk.Snapshot snapshot) {
            var cr = snapshot.append_cairo ({{0, 0}, {get_width (), get_height ()}});
            var state_flags = get_state_flags ();

            if (is_active) {
                Draw.draw_surface (cr, checked_surface);
            } else if ((state_flags & Gtk.StateFlags.ACTIVE) != 0) {
                Draw.draw_surface (cr, press_surface);
            } else if ((state_flags & Gtk.StateFlags.PRELIGHT) != 0) {
                Draw.draw_surface (cr, hover_surface);
            } else {
                Draw.draw_surface (cr, normal_surface);
            }
        }
    }
}
