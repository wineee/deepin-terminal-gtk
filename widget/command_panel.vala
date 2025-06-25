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

using Gee;
using Gtk;
using Utils;
using Widgets;

namespace Widgets {
    public class CommandPanel : BasePanel {
        public KeyFile config_file;
        public int width = Constant.SLIDER_WIDTH;
        public string config_file_path = Utils.get_config_file_path ("command-config.conf");

        public delegate void UpdatePageAfterEdit ();

        public CommandPanel (Workspace space, WorkspaceManager manager) {
            base (null, manager);
            
            Intl.bindtextdomain (GETTEXT_PACKAGE, LOCALEDIR);

            workspace = space;
            workspace_manager = manager;

            config_file = new KeyFile ();

            focus_widget = null;
            parent_window = null;
            try {
                background_color = Utils.hex_to_rgba (parent_window.config.config_file.get_string ("theme", "background"));
            } catch (Error e) {
                print ("CommandPanel init: %s\n", e.message);
            }

            switcher = new Widgets.Switcher (width);

            set_size_request (width, -1);
            home_page_box.set_size_request (width, -1);
            search_page_box.set_size_request (width, -1);

            append (switcher);

            show_home_page ();
        }

        public void load_config () {
            var file = File.new_for_path (config_file_path);
            if (!file.query_exists ()) {
                Utils.touch_dir (Utils.get_config_dir ());
                Utils.create_file (config_file_path);
            } else {
                try {
                    config_file.load_from_file (config_file_path, KeyFileFlags.NONE);
                } catch (Error e) {
                    if (!FileUtils.test (config_file_path, FileTest.EXISTS)) {
                        print ("Config: %s\n", e.message);
                    }
                }
            }
        }

        public override void create_home_page () {
            Utils.destroy_all_children (home_page_box);
            home_page_scrolledwindow = null;

            HashMap<string, int> groups = new HashMap<string, int> ();
            ArrayList<ArrayList<string>> ungroups = new ArrayList<ArrayList<string>> ();

            try {
                load_config ();

                foreach (unowned string option in config_file.get_groups ()) {
                    string group_name = config_file.get_value (option, "GroupName");

                    if (group_name == "") {
                        add_group_item (option, ungroups, config_file);
                    } else {
                        if (groups.has_key (group_name)) {
                            int group_item_number = groups.get (group_name);
                            groups.set (group_name, group_item_number + 1);
                        } else {
                            groups.set (group_name, 1);
                        }
                    }
                }
            } catch (Error e) {
                print ("CommandPanel config path: %s\n", config_file_path);

                if (!FileUtils.test (config_file_path, FileTest.EXISTS)) {
                    print ("CommandPanel create_home_page: %s\n", e.message);
                }
            }

            if (groups.size > 0 || ungroups.size > 1) {
                Widgets.SearchEntry search_entry = new Widgets.SearchEntry ();
                home_page_box.append (search_entry);

                search_entry.search_entry.activate.connect ((entry) => {
                        if (entry.get_text ().strip () != "") {
                            show_search_page (entry.get_text (), "", home_page_box);
                        }
                    });

                var split_line = new SplitLine ();
                home_page_box.append (split_line);
            }

            home_page_scrolledwindow = create_scrolled_window ();
            home_page_box.append (home_page_scrolledwindow);

            var command_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            home_page_scrolledwindow.set_child (command_box);

            if (ungroups.size + groups.size > 0) {
                foreach (var group_entry in groups.entries) {
                    var command_group_button = create_command_group_button (group_entry.key, group_entry.value);
                    command_box.append (command_group_button);
                }

                foreach (var ungroup_list in ungroups) {
                    var command_button = create_command_button (ungroup_list[0], ungroup_list[1], ungroup_list[2]);
                    command_button.edit_command.connect ((w, command_info) => {
                            edit_command (command_info, () => {
                                    update_home_page ();
                                });
                        });
                    command_box.append (command_button);
                }

            }

            var split_line = new SplitLine ();
            home_page_box.append (split_line);

            Widgets.AddButton add_command_button = create_add_command_button ();
            add_command_button.margin_start = 16;
            add_command_button.margin_end = 16;
            add_command_button.margin_top = 16;
            add_command_button.margin_bottom = 16;
            home_page_box.append (add_command_button);
        }

        public void add_command (
            string name,
            string command,
            string shortcut) {
            if (name != "" && command != "") {
                Utils.touch_dir (Utils.get_config_dir ());

                load_config ();

                // Use ',' as array-element-separator instead of ';'.
                config_file.set_list_separator (',');

                config_file.set_string (name, "Command", command);
                config_file.set_string (name, "Shortcut", shortcut);

                try {
                    config_file.save_to_file (config_file_path);
                } catch (Error e) {
                    print ("add_command error occur when config_file.save_to_file %s: %s\n", config_file_path, e.message);
                }
            }
        }

