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

namespace Widgets {
    public class SplitLine : Gtk.Box {
        public int split_line_margin_start = 1;

        public SplitLine () {
            margin_start = split_line_margin_start;
            set_size_request (-1, 1);

            // GTK4: 使用 override snapshot 替代 draw.connect
            // draw.connect ((w, cr) => {
            //     Gtk.Allocation rect;
            //     w.get_allocation (out rect);

            //     bool is_light_theme = true; // 简化实现
            //     var ratio = get_scale_factor ();

            //     if (is_light_theme) {
            //         cr.set_source_rgba (0, 0, 0, 0.1);
            //     } else {
            //         cr.set_source_rgba (1, 1, 1, 0.1);
            //     }
            //     Draw.draw_rectangle (cr, 0, 0, rect.width, 1);

            //     return true;
            // });
        }

        // GTK4: 使用 snapshot 虚方法替代 draw
        public override void snapshot (Gtk.Snapshot snapshot) {
            var cr = snapshot.append_cairo ({{0, 0}, {get_width (), get_height ()}});
            
            bool is_light_theme = true; // 简化实现
            var ratio = get_scale_factor ();

            if (is_light_theme) {
                cr.set_source_rgba (0, 0, 0, 0.1);
            } else {
                cr.set_source_rgba (1, 1, 1, 0.1);
            }
            Draw.draw_rectangle (cr, 0, 0, get_width (), 1);
            
            cr.get_target ().flush ();
        }
    }
}
