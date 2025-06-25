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
    public class AboutDialog : Widgets.Dialog {
        public Gtk.Widget? focus_widget;

        public AboutDialog (Gtk.Widget? widget) {
            focus_widget = widget;

            var overlay = new Gtk.Overlay ();

            var close_button = Widgets.create_close_button ();
            close_button.clicked.connect ((b) => {
                    this.destroy ();
                });

            var button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            button_box.append (close_button);

            var box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            box.append (button_box);

            var about_widget = new AboutWidget ();
            box.append (about_widget);

            set_init_size (500, 460);

            int about_text_height = Draw.get_text_render_height (
                about_widget,
                about_widget.about_text,
                window_init_width - about_widget.about_x * 2,
                about_widget.about_height,
                about_widget.about_height,
                Pango.Alignment.LEFT,
                "top",
                window_init_width - about_widget.about_x * 2);

            window_init_height += about_text_height;

            var event_area = new Widgets.WindowEventArea (this);
            event_area.margin_end = Constant.CLOSE_BUTTON_WIDTH;
            event_area.margin_bottom = window_init_height - Constant.TITLEBAR_HEIGHT;

            overlay.set_child (box);
            overlay.add_overlay (event_area);

            add_widget (overlay);
        }
    }
}
