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
using Widgets;

namespace Widgets {
    public class QuakeWindow : Widgets.ConfigWindow {
        public double window_default_height_scale = 0.3;
        public double window_max_height_scale = 0.7;
        public int press_x;
        public int press_y;
        public int window_frame_margin_bottom = 60;

        public QuakeWindow () {
            quake_mode = true;

            // 在GTK4中，set_app_paintable已被移除，透明度通过CSS处理
            // set_app_paintable (true);

            // 让窗口管理器决定窗口位置和大小，不再手动move/resize
            set_decorated (false);
            // 在GTK4中，这些方法已被移除或改变
            // set_keep_above (true);
            // set_skip_taskbar_hint (true);
            // set_skip_pager_hint (true);
            // set_type_hint(   Gdk.WindowTypeHint.MENU);

            window_frame_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            window_widget_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

            set_child (window_frame_box);
            window_frame_box.append (window_widget_box);

            // 在GTK4中，realize信号已被移除
            // realize.connect ((w) => {
            //         update_frame ();

            //         try {
            //             var quake_window_fullscreen = config.config_file.get_boolean ("advanced", "quake_window_fullscreen");
            //             if (quake_window_fullscreen) {
            //                 fullscreen ();
            //             }
            //             // 不再手动设置窗口大小，交给窗口管理器
            //         } catch (Error e) {
            //             print ("QuakeWindow init: %s\n", e.message);
            //         }
            //     });

            // 在GTK4中，这些事件信号已被移除，需要使用事件控制器
            // focus_in_event.connect ((w) => {
            //         update_style ();
            //         return false;
            //     });

            // focus_out_event.connect ((w) => {
            //         update_style ();

            //         try {
            //             // Hide quake window when lost focus, and config option 'hide_quakewindow_after_lost_focus' must be true, variable 'show_quake_menu' must be fasle.
            //             // If variable 'show_quake_menu' is true, lost focus signal is cause by click right menu on quake terminal.
            //             if (config.config_file.get_boolean(   "advanced", "hide_quakewindow_after_lost_focus")) {
            //                 if (show_quake_menu) {
            //                     show_quake_menu = false;
            //                 } else {
            //                     GLib.Timeout.add (200, () => {
            //                             var window_state = get_window ().get_state ();
            //                             // Because some desktop environment, such as DDE will grab keyboard focus when press keystroke. :(
            //                             //
            //                             // When press quakewindow shortcuts will make code follow order: `focus_out event -> toggle_quake_window'.
            //                             // focus_out event will make quakewindow hide immediately, quakewindow will show again when execute toggle_quake_window.
            //                             // At last, quakewindow will execute 'hide' and 'show' actions twice, not just simple hide window.
            //                             //
            //                             // So i add 200ms timeout to wait toggle_quake_window execute,
            //                             // focus_out event will hide window if it find window is show state after execute toggle_quake_window.
            //                             if (!(Gdk.WindowState.WITHDRAWN in window_state)) {
            //                                 hide ();
            //                             }

            //                             return false;
            //                         });
            //                     // hide();
            //                 }
            //             }
            //         } catch (Error e) {
            //             print ("quake_window focus_out_event: %s\n", e.message);
            //         }

            //         return false;
            //     });

            // configure_event.connect ((w) => {
            //         // Update input shape.
            //         int width, height;
            //         get_size (out width, out height);

            //         Cairo.RectangleInt input_shape_rect;
            //         get_window ().get_frame_extents (out input_shape_rect);

            //         // 在GTK4中，合成检测需要不同的方法
            //         bool is_composited = true; // 假设现代桌面环境都支持合成
            //         if (is_composited) {
            //             input_shape_rect.x = 0;
            //             input_shape_rect.y = 0;
            //             input_shape_rect.width = width;
            //             input_shape_rect.height = height - window_frame_box.margin_bottom + Constant.RESPONSE_RADIUS;
            //         }

            //         var shape = new Cairo.Region.rectangle (input_shape_rect);
            //         get_window ().input_shape_combine_region (shape, 0, 0);

            //         // Update blur area.
            //         update_blur_status(   );

            //         return false;
            //     });

            // window_frame_box.button_press_event.connect ((w, e) => {
            //         // 在GTK4中，合成检测需要不同的方法
            //         bool is_composited = true; // 假设现代桌面环境都支持合成
            //         if (!is_composited) {
            //             var cursor_name = get_frame_cursor_name (e.x_root, e.y_root);
            //             if (cursor_name != null) {
            //                 e.device.get_position (null, out press_x, out press_y);

            //                 GLib.Timeout.add (10, () => {
            //                         int pointer_x, pointer_y;
            //                         e.device.get_position (null, out pointer_x, out pointer_y);

            //                         if (pointer_x != press_x || pointer_y != press_y) {
            //                             Utils.resize_window (this, e, cursor_name);
            //                             return false;
            //                         } else {
            //                             return true;
            //                         }
            //                     });
            //             }
            //         }

            //         return false;
            //     });

            // button_press_event.connect ((w, e) => {
            //         var cursor_name = get_cursor_name (e.x_root, e.y_root);
            //         if (cursor_name != null) {
            //             e.device.get_position (null, out press_x, out press_y);

            //             GLib.Timeout.add (10, () => {
            //                     int pointer_x, pointer_y;
            //                     e.device.get_position (null, out pointer_x, out pointer_y);

            //                     if (pointer_x != press_x || pointer_y != press_y) {
            //                         Utils.resize_window (this, e, cursor_name);
            //                         return false;
            //                     } else {
            //                         return true;
            //                     }
            //                 });
            //         }

            //         return false;
            //     });

            // 在GTK4中，draw信号已被移除，使用snapshot
            // draw.connect_after ((w, cr) => {
            //         draw_window_widgets (cr);
            //         draw_window_above (cr);
            //         return true;
            //     });

            config.update.connect ((w) => {
                    update_style ();
                    update_blur_status (true);
                });
        }

