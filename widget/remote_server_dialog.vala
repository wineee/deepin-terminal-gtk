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
    public class RemoteServerDialog : Widgets.Dialog {
        public Gtk.Box advanced_options_box;
        public Gtk.Box box;
        public Gtk.Box server_action_box;
        public Widgets.DropdownTextButton backspace_key_box;
        public Widgets.DropdownTextButton del_key_box;
        public Widgets.DropdownTextButton encode_box;
        public Gtk.Grid advanced_grid;
        public Gtk.Widget? focus_widget;
        public Widgets.ConfigWindow parent_window;
        public Widgets.Entry address_entry;
        public Widgets.Entry command_entry;
        public Widgets.Entry groupname_entry;
        public Widgets.Entry name_entry;
        public Widgets.Entry path_entry;
        public Widgets.Entry user_entry;
        public Widgets.FileButton file_button;
        public Widgets.PasswordButton password_button;
        public Widgets.SpinButton port_spinbutton;
        public Widgets.TextButton delete_server_button;
        public Widgets.TextButton show_advanced_button;
        public int action_button_margin_top = 20;
        public int font_size = 11;
        public int grid_height = 24;
        public int label_margin_start = 14;
        public int max_server_name_length = 50;
        public int port_label_margin_start = 21;
        public int preference_margin_end = 20;
        public int preference_margin_start = 20;
        public int preference_margin_top = 10;
        public int preference_name_margin_start = 10;
        public int preference_name_width = 0;
        public int preference_widget_width = 100;
        public int window_expand_height;
        public string? server_info;

        public signal void add_server (string address,
                                      string username,
                                      string password,
                                      string private_key,
                                      int port,
                                      string encode,
                                      string path,
                                      string command,
                                      string nickname,
                                      string groupname,
                                      string backspace_key,
                                      string delete_key
            );
        public signal void edit_server (string address,
                                       string username,
                                       string password,
                                       string private_key,
                                       int port,
                                       string encode,
                                       string path,
                                       string command,
                                       string nickname,
                                       string groupname,
                                       string backspace_key,
                                       string delete_key
            );

        public signal void delete_server (string address, string username);

        public RemoteServerDialog (Widgets.ConfigWindow window, Gtk.Widget? widget, string? info=null, KeyFile? config_file=null) {
            Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);

            set_init_size (480, 360);

            window_expand_height = 530;

            var font_description = new Pango.FontDescription ();
            font_description.set_size ((int)(font_size * Pango.SCALE));
            int max_width = 0;
            string[] label_names = {_("Server name"), _("Address"), _("Username"), _("Password"), _("Certificate"), _("Path"), _("Command"), _("Group"), _("Encoding"), _("Backspace key"), _("Delete key")};
            foreach (string label_name in label_names) {
                var layout = create_pango_layout (label_name);
                layout.set_font_description (font_description);
                int name_width, name_height;
                layout.get_pixel_size (out name_width, out name_height);

                max_width = int.max (max_width, name_width);
            }
            preference_name_width = max_width + preference_name_margin_start;

            try {
                parent_window = window;
                focus_widget = widget;
                server_info = info;

                string[]? server_infos = null;
                if (server_info != null) {
                    server_infos = server_info.split ("@");
                }

                box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

                var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                top_box.margin_bottom = preference_margin_top;

                var event_area = new Widgets.WindowEventArea (this);
                event_area.margin_end = Constant.CLOSE_BUTTON_WIDTH;

                var overlay = new Gtk.Overlay ();
                overlay.set_child (top_box);
                overlay.add_overlay (event_area);

                box.append (overlay);

                // Make label center of titlebar.
                var spacing_box = new Gtk.Box(   Gtk.Orientation.HORIZONTAL, 0);
                spacing_box.set_size_request (Constant.CLOSE_BUTTON_WIDTH, -1);
                top_box.append (spacing_box);

                Gtk.Label title_label = new Gtk.Label (null);
                title_label.get_style_context ().add_class ("remote_server_label");
                top_box.append (title_label);

                if (server_infos != null) {
                    title_label.set_text (_("Edit Server"));
                } else {
                    title_label.set_text (_("Add Server"));
                }

                var close_button = Widgets.create_close_button ();
                close_button.clicked.connect ((b) => {
                        this.destroy ();
                    });

                top_box.append (close_button);

                var content_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
                content_box.set_halign (Gtk.Align.CENTER);
                content_box.margin_start = preference_margin_start;
                content_box.margin_end = preference_margin_end;
                box.append (content_box);

                var grid = new Gtk.Grid ();
                grid.margin_end = label_margin_start;
                content_box.append (grid);

                // Nick name.
                Label name_label = new Gtk.Label(   null);
                name_entry = new Widgets.Entry ();
                if (server_infos != null) {
                    name_entry.set_text (config_file.get_value (server_info, "Name"));
                }
                name_entry.set_placeholder_text (_("Required"));
                create_key_row (name_label, name_entry, _("Server name:"), grid);

                // Address.
                Label address_label = create_label(   _("Address:"));
                address_entry = new Widgets.Entry ();
                if (server_infos != null) {
                    address_entry.set_text (server_infos[1]);
                }
                address_entry.set_width_chars (label_margin_start);
                address_entry.set_placeholder_text (_("Required"));
                address_entry.margin_start = label_margin_start;
                address_entry.get_style_context ().add_class ("preference_entry");
                Label port_label = create_label (_("Port:"));
                port_spinbutton = new Widgets.SpinButton ();

                port_spinbutton.set_range (0, 65535);
                port_spinbutton.set_increments (1, 10);
                port_spinbutton.get_style_context ().add_class ("preference_spinbutton");
                if (server_infos != null) {
                    if (server_infos.length > 2) {
                        port_spinbutton.set_value (int.parse (server_infos[2]));
                    } else {
                        port_spinbutton.set_value (config_file.get_integer (server_info, "Port"));
                    }
                } else {
                    port_spinbutton.set_value (22);
                }
                port_spinbutton.margin_start = label_margin_start;

                var address_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                address_box.append (address_entry);
                address_box.append (port_label);
                address_box.append (port_spinbutton);

                grid_attach_next_to (grid, address_label, name_label, Gtk.PositionType.BOTTOM, preference_name_width, grid_height);
                grid_attach_next_to (grid, address_box, address_label, Gtk.PositionType.RIGHT, preference_widget_width, grid_height);

                adjust_option_widgets (address_label, address_box);

                // Username.
                Label user_label = new Gtk.Label(   null);
                user_entry = new Widgets.Entry ();
                if (server_infos != null) {
                    user_entry.set_text (server_infos[0]);
                }
                user_entry.set_placeholder_text (_("Required"));
                create_follow_key_row (user_label, user_entry, _("Username:"), address_label, grid);

                // Password.
                Label password_label = new Gtk.Label(   null);
                password_button = new Widgets.PasswordButton ();
                if (server_infos != null) {
                    string password = "";
                    if (server_infos.length > 2) {
                        password = Utils.lookup_password (server_infos[0], server_infos[1], server_infos[2]);
                    } else {
                        password = Utils.lookup_password (server_infos[0], server_infos[1]);
                    }
                    password_button.entry.set_text (password);
                }
                create_follow_key_row (password_label, password_button, _("Password:"), user_label, grid);

                // File.
                Label file_label = new Gtk.Label(   null);
                file_button = new Widgets.FileButton ();
                if (server_infos != null) {
                    try {
                        file_button.entry.set_text (config_file.get_value (server_info, "PrivateKey"));
                    } catch (GLib.KeyFileError e) {
                        if (FileUtils.test (Utils.get_default_private_key_path (), FileTest.EXISTS)) {
                            file_button.entry.set_text (Utils.get_default_private_key_path ());
                        }
                    }
                }
                create_follow_key_row (file_label, file_button, _("Certificate:"), password_label, grid);

                // Advanced box.
                advanced_options_box = new Gtk.Box(   Gtk.Orientation.VERTICAL, 0);
                advanced_grid = new Gtk.Grid ();
                advanced_grid.margin_end = label_margin_start;
                content_box.append (advanced_options_box);

                // Group name.
                Label group_name_label = new Gtk.Label(   null);
                groupname_entry = new Widgets.Entry ();
                if (server_infos != null) {
                    groupname_entry.set_text (config_file.get_value (server_info, "GroupName"));
                }
                groupname_entry.set_placeholder_text (_("Optional"));
                groupname_entry.set_width_chars (30);  // this line is expand width of entry.
                create_key_row(   group_name_label, groupname_entry, _("Group:"), advanced_grid);

                // Path.
                Label path_label = new Gtk.Label(   null);
                path_entry = new Widgets.Entry ();
                if (server_infos != null) {
                    path_entry.set_text (config_file.get_value (server_info, "Path"));
                }
                path_entry.set_placeholder_text (_("Optional"));
                create_follow_key_row (path_label, path_entry, _("Path:"), group_name_label, advanced_grid);

                // Command.
                Label command_label = new Gtk.Label(   null);
                command_entry = new Widgets.Entry ();
                if (server_infos != null) {
                    command_entry.set_text (config_file.get_value (server_info, "Command"));
                }
                command_entry.set_placeholder_text (_("Optional"));
                create_follow_key_row (command_label, command_entry, _("Command:"), path_label, advanced_grid);

                // Encoding.
                Label encode_label = new Gtk.Label(   null);
                encode_box = new Widgets.DropdownTextButton ();
                foreach (string name in parent_window.config.encoding_names) {
                    encode_box.add_item(name);
                }
                if (server_infos != null) {
                    encode_box.selected = parent_window.config.encoding_names.index_of (config_file.get_value (server_info, "Encode"));
                } else {
                    encode_box.selected = parent_window.config.encoding_names.index_of ("UTF-8");
                }
                create_follow_key_row (encode_label, encode_box, _("Encoding:"), command_label, advanced_grid, "preference_comboboxtext");

                // Backspace sequence.
                Label backspace_key_label = new Gtk.Label(   null);
                backspace_key_box = new Widgets.DropdownTextButton ();
                foreach (string name in parent_window.config.backspace_key_erase_names) {
                    backspace_key_box.add_item(parent_window.config.erase_map.get(name));
                }
                if (server_infos != null) {
                    backspace_key_box.selected = parent_window.config.backspace_key_erase_names.index_of (config_file.get_value (server_info, "Backspace"));
                } else {
                    backspace_key_box.selected = parent_window.config.backspace_key_erase_names.index_of ("ascii-del");
                }
                create_follow_key_row (backspace_key_label, backspace_key_box, _("Backspace key:"), encode_label, advanced_grid, "preference_comboboxtext");

                // Delete sequence.
                Label del_key_label = new Gtk.Label(   null);
                del_key_box = new Widgets.DropdownTextButton ();
                foreach (string name in parent_window.config.del_key_erase_names) {
                    del_key_box.add_item(parent_window.config.erase_map.get(name));
                }
                if (server_infos != null) {
                    del_key_box.selected = parent_window.config.del_key_erase_names.index_of (config_file.get_value (server_info, "Del"));
                } else {
                    del_key_box.selected = parent_window.config.del_key_erase_names.index_of ("escape-sequence");
                }
                create_follow_key_row (del_key_label, del_key_box, _("Delete key:"), backspace_key_label, advanced_grid, "preference_comboboxtext");

                server_action_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                show_advanced_button = Widgets.create_link_button (_("Advanced options"));
                show_advanced_button.clicked.connect ((w) => {
                        show_advanced_options ();
                    });

                server_action_box.append (show_advanced_button);
                content_box.append (server_action_box);

                Box button_box = new Box (Gtk.Orientation.HORIZONTAL, 0);
                button_box.margin_top = action_button_margin_top;
                DialogButton cancel_button = new Widgets.DialogButton (_("Cancel"), "left", "text", true);
                string button_name;
                if (server_infos != null) {
                    button_name = _("Save");
                } else {
                    button_name = _("Add");
                }
                DialogButton confirm_button = new Widgets.DialogButton (button_name, "right", "action", true);
                cancel_button.clicked.connect ((b) => {
                        destroy ();
                    });
                confirm_button.clicked.connect ((b) => {
                        if (server_infos != null) {
                            if (name_entry.get_text ().strip () != "" && address_entry.get_text(   ).strip(   ) != "" && port_spinbutton.get_text(   ).strip(   ) != "" && user_entry.get_text(   ).strip(   ) != "") {
                                edit_server (address_entry.get_text (),
                                            user_entry.get_text (),
                                            password_button.entry.get_text (),
                                            file_button.entry.get_text (),
                                            (int) port_spinbutton.get_value (),
                                            parent_window.config.encoding_names[(int)encode_box.selected],
                                            path_entry.get_text (),
                                            command_entry.get_text (),
                                            name_entry.get_text (),
                                            groupname_entry.get_text (),
                                            parent_window.config.backspace_key_erase_names[(int)backspace_key_box.selected],
                                            parent_window.config.del_key_erase_names[(int)del_key_box.selected]
                                    );
                            }
                        } else {
                            if (name_entry.get_text ().strip () != "" && address_entry.get_text(   ).strip(   ) != "" && port_spinbutton.get_text(   ).strip(   ) != "" && user_entry.get_text(   ).strip(   ) != "") {
                                add_server (address_entry.get_text (),
                                           user_entry.get_text (),
                                           password_button.entry.get_text (),
                                           file_button.entry.get_text (),
                                           (int) port_spinbutton.get_value (),
                                           parent_window.config.encoding_names[(int)encode_box.selected],
                                           path_entry.get_text (),
                                           command_entry.get_text (),
                                           name_entry.get_text (),
                                           groupname_entry.get_text (),
                                           parent_window.config.backspace_key_erase_names[(int)backspace_key_box.selected],
                                           parent_window.config.del_key_erase_names[(int)del_key_box.selected]
                                    );
                            }
                        }
                    });

                var tab_order_list = new List<Gtk.Widget> ();
                tab_order_list.append ((Gtk.Widget) cancel_button);
                tab_order_list.append ((Gtk.Widget) confirm_button);
                // button_box.set_focus_chain (tab_order_list);
                button_box.set_focus_child (confirm_button);

                button_box.append (cancel_button);
                button_box.append (confirm_button);
                box.append (button_box);

                add_widget (box);
            } catch (Error e) {
                error ("%s", e.message);
            }
        }

        public void show_advanced_options () {
            set_default_size (window_init_width, window_expand_height);

            Utils.destroy_all_children (server_action_box);
            if (server_info != null) {
                delete_server_button = Widgets.create_link_button (_("Delete server"));
                delete_server_button.clicked.connect ((w) => {
                        string[]? server_infos = server_info.split ("@");
                        if (server_infos != null && server_infos.length >= 2) {
                            delete_server (server_infos[1], server_infos[0]);
                        }
                    });
                server_action_box.append (delete_server_button);
            }

            advanced_options_box.append (advanced_grid);

            show ();
        }

        public Label create_label (string text) {
            Label label = new Gtk.Label (null);
            label.margin_start = label_margin_start;
            label.set_text (text);
            label.get_style_context ().add_class ("preference_label");
            label.set_xalign (0);

            return label;
        }

        public void create_key_row (Gtk.Label label, Gtk.Widget widget, string name, Gtk.Grid grid, string class_name="preference_entry") {
            label.set_text (name);
            label.margin_start = label_margin_start;
            label.get_style_context ().add_class ("preference_label");
            widget.get_style_context ().add_class (class_name);
            widget.margin_start = label_margin_start;

            adjust_option_widgets (label, widget);
            grid_attach (grid, label, 0, 0, preference_name_width, grid_height);
            grid_attach_next_to (grid, widget, label, Gtk.PositionType.RIGHT, preference_widget_width, grid_height);
        }

        public void create_follow_key_row (Gtk.Label label, Gtk.Widget widget, string name, Gtk.Label previous_label, Gtk.Grid grid, string class_name="preference_entry") {
            label.set_text (name);
            label.margin_start = label_margin_start;
            label.get_style_context ().add_class ("preference_label");
            widget.get_style_context ().add_class (class_name);
            widget.margin_start = label_margin_start;

            adjust_option_widgets (label, widget);
            grid_attach_next_to (grid, label, previous_label, Gtk.PositionType.BOTTOM, preference_name_width, grid_height);
            grid_attach_next_to (grid, widget, label, Gtk.PositionType.RIGHT, preference_widget_width, grid_height);
        }

        public void adjust_option_widgets (Gtk.Label name_widget, Gtk.Widget value_widget) {
            name_widget.set_xalign (0);
            name_widget.set_size_request (preference_name_width, grid_height);

            value_widget.set_size_request (preference_widget_width, grid_height);
            // NOTE:
            // set_hexpand is very important to make widget in grid to expand space horizaontally.
            value_widget.set_hexpand(   true);
        }
    }
}