        public void create_search_page (string search_text, string search_direction, Gtk.Widget start_widget) {
            Utils.destroy_all_children (search_page_box);
            search_page_scrolledwindow = null;

            var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            top_box.set_size_request (-1, Constant.COMMAND_PANEL_SEARCHBAR_HEIGHT);
            search_page_box.append (top_box);

            ImageButton back_button = new Widgets.ImageButton ("back", true);
            back_button.margin_start = back_button_margin_start;
            back_button.margin_top = back_button_margin_top;
            back_button.clicked.connect ((w) => {
                    show_home_page (search_page_box);
                });
            top_box.append (back_button);

            Gtk.Label search_label = new Gtk.Label (null);
            search_label.set_text (_("Search: %s").printf (search_text));
            top_box.append (search_label);

            var split_line = new SplitLine ();
            search_page_box.append (split_line);

            search_page_scrolledwindow = create_scrolled_window ();
            search_page_box.append (search_page_scrolledwindow);

            var command_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            search_page_scrolledwindow.set_child (command_box);

            ArrayList<ArrayList<string>> ungroups = new ArrayList<ArrayList<string>> ();

            try {
                load_config ();

                foreach (unowned string option in config_file.get_groups ()) {
                    string command_name = config_file.get_value (option, "Name");
                    string command_exec = config_file.get_value (option, "Exec");

                    if (command_name.down ().contains (search_text.down ()) || command_exec.down ().contains (search_text.down ())) {
                        add_group_item (option, ungroups, config_file);
                    }
                }
            } catch (Error e) {
                if (!FileUtils.test (config_file_path, FileTest.EXISTS)) {
                    print ("create_search_page error: %s\n", e.message);
                }
            }

            if (ungroups.size > 0) {
                foreach (var ungroup_list in ungroups) {
                    var command_button = create_command_button (ungroup_list[0], ungroup_list[1], ungroup_list[2]);
                    command_button.edit_command.connect ((w, command_info) => {
                            edit_command (command_info, () => {
                                    update_home_page ();
                                });
                        });
                    command_box.append (command_button);
                }

            }

            if (search_direction == "scroll_to_right") {
                switcher.scroll_to_right (start_widget, search_page_box);
            } else if (search_direction == "scroll_to_left") {
                switcher.scroll_to_left (start_widget, search_page_box);
            }

            show ();
        }

        public void add_group_item (string option, ArrayList<ArrayList<string>> lists, KeyFile config_file) {
            try {
                ArrayList<string> list = new ArrayList<string> ();
                list.add (option);
                list.add (config_file.get_value (option, "Command"));
                list.add (config_file.get_value (option, "Shortcut"));
                lists.add (list);
            } catch (Error e) {
                print ("add_group_item error: %s\n", e.message);
            }
        }

        public void edit_command (string command_name, UpdatePageAfterEdit func) {
            load_config ();

            var command_dialog = new Widgets.CommandDialog (parent_window, null, this, command_name, config_file);
            command_dialog.transient_for_window (parent_window);
            command_dialog.delete_command.connect ((name) => {
                    try {
                        // First, remove old command info from config file.
                        if (config_file.has_group(   command_name)) {
                            config_file.remove_group (command_name);
                            config_file.save_to_file (config_file_path);
                        }

                        func ();
                    } catch (Error e) {
                        error ("%s", e.message);
                    }
                });
            command_dialog.edit_command.connect ((name, command, shortcut) => {
                    try {
                        // First, remove old command info from config file.
                        if (config_file.has_group(   command_name)) {
                            config_file.remove_group (command_name);
                            config_file.save_to_file (config_file_path);
                        }

                        // Second, add new command info.
                        add_command(   name, command, shortcut);

                        func ();

                        command_dialog.show();
                    } catch (Error e) {
                        error ("%s", e.message);
                    }
                });

            command_dialog.show();
        }

        public Widgets.CommandButton create_command_button (string name, string value, string shortcut) {
            var command_button = new Widgets.CommandButton (name, value, shortcut);
            command_button.execute_command.connect ((w, command) => {
                    execute_command (command);
                });
            return command_button;
        }

        public Gtk.Widget? create_command_group_button (string name, int value) {
            // GTK4: 暂时注释掉，因为 CommandGroupButton 可能不存在
            // var command_group_button = new Widgets.CommandGroupButton (name, value);
            // return command_group_button;
            return null;
        }

        public void execute_command (string command) {
            Term focus_term = workspace_manager.focus_workspace.get_focus_term (workspace_manager.focus_workspace);
            var command_string = "%s\n".printf(   command);
            focus_term.term.feed_child (Utils.to_raw_data (command_string));

            workspace.hide_command_panel ();
            if (focus_widget != null) {
                focus_widget.grab_focus ();
            }
        }

        public Widgets.AddButton create_add_command_button () {
            Widgets.AddButton add_command_button = new Widgets.AddButton (_("Add command"));
            add_command_button.clicked.connect ((w) => {
                    Term focus_term = workspace_manager.focus_workspace.get_focus_term (workspace_manager.focus_workspace);
                    var command_dialog = new Widgets.CommandDialog (parent_window, focus_term, this);
                    command_dialog.transient_for_window (parent_window);
                    command_dialog.add_command.connect ((name, command, shortcut) => {
                            add_command (name, command, shortcut);
                            update_home_page ();
                            command_dialog.show();
                        });
                    command_dialog.show();
                });

            return add_command_button;
        }
    }
}