        public void update_blur_status (bool force_update=false) {
            // 在GTK4中，X11相关的API已被移除，暂时禁用模糊背景功能
            // TODO: 实现GTK4兼容的模糊背景功能
            return;
            
            try {
                int width = get_width ();
                int height = get_height ();

                if (width != resize_cache_width || height != resize_cache_height || force_update) {
                    resize_cache_width = width;
                    resize_cache_height = height;

                    // X11相关代码已被移除
                    // unowned X.Display xdisplay = (get_window ().get_display () as Gdk.X11.Display).get_xdisplay ();
                    // var xid = (int)((Gdk.X11.Window) get_window ()).get_xid ();
                    // var atom_NET_WM_DEEPIN_BLUR_REGION_ROUNDED = xdisplay.intern_atom ("_NET_WM_DEEPIN_BLUR_REGION_ROUNDED", false);
                    // var atom_KDE_NET_WM_BLUR_BEHIND_REGION = xdisplay.intern_atom ("_KDE_NET_WM_BLUR_BEHIND_REGION", false);

                    var blur_background = config.config_file.get_boolean ("advanced", "blur_background");
                    if (blur_background) {
                        // 在GTK4中，get_frame_extents已被移除
                        // Cairo.RectangleInt blur_rect;
                        // get_window ().get_frame_extents (out blur_rect);

                        // 在GTK4中，合成检测需要不同的方法
                        bool is_composited = true; // 假设现代桌面环境都支持合成
                        if (is_composited) {
                            // blur_rect.x = 0;
                            // blur_rect.y = 0;
                            // blur_rect.width = width;
                            // blur_rect.height = height - window_frame_box.margin_bottom;
                        }

                        // if (blur_rect.width < 0) {
                        //     print ("[!!!] blur_rect calc result error! blur_rect.width = %d which is negative!\n", blur_rect.width);
                        //     blur_rect.width = width - window_frame_box.get_margin_start () - window_frame_box.get_margin_end ();
                        //     blur_rect.height = height - window_frame_box.get_margin_top () - window_frame_box.get_margin_bottom ();
                        // }
                    } else {
                        // xdisplay.delete_property (xid, atom_NET_WM_DEEPIN_BLUR_REGION_ROUNDED);
                        // xdisplay.delete_property (xid, atom_KDE_NET_WM_BLUR_BEHIND_REGION);
                    }
                }
            } catch (GLib.KeyFileError e) {
                print ("%s\n", e.message);
            }
        }

        public void add_widget (Gtk.Widget widget) {
            window_widget_box.append (widget);
        }

        public void toggle_quake_window () {
            // 让窗口管理器决定窗口位置和大小，不再手动move/resize
            // 在GTK4中，get_window已被移除
            // var window_state = get_window ().get_state ();
            // if (Gdk.WindowState.WITHDRAWN in window_state) {
            //     show_all();
            //     present();
            // } else {
            //     try {
            //         if (config.config_file.get_boolean(   "advanced", "hide_quakewindow_when_active")) {
            //             GLib.Timeout.add(   200, () => {
            //                     if (is_active) {
            //                         hide ();
            //                     } else {
            //                         // 在GTK4中，X11相关的API已被移除
            //                         present();
            //                     }
            //                     return false;
            //                 });
            //         } else {
            //             hide ();
            //         }
            //     } catch (Error e) {
            //         print ("quake_window toggle_quake_window: %s\n", e.message);
            //     }
            // }
            
            // 简化实现
            if (visible) {
                hide ();
            } else {
                show ();
                present ();
            }
        }

