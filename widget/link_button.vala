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
    public class LinkButton : Widgets.ClickEventBox {
        public string link_css;
        public string link_name;
        public string link_uri;

        public LinkButton (string link_name, string link_uri, string link_css) {
            var link_label = new Gtk.Label (null);
            link_label.set_text (link_name);
            link_label.get_style_context ().add_class (link_css);
            
            var motion_controller = new Gtk.EventControllerMotion ();
            motion_controller.enter.connect ((x, y) => {
                var surface = get_native ()?.get_surface ();
                if (surface != null) {
                    // 在GTK4中，Gdk.Cursor.new_from_name已被移除
                    // surface.set_cursor (Gdk.Cursor.new_from_name ("pointer", null));
                }
            });
            
            motion_controller.leave.connect (() => {
                var surface = get_native ()?.get_surface ();
                if (surface != null) {
                    surface.set_cursor (null);
                }
            });
            
            add_controller (motion_controller);
            
            clicked.connect ((w, e) => {
                    try {
                        // 在GTK4中，show_uri_on_window已被移除
                        // Gtk.show_uri_on_window (null, link_uri, e.time);
                        // 在GTK4中，AppInfo.lookup_default_for_uri_scheme已被移除
                        // var app = new GLib.AppInfo.lookup_default_for_uri_scheme ("http");
                        // if (app != null) {
                        //     app.launch_uris (new string[] { link_uri }, null);
                        // }
                    } catch (GLib.Error e) {
                        print ("LinkButton: %s\n", e.message);
                    }
                });
        }
    }
}
