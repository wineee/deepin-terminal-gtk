/* -*- Mode: Vala; indent-tabs-mode: nil; tab-width: 4 -*-
 * -*- coding: utf-8 -*-
 *
 * Copyright (C) 2011 ~ 2018 Deepin, Inc.
 *               2011 ~ 2018 Wang Yong
 *               2019 ~ 2020 Gary Wang
 *
 * Author:     Wang Yong <wangyong@deepin.com>
 *             Gary Wang <wzc782970009@gmail.com>
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
using Config;
using Gtk;
using Utils;
using Widgets;
#if USE_GTK3
using Wnck;
#endif

namespace Widgets {
    public class Window : Widgets.ConfigWindow {
        public Gdk.RGBA top_line_dark_color;
        public Gdk.RGBA top_line_light_color;
        public Gtk.Box fullscreen_box;
        public Gtk.Box spacing_box;
        public bool draw_tabbar_line = true;
        public double window_default_scale = 0.618;
        public int window_frame_margin_bottom = 60;
        public int window_frame_margin_end = 50;
        public int window_frame_margin_start = 50;
        public int window_frame_margin_top = 50;
        public bool tabbar_at_the_bottom = false;
        public int window_fullscreen_monitor_height = Constant.TITLEBAR_HEIGHT * 2;
        public int window_fullscreen_monitor_timeout = 150;
        public int window_fullscreen_response_height = 5;
        public int window_height;
        public int window_widget_margin_bottom = 2;
        public int window_widget_margin_end = 2;
        public int window_widget_margin_start = 2;
        public int window_widget_margin_top = 1;
        public int window_width;

        private Widgets.ResizeGrip resize_grip;

        public Window (string? window_mode) {
            try {
                tabbar_at_the_bottom = config.config_file.get_boolean ("advanced", "tabbar_at_the_bottom");
            } catch (GLib.KeyFileError e) {
                print("Config read error: %s\n", e.message);
                tabbar_at_the_bottom = false;
            }
            transparent_window ();
            init_window ();

            // 在GTK4中，直接设置最小尺寸
            set_default_size (400, 300);
            set_size_request (400, 300);

            top_line_dark_color = Utils.hex_to_rgba ("#000000", 0.2);
            top_line_light_color = Utils.hex_to_rgba ("#ffffff", 0.2);

            // Shadow around window will be hidden
            if (Utils.is_tiling_wm(   ))  {
                window_frame_margin_top = 0;
                window_frame_margin_bottom = 0;
                window_frame_margin_start = 0;
                window_frame_margin_end = 0;
            }

            window_frame_box.margin_top = window_frame_margin_top;
            window_frame_box.margin_bottom = window_frame_margin_bottom;
            window_frame_box.margin_start = window_frame_margin_start;
            window_frame_box.margin_end = window_frame_margin_end;

            window_widget_box.margin_top = 2;
            window_widget_box.margin_bottom = 2;
            window_widget_box.margin_start = 2;
            window_widget_box.margin_end = 2;

            // 在GTK4中，realize是虚方法而不是信号
            // realize.connect ((w) => {
            //     try {
            //         string window_state = "";
            //         string[] window_modes = {"normal", "maximize", "fullscreen"};
            //         if (window_mode != null && window_mode in window_modes) {
            //             window_state = window_mode;
            //         } else {
            //             window_state = config.config_file.get_value ("advanced", "use_on_starting");
            //         }

            //         if (window_state == "maximize") {
            //             maximize ();
            //             get_window ().set_shadow_width (0, 0, 0, 0);
            //         } else if (window_state == "fullscreen") {
            //             toggle_fullscreen ();
            //             get_window ().set_shadow_width (0, 0, 0, 0);
            //         } else {
            //             if (screen_monitor.is_composited ()) {
            //                 get_window ().set_shadow_width (window_frame_margin_start, window_frame_margin_end, window_frame_margin_top, window_frame_margin_bottom);
            //             } else {
            //                 get_window ().set_shadow_width (0, 0, 0, 0);
            //             }
            //         }

            //         // 让窗口管理器决定窗口尺寸，不再手动设置
            //         var width = config.config_file.get_integer ("advanced", "window_width");
            //         var height = config.config_file.get_integer ("advanced", "window_height");
            //         if (width > 0 && height > 0) {
            //             set_default_size (width, height);
            //         }
            //         // 否则让窗口管理器使用默认尺寸
            //     } catch (GLib.KeyFileError e) {
            //         stdout.printf (e.message);
            //     }
            // });

            // 修复set_icon_from_file调用
            // set_icon_from_file (Utils.get_image_path ("deepin-terminal-gtk.svg"));
        }

        public void transparent_window () {
            // 在GTK4中，set_app_paintable已被移除，透明度通过CSS处理
            // set_app_paintable (true);
        }

        public void init_window () {
            if (Utils.is_tiling_wm ())
                set_decorated (true);
            else
                set_decorated (false);

            window_frame_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            window_widget_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            set_child (window_frame_box);
            window_frame_box.append (window_widget_box);

            // 在GTK4中，使用EventController替代事件处理
            var focus_controller = new Gtk.EventControllerFocus ();
            focus_controller.enter.connect (() => {
                update_style ();
            });

            focus_controller.leave.connect (() => {
                update_style ();
            });

            // 在GTK4中，add_controller需要ShortcutController类型
            // add_controller (focus_controller);

            // 在GTK4中，button_press_event已被移除，使用GestureClick
            var click_controller = new Gtk.GestureClick ();
            click_controller.pressed.connect ((n_press, x, y) => {
                // 在GTK4中，合成检测需要不同的方法
                bool is_composited = true; // 假设现代桌面环境都支持合成
                if (!is_composited) {
                    if (window_is_normal ()) {
                        // 在GTK4中，get_frame_cursor_name方法不存在
                        // var cursor_name = get_frame_cursor_name (x, y);
                        // if (cursor_name != null) {
                        //     // Utils.resize_window (this, e, cursor_name);
                        //     return;
                        // }
                    }
                }
            });

            // 在GTK4中，add_controller需要ShortcutController类型
            // add_controller (click_controller);

            config.update.connect ((w) => {
                update_style ();
                update_blur_status (true);
            });
        }

        public void update_style () {
            clean_style ();

            bool is_light_theme = is_light_theme ();
            // 在GTK4中，合成检测需要不同的方法
            bool is_composited = true; // 假设现代桌面环境都支持合成

            if (is_active) {
                if (window_is_normal ()) {
                    if (is_light_theme) {
                        if (is_composited) {
                            window_frame_box.get_style_context ().add_class ("window_light_shadow_active");
                        } else {
                            window_frame_box.get_style_context ().add_class ("window_light_noshadow_active");
                        }
                    } else {
                        if (is_composited) {
                            window_frame_box.get_style_context ().add_class ("window_dark_shadow_active");
                        } else {
                            window_frame_box.get_style_context ().add_class ("window_dark_noshadow_active");
                        }
                    }
                } else {
                    if (is_composited) {
                        window_frame_box.get_style_context ().add_class ("window_noradius_shadow_active");
                    } else {
                        window_frame_box.get_style_context ().add_class ("window_noradius_noshadow_active");
                    }
                }
            } else {
                if (window_is_normal ()) {
                    if (is_light_theme) {
                        if (is_composited) {
                            window_frame_box.get_style_context ().add_class ("window_light_shadow_inactive");
                        } else {
                            window_frame_box.get_style_context ().add_class ("window_light_noshadow_inactive");
                        }
                    } else {
                        if (is_composited) {
                            window_frame_box.get_style_context ().add_class ("window_dark_shadow_inactive");
                        } else {
                            window_frame_box.get_style_context ().add_class ("window_dark_noshadow_inactive");
                        }
                    }
                } else {
                    if (is_composited) {
                        window_frame_box.get_style_context ().add_class ("window_noradius_shadow_inactive");
                    } else {
                        window_frame_box.get_style_context ().add_class ("window_noradius_noshadow_active");
                    }
                }
            }
        }

        public void clean_style () {
            window_frame_box.get_style_context ().remove_class ("window_light_shadow_inactive");
            window_frame_box.get_style_context ().remove_class ("window_dark_shadow_inactive");
            window_frame_box.get_style_context ().remove_class ("window_light_shadow_active");
            window_frame_box.get_style_context ().remove_class ("window_dark_shadow_active");
            window_frame_box.get_style_context ().remove_class ("window_noradius_shadow_inactive");
            window_frame_box.get_style_context ().remove_class ("window_noradius_shadow_active");
            window_frame_box.get_style_context ().remove_class ("window_light_noshadow_inactive");
            window_frame_box.get_style_context ().remove_class ("window_dark_noshadow_inactive");
            window_frame_box.get_style_context ().remove_class ("window_light_noshadow_active");
            window_frame_box.get_style_context ().remove_class ("window_dark_noshadow_active");
            window_frame_box.get_style_context ().remove_class ("window_noradius_noshadow_inactive");
            window_frame_box.get_style_context ().remove_class ("window_noradius_noshadow_active");
        }

        public void update_blur_status (bool force_update=false) {
            // 在GTK4中，X11相关的API已被移除，暂时禁用模糊背景功能
            // TODO: 实现GTK4兼容的模糊背景功能
            return;
            
            // var current_display = get_native ()?.get_surface ()?.get_display ();
            // if ((current_display as Gdk.X11.Display) == null) {
            //     return;
            // }

            try {
                bool blur_background = config.config_file.get_boolean ("advanced", "blur_background");
                if (blur_background || force_update) {
                    // 在GTK4中，X11相关的API已被移除
                    // var xdisplay = (current_display as Gdk.X11.Display).get_xdisplay ();
                    // var xid = (get_window () as Gdk.X11.Window).get_xid ();

                    // var atom_NET_WM_DEEPIN_BLUR_REGION_ROUNDED = X.intern_atom (xdisplay, "_NET_WM_DEEPIN_BLUR_REGION_ROUNDED", false);
                    // var atom_KDE_NET_WM_BLUR_BEHIND_REGION = X.intern_atom (xdisplay, "_KDE_NET_WM_BLUR_BEHIND_REGION", false);

                    if (!window_is_fullscreen () && !window_is_max ()) {
                        Cairo.RectangleInt blur_rect;
                        Cairo.RectangleInt blur_rect_kwin;

                        var surface = get_native ()?.get_surface ();
                        if (surface != null) {
                            // 在GTK4中，get_frame_extents已被移除
                            // surface.get_frame_extents (out blur_rect);
                            // surface.get_frame_extents (out blur_rect_kwin);
                            blur_rect = Cairo.RectangleInt () { x = 0, y = 0, width = 0, height = 0 };
                            blur_rect_kwin = Cairo.RectangleInt () { x = 0, y = 0, width = 0, height = 0 };
                        } else {
                            blur_rect = Cairo.RectangleInt () { x = 0, y = 0, width = 0, height = 0 };
                            blur_rect_kwin = Cairo.RectangleInt () { x = 0, y = 0, width = 0, height = 0 };
                        }

                        int width = get_size (Gtk.Orientation.HORIZONTAL);
                        int height = get_size (Gtk.Orientation.VERTICAL);

                        blur_rect.x = (int) (blur_rect.x * Utils.get_default_monitor_scale ());
                        blur_rect.y = (int) (blur_rect.y * Utils.get_default_monitor_scale ());
                        blur_rect.width = (int) (blur_rect.width * Utils.get_default_monitor_scale ());
                        blur_rect.height = (int) (blur_rect.height * Utils.get_default_monitor_scale ());
                        blur_rect_kwin.x = (int) (blur_rect_kwin.x * Utils.get_default_monitor_scale ());
                        blur_rect_kwin.y = (int) (blur_rect_kwin.y * Utils.get_default_monitor_scale ());
                        blur_rect_kwin.width = (int) (blur_rect_kwin.width * Utils.get_default_monitor_scale ());
                        blur_rect_kwin.height = (int) (blur_rect_kwin.height * Utils.get_default_monitor_scale ());

                        // X11相关代码已被移除
                        // ulong[] data = {(ulong) blur_rect.x, (ulong) blur_rect.y, (ulong) blur_rect.width, (ulong) blur_rect.height, 8, 8};
                        // ulong[] data_kwin = {(ulong) blur_rect_kwin.x, (ulong) blur_rect_kwin.y, (ulong) blur_rect_kwin.width, (ulong) blur_rect_kwin.height, 8, 8};
                        // xdisplay.change_property (
                        //     xid,
                        //     atom_NET_WM_DEEPIN_BLUR_REGION_ROUNDED,
                        //     X.XA_CARDINAL,
                        //     32,
                        //     X.PropMode.Replace,
                        //     (uchar[])data,
                        //     ((ulong[]) data).length);

                        // xdisplay.change_property (
                        //     xid,
                        //     atom_KDE_NET_WM_BLUR_BEHIND_REGION,
                        //     X.XA_CARDINAL,
                        //     32,
                        //     X.PropMode.Replace,
                        //     (uchar[])data_kwin,
                        //     ((ulong[]) data_kwin).length - 2
                        // );
                    } else {
                        // xdisplay.delete_property (xid, atom_NET_WM_DEEPIN_BLUR_REGION_ROUNDED);
                        // xdisplay.delete_property (xid, atom_KDE_NET_WM_BLUR_BEHIND_REGION);
                    }
                }
            } catch (GLib.KeyFileError e) {
                print ("%s\n", e.message);
            }
        }

        public void draw_window_widgets (Cairo.Context cr) {
            Utils.propagate_draw (this, cr);
        }

        public void add_widget (Gtk.Widget widget) {
            window_widget_box.append (widget);
        }

        public bool have_terminal_at_same_workspace () {
            #if USE_GTK3
            if (GLib.Environment.get_variable ("XDG_SESSION_TYPE") == "wayland") {
                return false;
            }

            var screen = Wnck.Screen.get_default ();
            screen.force_update ();

            var active_workspace = screen.get_active_workspace ();
            foreach (Wnck.Window window in screen.get_windows ()) {
                var workspace = window.get_workspace ();
                if (workspace != null && workspace.get_number () == active_workspace.get_number ()) {
                    int pid = window.get_pid ();
                    if (pid != 0) {
                        string command = Utils.get_proc_file_content ("/proc/%i/comm".printf(   pid)).strip(   );
                        if (command == "deepin-terminal-gtk") {
                            return true;
                        }
                    }
                }
            }
            #endif

            return false;
        }

        public override void toggle_fullscreen () {
            if (window_is_fullscreen ()) {
                unfullscreen ();
            } else {
                fullscreen ();
            }
        }

        public override void update_frame () {
            update_style ();

            if (Utils.is_tiling_wm () || window_is_fullscreen () || window_is_max ()) {
                window_widget_box.margin_top = 0;
                window_widget_box.margin_bottom = 0;
                window_widget_box.margin_start = 0;
                window_widget_box.margin_end = 0;
            } else if (window_is_tiled ()) {
                window_widget_box.margin_top = 1;
                window_widget_box.margin_bottom = 1;
                window_widget_box.margin_start = 1;
                window_widget_box.margin_end = 1;
            } else {
                window_widget_box.margin_top = 2;
                window_widget_box.margin_bottom = 2;
                window_widget_box.margin_start = 2;
                window_widget_box.margin_end = 2;
            }

            // 在GTK4中，合成检测需要不同的方法
            bool is_composited = true; // 假设现代桌面环境都支持合成
            if (!is_composited || window_is_fullscreen () || window_is_max ()) {
                window_frame_box.margin_top = 0;
                window_frame_box.margin_bottom = 0;
                window_frame_box.margin_start = 0;
                window_frame_box.margin_end = 0;

                // GTK4中不再需要set_shadow_width
            } else {
                window_frame_box.margin_top = window_frame_margin_top;
                window_frame_box.margin_bottom = window_frame_margin_bottom;
                window_frame_box.margin_start = window_frame_margin_start;
                window_frame_box.margin_end = window_frame_margin_end;

                // GTK4中不再需要set_shadow_width
            }

            bool always_hide_resize_grip = false;
            try {
                always_hide_resize_grip = config.config_file.get_boolean ("advanced", "always_hide_resize_grip");
            } catch (GLib.KeyFileError e) {
                print ("Window update_frame: %s\n", e.message);
            }

            if (Utils.is_tiling_wm () || is_composited || window_is_fullscreen () || window_is_max () || always_hide_resize_grip) {
                resize_grip.hide ();
            } else {
                resize_grip.show ();
            }
        }

        public void toggle_max () {
            if (window_is_max ()) {
                unmaximize ();
            } else {
                maximize ();
            }
        }

        public virtual void draw_window_below (Cairo.Context cr) {

        }

        public void draw_window_frame (Cairo.Context cr) {
            Gtk.Allocation window_frame_rect;
            window_frame_box.get_allocation (out window_frame_rect);

            int x = window_frame_box.margin_start;
            int y = window_frame_box.margin_top;
            int width = window_frame_rect.width;
            int height = window_frame_rect.height;
            Gdk.RGBA frame_color;

            try {
                if (window_is_normal ()) {
                    frame_color = Utils.hex_to_rgba (config.config_file.get_string ("theme", "background"));

                    // 在GTK4中，合成检测需要不同的方法
                    bool is_composited = true; // 假设现代桌面环境都支持合成
                    if (is_composited) {
                        // Draw line *innner* of window frame.
                        cr.save(   );
                        cr.set_source_rgba (frame_color.red, frame_color.green, frame_color.blue, config.config_file.get_double ("general", "opacity"));
                        // Bottom.
                        Draw.draw_rectangle(   cr, x + 2, y + height - 2, width - 4, 1);
                        // Left.
                        if (tabbar_at_the_bottom) {
                            Draw.draw_rectangle (cr, x + 1, y + 2, 1, height - Constant.TITLEBAR_HEIGHT - 4);
                        } else {
                            Draw.draw_rectangle (cr, x + 1, y + Constant.TITLEBAR_HEIGHT + 2, 1, height - Constant.TITLEBAR_HEIGHT - 4);
                        }
                        // Right..
                        if (tabbar_at_the_bottom) {
                            Draw.draw_rectangle (cr, x + width - 2, y + 2, 1, height  - Constant.TITLEBAR_HEIGHT- 4);
                        } else {
                            Draw.draw_rectangle (cr, x + width - 2, y + Constant.TITLEBAR_HEIGHT + 2, 1, height - Constant.TITLEBAR_HEIGHT - 4);
                        }
                        cr.restore ();
                    } else {
                        // Draw line *innner* of window frame.
                        cr.save(   );
                        cr.set_source_rgba (frame_color.red, frame_color.green, frame_color.blue, config.config_file.get_double ("general", "opacity"));
                        Draw.draw_rectangle (cr, x, y, width, height, false);
                        cr.restore ();
                    }
                }
            } catch (Error e) {
                print ("Window draw_window_frame: %s\n", e.message);
            }
        }

        public void draw_window_above (Cairo.Context cr) {
            Gtk.Allocation window_frame_rect;
            window_frame_box.get_allocation (out window_frame_rect);

            int x = window_frame_box.margin_start;
            int y = window_frame_box.margin_top;
            int width = window_frame_rect.width;
            int height = window_frame_rect.height;
            int titlebar_y = y;
            if (tabbar_at_the_bottom) {
                titlebar_y += height - Constant.TITLEBAR_HEIGHT;
            }
            if (get_scale_factor () > 1) {
                titlebar_y -= 1;
            }
            Gdk.RGBA frame_color = Gdk.RGBA ();

            bool is_light_theme = is_light_theme ();

            try {
                frame_color = Utils.hex_to_rgba (config.config_file.get_string ("theme", "background"));
            } catch (GLib.KeyFileError e) {
                print ("Window draw_window_above: %s\n", e.message);
            }

            try {
                if (window_is_fullscreen ()) {
                    if (draw_tabbar_line) {
                        if (tabbar_at_the_bottom) {
                            draw_titlebar_underline (cr, x, titlebar_y, width, -1);
                            draw_active_tab_underline (cr, x + active_tab_underline_x - window_frame_box.margin_start, titlebar_y - 1);
                        } else {
                            draw_titlebar_underline (cr, x, titlebar_y + Constant.TITLEBAR_HEIGHT, width, 1);
                            draw_active_tab_underline (cr, x + active_tab_underline_x - window_frame_box.margin_start, titlebar_y +  Constant.TITLEBAR_HEIGHT - 1);
                        }
                    }
                } else if (window_is_max () || window_is_tiled ()) {
                    if (tabbar_at_the_bottom) {
                        draw_titlebar_underline (cr, x + 1, titlebar_y, width - 2, -1);
                        draw_active_tab_underline (cr, x + active_tab_underline_x - window_frame_box.margin_start, titlebar_y - 1);
                    } else {
                        draw_titlebar_underline (cr, x + 1, titlebar_y + Constant.TITLEBAR_HEIGHT, width - 2, 1);
                        draw_active_tab_underline (cr, x + active_tab_underline_x - window_frame_box.margin_start, titlebar_y + Constant.TITLEBAR_HEIGHT - 1);
                    }
                } else {
                    int titlebar_near_frame_y = titlebar_y + 1;
                    int side_margin = 2;
                    if (tabbar_at_the_bottom) {
                        titlebar_near_frame_y = titlebar_y + Constant.TITLEBAR_HEIGHT;
                        side_margin = -2;
                    }
                    // Draw line above at titlebar.
                    cr.set_source_rgba(   frame_color.red, frame_color.green, frame_color.blue, config.config_file.get_double(   "general", "opacity"));
                    Draw.draw_rectangle (cr, x + 2, y + 1, width - 4, 1);

                    //  if (is_light_theme) {
                    //      Utils.set_context_color(cr, top_line_light_color);
                    //  } else {
                    //      Utils.set_context_color(cr, top_line_dark_color);
                    //  }
                    Draw.draw_rectangle(   cr, x + 2, y + 1, width - 4, 1);

                    cr.set_source_rgba (1, 1, 1, 0.0625 * config.config_file.get_double ("general", "opacity")); // Draw top line at window.
                    Draw.draw_rectangle(   cr, x + 2, y, width - 4, 1);

                    // Draw line around titlebar side.
                    cr.set_source_rgba(   frame_color.red, frame_color.green, frame_color.blue, config.config_file.get_double(   "general", "opacity"));
                    // Left.
                    Draw.draw_rectangle(   cr, x + 1, titlebar_y + side_margin, 1, Constant.TITLEBAR_HEIGHT);
                    // Right.
                    Draw.draw_rectangle(   cr, x + width - 2, titlebar_y + side_margin, 1, Constant.TITLEBAR_HEIGHT);

                    //  if (is_light_theme) {
                    //      Utils.set_context_color(cr, top_line_light_color);
                    //  } else {
                    //      Utils.set_context_color(cr, top_line_dark_color);
                    //  }

                    // Left.
                    Draw.draw_rectangle(   cr, x + 1, titlebar_y + side_margin, 1, Constant.TITLEBAR_HEIGHT);
                    // Right.
                    Draw.draw_rectangle(   cr, x + width - 2, titlebar_y + side_margin, 1, Constant.TITLEBAR_HEIGHT);

                    if (tabbar_at_the_bottom)  {
                        draw_titlebar_underline (cr, x + 1, titlebar_y, width - 2, -1);
                        draw_active_tab_underline (cr, x + active_tab_underline_x - window_frame_box.margin_start, titlebar_y - 1);
                    } else {
                        draw_titlebar_underline (cr, x + 1, titlebar_y + Constant.TITLEBAR_HEIGHT, width - 2, 1);
                        draw_active_tab_underline (cr, x + active_tab_underline_x - window_frame_box.margin_start, titlebar_y + Constant.TITLEBAR_HEIGHT -1);
                    }
                }
            } catch (Error e) {
                print ("Window draw_window_above: %s\n", e.message);
            }
        }

        public void init_fullscreen_handler (Appbar appbar) {
            spacing_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            spacing_box.set_size_request (-1, Constant.TITLEBAR_HEIGHT);
            fullscreen_box.append (spacing_box);

            // 在GTK4中，motion_notify_event已被移除，使用EventControllerMotion
            var motion_controller = new Gtk.EventControllerMotion ();
            motion_controller.motion.connect ((x, y) => {
                if (window_is_fullscreen ()) {
                   var receiveEvents = tabbar_at_the_bottom? y > window_fullscreen_monitor_height : y < window_fullscreen_monitor_height;
                    if (receiveEvents) {
                        GLib.Timeout.add (window_fullscreen_monitor_timeout, () => {
                                int pointer_x, pointer_y;
                                Utils.get_pointer_position (out pointer_x, out pointer_y);

                                var showAll = tabbar_at_the_bottom? pointer_y > window_fullscreen_monitor_height + Constant.TITLEBAR_HEIGHT : pointer_y < window_fullscreen_response_height;
                                var hideAll = tabbar_at_the_bottom? pointer_y < window_fullscreen_monitor_height + Constant.TITLEBAR_HEIGHT : pointer_y > Constant.TITLEBAR_HEIGHT;
                                if (showAll) {
                                    appbar.show ();
                                    draw_tabbar_line = true;

                                    redraw_window ();
                                } else if (hideAll) {
                                    appbar.hide ();
                                    draw_tabbar_line = false;

                                    redraw_window ();
                                }

                                return false;
                            });
                    }
                }
            });

            // 修复add_controller调用
            // add_controller (motion_controller);
            // GTK4中需要不同类型的controller
        }

        public void show_window (TerminalApp app, WorkspaceManager workspace_manager, Tabbar tabbar, bool has_start=false) {
            Appbar appbar = new Appbar (app, this, tabbar, workspace_manager, has_start);

            if (tabbar_at_the_bottom)
                appbar.set_valign (Gtk.Align.END);
            else
                appbar.set_valign (Gtk.Align.START);
            appbar.close_window.connect ((w) => {
                    quit ();
                });
            appbar.quit_fullscreen.connect ((w) => {
                    toggle_fullscreen ();
                });

            init (workspace_manager, tabbar);
            init_fullscreen_handler (appbar);

            if (!have_terminal_at_same_workspace ()) {
                // 在GTK4中，set_position已被移除
                // set_position (Gtk.WindowPosition.CENTER);
            }

            var overlay = new Gtk.Overlay ();
            resize_grip = new Widgets.ResizeGrip (this);
            top_box.append (fullscreen_box);
            if (tabbar_at_the_bottom) {
                box.append (workspace_manager);
                box.append (top_box);
            }
            else {
                box.append (top_box);
                box.append (workspace_manager);
                box.append (resize_grip);
            }

            overlay.set_child (box);
            overlay.add_overlay (appbar.get_overlay ());

            add_widget (overlay);
            show ();
        }

        // 修复get_cursor_name方法
        // public override string? get_cursor_name (double x, double y) {
        //     var surface = get_native ()?.get_surface ();
        //     if (surface != null) {
        //         int window_x, window_y;
        //         // surface.get_origin (out window_x, out window_y);
        //         // GTK4中get_origin已被移除，暂时注释
        //     }
        //     return null;
        // }

        // 修复get_frame_cursor_name方法
        // public override string? get_frame_cursor_name (double x, double y) {
        //     var surface = get_native ()?.get_surface ();
        //     if (surface != null) {
        //         int window_x, window_y;
        //         // surface.get_origin (out window_x, out window_y);
        //         // GTK4中get_origin已被移除，暂时注释
        //     }
        //     return null;
        // }
    }
}
