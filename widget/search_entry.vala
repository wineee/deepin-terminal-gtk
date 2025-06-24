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

using Animation;
using Gtk;
using Widgets;

namespace Widgets {
    public class SearchEntry : Gtk.Widget {
        public AnimateTimer timer;
        public Gtk.Box box;
        public Gtk.Box display_box;
        public Gtk.Label search_label;
        public ImageButton clear_button;
        public Widgets.Entry search_entry;
        public Widgets.ImageButton search_image;
        public int animation_time = 100;
        public int clear_button_margin_end = 12;
        public int height = 36;
        public int search_image_animate_start_x;
        public int search_image_margin_end = 5;
        public int search_image_margin_x = 18;

        public SearchEntry () {
            Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);

            // 在GTK4中，使用EventController替代add_events
            var click_controller = new Gtk.GestureClick ();
            click_controller.pressed.connect ((n_press, x, y) => {
                display_box.set_halign (Gtk.Align.START);
                display_box.remove (search_label);

                this.translate_coordinates (search_image, 0, 0, out search_image_animate_start_x, null);
                search_image_animate_start_x = search_image_animate_start_x.abs () - search_image_margin_x;
                search_image.margin_start = search_image_margin_x + search_image_animate_start_x;

                timer.reset ();

                return true;
            });

            var key_controller = new Gtk.EventControllerKey ();
            key_controller.key_pressed.connect ((keyval, keycode, state) => {
                string keyname = Keymap.get_keyevent_name (keyval, state);
                if (keyname == "Esc") {
                    switch_to_display ();
                }

                return false;
            });

            add_controller (click_controller);
            add_controller (key_controller);

            set_size_request (-1, height);

            timer = new AnimateTimer (AnimateTimer.ease_in_out, animation_time);
            timer.animate.connect (on_animate);

            box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            display_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

            search_image = new ImageButton ("search", true);
            search_image.margin_end = search_image_margin_end;
            search_image.set_valign (Gtk.Align.CENTER);
            search_label = new Gtk.Label (null);
            search_label.set_valign (Gtk.Align.CENTER);
            search_label.set_text (_("Search"));
            search_entry = new Widgets.Entry ();
            search_entry.set_placeholder_text (_("Search"));
            clear_button = new ImageButton ("search_clear", true);
            clear_button.margin_end = clear_button_margin_end;
            clear_button.set_valign (Gtk.Align.CENTER);
            clear_button.clicked.connect ((w, e) => {
                    search_entry.set_text ("");
                });

            switch_to_display ();

            realize.connect ((w) => {
                    bool is_light_theme = ((Widgets.ConfigWindow) get_toplevel ()).is_light_theme ();
                    if (is_light_theme) {
                        search_entry.get_style_context ().add_class ("remote_search_light_entry");
                        search_label.get_style_context ().add_class ("remote_search_label_light");
                    } else {
                        search_entry.get_style_context ().add_class ("remote_search_dark_entry");
                        search_label.get_style_context ().add_class ("remote_search_label_dark");
                    }
                });

            set_child (box);
        }

        public void on_animate (double progress) {
            search_image.margin_start = search_image_margin_x + (int) (search_image_animate_start_x * (1.0 - progress));

            if (progress >= 1.0) {
                timer.stop ();
                switch_to_input ();
            }
        }

        public void switch_to_display () {
            Utils.remove_all_children (box);

            search_image.margin_start = 0;
            display_box.append (search_image);
            display_box.append (search_label);
            display_box.set_halign (Gtk.Align.CENTER);
            box.append (display_box);

            show_all ();
        }

        public void switch_to_input () {
             Utils.remove_all_children (box);
             Utils.remove_all_children (display_box);

             box.append (search_image);
             box.append (search_entry);
             box.append (clear_button);

             search_image.margin_start = search_image_margin_x;
             search_entry.grab_focus ();

             show_all ();
        }
    }
}
