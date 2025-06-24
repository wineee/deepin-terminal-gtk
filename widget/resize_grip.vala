/* -*- Mode: Vala; indent-tabs-mode: nil; tab-width: 4 -*-
 * -*- coding: utf-8 -*-
 *
 * Copyright (C) 2019 Deepin, Inc.
 *               2019 Gary Wang
 *
 * Author:     Gary Wang <wzc782970009@gmail.com>
 * Maintainer: Gary Wang <wzc782970009@gmail.com>
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

// This is pretty dirty workaround to make the window resizable under not composited window manager.
// Feel free to submit a patch if you have better solution.

namespace Widgets {
    private static int GRIP_WIDTH = 8;
    public static int GRIP_HEIGHT = 8;

    public class Grip : Gtk.Widget {

        public Cairo.ImageSurface resize_grip_surface;
        public int surface_y;

        public signal void clicked ();

        public Grip () {

            resize_grip_surface = Utils.create_image_surface ("resize_grip.svg");
            set_size_request (GRIP_WIDTH, GRIP_HEIGHT);
            surface_y = (GRIP_HEIGHT - resize_grip_surface.get_height () / get_scale_factor ()) / 2;

            // 在GTK4中，使用EventController替代事件处理
            var motion_controller = new Gtk.EventControllerMotion ();
            motion_controller.enter.connect ((x, y) => {
                // set cursor.
                get_native ().get_surface ().set_cursor (new Gdk.Cursor.for_name ("se-resize"));
                return true;
            });

            motion_controller.leave.connect (() => {
                // set cursor back.
                get_native ().get_surface ().set_cursor (null);
                return true;
            });

            var click_controller = new Gtk.GestureClick ();
            click_controller.pressed.connect ((n_press, x, y) => {
                get_native ().begin_resize (Gdk.SurfaceEdge.SOUTH_EAST, null, x, y);
                clicked ();
                return true;
            });

            add_controller (motion_controller);
            add_controller (click_controller);
        }

        public override void snapshot (Gtk.Snapshot snapshot) {
            var cr = snapshot.append_cairo ({{0, 0}, {GRIP_WIDTH, GRIP_HEIGHT}});
            Draw.draw_surface (cr, resize_grip_surface, 0, surface_y);
        }
    }

    public class ResizeGrip : Gtk.Overlay {
        public Widgets.WindowEventArea event_area;
        public Widgets.Window window;
        public Grip grip;

        public ResizeGrip (Widgets.Window win) {

            window = win;

            grip = new Widgets.Grip ();
            grip.set_halign (Gtk.Align.END);

            Box box = new Box (Gtk.Orientation.HORIZONTAL, 0);
            box.append (grip);

            event_area = new Widgets.WindowEventArea (this);
            event_area.margin_end = Constant.CLOSE_BUTTON_WIDTH;

            add (box);
            add_overlay (event_area);

            set_size_request (-1, GRIP_HEIGHT);

            Gdk.RGBA background_color = Gdk.RGBA ();

            box.snapshot.connect ((snapshot) => {
                // 在GTK4中，使用snapshot替代draw
                var cr = snapshot.append_cairo ({{0, 0}, {get_width (), get_height ()}});

                try {
                    background_color = Utils.hex_to_rgba (window.config.config_file.get_string ("theme", "background"));
                    cr.set_source_rgba (background_color.red, background_color.green, background_color.blue, window.config.config_file.get_double ("general", "opacity"));
                    Draw.draw_rectangle (cr, 0, 0, get_width (), get_height ());
                } catch (Error e) {
                    print ("ResizeGrip draw: %s\n", e.message);
                }

                Utils.propagate_draw (box, cr);

                return true;
            });
        }
    }
}
