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
using Utils;

namespace Widgets {
    public class SpinButton : Gtk.Box {
        public Gtk.SpinButton spinbutton;
        public Widgets.EntryMenu menu;

        public SpinButton () {
            Object (orientation: Gtk.Orientation.HORIZONTAL);
            spinbutton = new Gtk.SpinButton (new Gtk.Adjustment (0, 0, 100, 1, 10, 0), 1, 0);
            append (spinbutton);
            
            // 连接信号
            spinbutton.value_changed.connect (() => {
                value_changed ();
            });
            
            spinbutton.input.connect (() => {
                input ();
                return 0;
            });
            
            spinbutton.output.connect (() => {
                output ();
                return true;
            });
            
            spinbutton.wrapped.connect (() => {
                wrapped ();
            });
            
            // 在GTK4中，这些事件信号已被移除
            // button_press_event.connect ((w, e) => {
            //         if (Utils.is_right_button (e)) {
            //             menu = new Widgets.EntryMenu ();
            //             menu.create_entry_menu (this, (int) e.x_root, (int) e.y_root);

            //             return true;
            //         }

            //         return false;
            //     });

            // Prevent scroll event.
            // scroll_event.connect(   (w, e) => {
            //         return true;
            //     });
        }

        // 提供访问内部spinbutton的方法
        public Gtk.Adjustment adjustment {
            get { return spinbutton.adjustment; }
            set { spinbutton.adjustment = value; }
        }

        public void set_range (double min, double max) {
            spinbutton.set_range (min, max);
        }

        public void set_increments (double step, double page) {
            spinbutton.set_increments (step, page);
        }

        public void set_digits (uint digits) {
            spinbutton.set_digits (digits);
        }

        public void set_numeric (bool numeric) {
            spinbutton.set_numeric (numeric);
        }

        public void set_wrap (bool wrap) {
            spinbutton.set_wrap (wrap);
        }

        public void set_snap_to_ticks (bool snap_to_ticks) {
            spinbutton.set_snap_to_ticks (snap_to_ticks);
        }

        public void set_update_policy (Gtk.SpinButtonUpdatePolicy policy) {
            spinbutton.set_update_policy (policy);
        }

        public void spin (Gtk.SpinType direction, double increment) {
            spinbutton.spin (direction, increment);
        }

        public void update () {
            spinbutton.update ();
        }

        public void set_value (double value) {
            spinbutton.value = value;
        }

        public double get_value () {
            return spinbutton.value;
        }

        public string get_text () {
            return spinbutton.text;
        }

        public signal void value_changed ();
        public signal void input ();
        public signal void output ();
        public signal void wrapped ();
    }
}
