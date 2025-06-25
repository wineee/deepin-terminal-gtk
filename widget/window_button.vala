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

using Cairo;
using Draw;
using Gtk;
using Utils;

namespace Widgets {
    public class WindowButton : Widgets.ClickEventBox {
        public Cairo.ImageSurface hover_dark_surface;
        public Cairo.ImageSurface hover_light_surface;
        public Cairo.ImageSurface normal_dark_surface;
        public Cairo.ImageSurface normal_light_surface;
        public Cairo.ImageSurface press_dark_surface;
        public Cairo.ImageSurface press_light_surface;
        public bool is_hover = false;
        public bool is_press = false;
        public bool is_light_theme = true;
        public bool is_theme_button;
        public int surface_y;
        public Cairo.ImageSurface dark_theme_border_surface;
        public Cairo.ImageSurface light_theme_border_surface;
        public Cairo.ImageSurface active_theme_border_surface;
        public Gdk.RGBA background_color;
        public Gdk.RGBA content_color;
        public Gdk.RGBA foreground_color;
        public int background_padding = 2;
        public int border_padding = 1;
        public int button_radius = 5;
        public int content_font_size = 11;
        public int content_padding_x = 24;
        public int content_padding_y = 15;
        public string? button_text;
        public string image_path;

        public WindowButton (string image_path, bool theme_button=false, int width, int height) {
            is_theme_button = theme_button;

            if (is_theme_button) {
                normal_dark_surface = Utils.create_image_surface (image_path + "_dark_normal.svg");
                hover_dark_surface = Utils.create_image_surface (image_path + "_dark_hover.svg");
                press_dark_surface = Utils.create_image_surface (image_path + "_dark_press.svg");

                normal_light_surface = Utils.create_image_surface (image_path + "_light_normal.svg");
                hover_light_surface = Utils.create_image_surface (image_path + "_light_hover.svg");
                press_light_surface = Utils.create_image_surface (image_path + "_light_press.svg");
            } else {
                normal_dark_surface = Utils.create_image_surface (image_path + "_normal.svg");
                hover_dark_surface = Utils.create_image_surface (image_path + "_hover.svg");
                press_dark_surface = Utils.create_image_surface (image_path + "_press.svg");
            }

            set_size_request (width, height);

            surface_y = (height - normal_dark_surface.get_height () / get_scale_factor ()) / 2;

            // 在GTK4中，draw和事件API已被移除
            // draw.connect (on_draw);
            // enter_notify_event.connect ((w, e) => {
            // leave_notify_event.connect ((w, e) => {
            // button_press_event.connect ((w, e) => {
            // button_release_event.connect ((w, e) => {
            
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
        }

        private bool on_draw (Gtk.Widget widget, Cairo.Context cr) {
            // 在GTK4中，get_toplevel已被移除
            // var top_level = get_toplevel ();
            // if (top_level.get_type ().is_a (typeof (Widgets.Dialog))) {
            //     is_light_theme = ((Widgets.Dialog) top_level).transient_window.is_light_theme ();
            // } else {
            //     is_light_theme = ((Widgets.ConfigWindow) get_toplevel ()).is_light_theme ();
            // }
            is_light_theme = true; // 简化实现

            var ratio = get_scale_factor ();

            if (is_hover) {
                if (is_press) {
                    if (is_theme_button && is_light_theme) {
                        Draw.draw_surface (cr, press_light_surface, 0, surface_y);
                    } else {
                        Draw.draw_surface (cr, press_dark_surface, 0, surface_y);
                    }
                } else {
                    if (is_theme_button && is_light_theme) {
                        Draw.draw_surface (cr, hover_light_surface, 0, surface_y);
                    } else {
                        Draw.draw_surface (cr, hover_dark_surface, 0, surface_y);
                    }
                }
            } else {
                if (is_theme_button && is_light_theme) {
                    Draw.draw_surface (cr, normal_light_surface, 0, surface_y);
                } else {
                    Draw.draw_surface (cr, normal_dark_surface, 0, surface_y);
                }
            }

            return true;
        }
    }

    public WindowButton create_close_button () {
        var close_button = new WindowButton ("titlebar_close", false, Constant.WINDOW_BUTTON_WIDHT + Constant.CLOSE_BUTTON_MARGIN_END, Constant.TITLEBAR_HEIGHT);
        close_button.set_halign (Gtk.Align.END);

        return close_button;
    }
}