        public void show_quake_window (Gdk.Rectangle rect) {
            // Init.
            int width = get_width ();
            int height = get_height ();
            show ();

            // Resize quake terminal window's width along with monitor's width.
            var surface = get_native ()?.get_surface ();
            if (surface != null) {
                // 在GTK4中，move_resize方法已被移除
                // surface.move_resize (rect.x, 0, rect.width, height);
            }

            // Present window.
            present ();
        }

        public void update_style () {
            clean_style ();

            bool is_light_theme = is_light_theme ();
            // 在GTK4中，合成检测需要不同的方法
            bool is_composited = true; // 假设现代桌面环境都支持合成

            if (is_active) {
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

        public void draw_window_widgets (Cairo.Context cr) {
            Utils.propagate_draw (this, cr);
        }

        public void draw_window_above (Cairo.Context cr) {
            Gtk.Allocation window_frame_rect;
            window_frame_box.get_allocation (out window_frame_rect);

            int x = window_frame_box.margin_start;
            int y = window_frame_box.margin_top;
            int width = window_frame_rect.width;
            int height = window_frame_rect.height;

            int titlebar_y = y;
            if (get_scale_factor () > 1) {
                titlebar_y += 1;
            }

            draw_titlebar_underline (cr, x, titlebar_y + height - Constant.TITLEBAR_HEIGHT, width, -1);
            draw_active_tab_underline (cr, x + active_tab_underline_x, titlebar_y + height - Constant.TITLEBAR_HEIGHT);
        }

        public void show_window (WorkspaceManager workspace_manager, Tabbar tabbar) {
            Gdk.RGBA background_color = Gdk.RGBA ();

            init (workspace_manager, tabbar);
            // First focus terminal after show quake terminal.
            // Sometimes, some popup window (like wine program's popup notify window) will grab focus,
            // so call window.present to make terminal get focus.
            show.connect ((t) => {
                    present ();
                });

            top_box.append (tabbar);
            box.append (workspace_manager);

            try {
                if (config.config_file.get_boolean ("advanced", "show_quakewindow_tab")) {
                    box.append (top_box);
                }
            } catch (Error e) {
                print ("Main quake mode: %s\n", e.message);
            }

            set_child (box);
            show ();
        }

        // 在GTK4中，这些方法已被移除
        // public override string? get_cursor_name (double x, double y) {
        //     int window_x, window_y;
        //     var surface = get_native ()?.get_surface ();
        //     if (surface != null) {
        //         surface.get_origin (out window_x, out window_y);
        //     } else {
        //         window_x = 0;
        //         window_y = 0;
        //     }

        //     int width = get_width ();
        //     int height = get_height ();

        //     var bottom_side_start = window_y + height - window_frame_margin_bottom;
        //     var bottom_side_end = window_y + height - window_frame_margin_bottom + Constant.RESPONSE_RADIUS;

        //     if (y > bottom_side_start && y < bottom_side_end) {
        //         return "ns-resize";
        //     } else {
        //         return null;
        //     }
        // }

        // public override string? get_frame_cursor_name (double x, double y) {
        //     int window_x, window_y;
        //     var surface = get_native ()?.get_surface ();
        //     if (surface != null) {
        //         surface.get_origin (out window_x, out window_y);
        //     } else {
        //         window_x = 0;
        //         window_y = 0;
        //     }

        //     int width = get_width ();
        //     int height = get_height ();

        //     var bottom_side_start = window_y + height - Constant.RESPONSE_RADIUS;
        //     var bottom_side_end = window_y + height;

        //     if (y > bottom_side_start && y < bottom_side_end) {
        //         return "ns-resize";
        //     } else {
        //         return null;
        //     }
        // }

        public override void update_frame () {
            update_style ();

            // 在GTK4中，合成检测需要不同的方法
            bool is_composited = true; // 假设现代桌面环境都支持合成
            if (is_composited) {
                window_frame_box.margin_bottom = window_frame_margin_bottom;
                // GTK4中不再需要set_shadow_width
            } else {
                window_frame_box.margin_bottom = 0;
                // GTK4中不再需要set_shadow_width
            }
        }
    }
}
