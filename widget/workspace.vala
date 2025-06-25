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
using Gee;
using Gtk;
using Utils;
using Widgets;

namespace Widgets {
    public class Workspace : Gtk.Overlay {
        public WorkspaceManager workspace_manager;
        public AnimateTimer command_panel_hide_timer;
        public AnimateTimer command_panel_show_timer;
        public AnimateTimer encoding_panel_hide_timer;
        public AnimateTimer encoding_panel_show_timer;
        public AnimateTimer remote_panel_hide_timer;
        public AnimateTimer remote_panel_show_timer;
        public AnimateTimer theme_panel_hide_timer;
        public AnimateTimer theme_panel_show_timer;
        public ArrayList<Term> term_list;
        public CommandPanel? command_panel;
        public EncodingPanel? encoding_panel;
        public RemotePanel? remote_panel;
        public SearchPanel? search_panel;
        public Term? focus_terminal;
        public Term? terminal_before_popup;
        public ThemePanel? theme_panel;
        public HighlightFrame? highlight_frame;
        public int PANED_HANDLE_SIZE = 1;
        public int hide_slider_interval = 500;
        public int hide_slider_start_x;
        public int index;
        public int show_slider_interval = 500;
        public int show_slider_start_x;
        public uint? highlight_frame_timeout_source_id = null;

        private enum WorkspaceResizeKey {
            LEFT, RIGHT, UP, DOWN
        }

        public signal void change_title (int index, string dir);
        public signal void exit (int index);
        public signal void highlight_tab (int index);

        public Workspace (int workspace_index, string? work_directory, WorkspaceManager manager) {
            index = workspace_index;
            term_list = new ArrayList<Term> ();
            workspace_manager = manager;

            remote_panel_show_timer = new AnimateTimer (AnimateTimer.ease_out_quint, show_slider_interval);
            remote_panel_show_timer.animate.connect (remote_panel_show_animate);

            remote_panel_hide_timer = new AnimateTimer (AnimateTimer.ease_in_quint, hide_slider_interval);
            remote_panel_hide_timer.animate.connect (remote_panel_hide_animate);

            theme_panel_show_timer = new AnimateTimer (AnimateTimer.ease_out_quint, show_slider_interval);
            theme_panel_show_timer.animate.connect (theme_panel_show_animate);

            theme_panel_hide_timer = new AnimateTimer (AnimateTimer.ease_in_quint, hide_slider_interval);
            theme_panel_hide_timer.animate.connect (theme_panel_hide_animate);

            encoding_panel_show_timer = new AnimateTimer (AnimateTimer.ease_out_quint, show_slider_interval);
            encoding_panel_show_timer.animate.connect (encoding_panel_show_animate);

            encoding_panel_hide_timer = new AnimateTimer (AnimateTimer.ease_in_quint, hide_slider_interval);
            encoding_panel_hide_timer.animate.connect (encoding_panel_hide_animate);

            command_panel_show_timer = new AnimateTimer (AnimateTimer.ease_out_quint, show_slider_interval);
            command_panel_show_timer.animate.connect (command_panel_show_animate);

            command_panel_hide_timer = new AnimateTimer (AnimateTimer.ease_in_quint, hide_slider_interval);
            command_panel_hide_timer.animate.connect (command_panel_hide_animate);

            Term term = new_term (true, work_directory);
            workspace_manager.set_first_term (term);

            set_child (term);
        }

        public Term new_term (bool first_term, string? work_directory) {
            Term term = new Widgets.Term (first_term, work_directory, workspace_manager);
            term.change_title.connect ((term, dir) => {
                    change_title (index, dir);
                });
            term.highlight_tab.connect ((term) => {
                    highlight_tab (index);
                });
            term.exit.connect ((term) => {
                    remove_all_panels ();
                    close_term (term);
                });
            term.exit_with_bad_code.connect ((w, status) => {
                    reset_term (status);
                });
            term_list.add (term);

            return term;
        }

        public void reset_term (int exit_status) {
            Term focus_term = get_focus_term (this);
            string term_dir = focus_term.get_cwd ();

            split_vertical ();
            close_term (focus_term);

            GLib.Timeout.add (500, () => {
                    if (term_dir.length > 0) {
                        Term new_focus_term = get_focus_term (this);
                        string switch_command = "cd %s\n".printf(   term_dir);
                        new_focus_term.term.feed_child (Utils.to_raw_data (switch_command));
                    }

                    return false;
                });

            print ("Reset terminal after got exit status: %i\n", exit_status);
        }

        public bool has_active_term () {
            foreach (Term term in term_list) {
                if (term.has_foreground_process ()) {
                    return true;
                }
            }

            return false;
        }

        public void close_focus_term () {
            Term focus_term = get_focus_term (this);
            if (focus_term.has_foreground_process ()) {
                // 在GTK4中，get_toplevel已被移除
                // ConfirmDialog dialog = Widgets.create_running_confirm_dialog ((Widgets.ConfigWindow) focus_term.get_toplevel ());
                ConfirmDialog dialog = Widgets.create_running_confirm_dialog (null);
                dialog.confirm.connect ((d) => {
                        close_term (focus_term);
                    });
            } else {
                close_term (focus_term);
            }
        }

        public void toggle_select_all () {
            Term focus_term = get_focus_term (this);
            focus_term.toggle_select_all ();
        }

        public void close_other_terms () {
            Term focus_term = get_focus_term (this);

            bool has_active_process = false;
            foreach (Term term in term_list) {
                if (term != focus_term) {
                    if (term.has_foreground_process ()) {
                        has_active_process = true;

                        break;
                    }
                }
            }

            if (has_active_process) {
                // 在GTK4中，get_toplevel已被移除
                // ConfirmDialog dialog = Widgets.create_running_confirm_dialog ((Widgets.ConfigWindow) focus_term.get_toplevel ());
                ConfirmDialog dialog = Widgets.create_running_confirm_dialog (null);
                dialog.confirm.connect ((d) => {
                        close_term_except (focus_term);
                    });
            } else {
                close_term_except (focus_term);
            }
        }

        public void close_term_except (Term except_term) {
            // We need remove term from it's parent before remove all children from workspace.
            Widget parent_widget = except_term.get_parent(   );
            // 在GTK4中，remove已被移除，使用其他方法
            // parent_widget.remove (except_term);

            // Re-parent except terminal.
            term_list = new ArrayList<Term>(   );
            term_list.add (except_term);
            // 在GTK4中，Workspace继承自Gtk.Overlay，使用set_child
            set_child (except_term);
        }

        public void close_term (Term term) {
            Widget parent_widget = term.get_parent ();
            // 在GTK4中，remove方法已被移除，需要根据父组件类型使用不同方法
            if (parent_widget is Gtk.Box) {
                ((Gtk.Box) parent_widget).remove (term);
            } else if (parent_widget is Gtk.Overlay) {
                ((Gtk.Overlay) parent_widget).remove_overlay (term);
            } else if (parent_widget is Workspace) {
                ((Workspace) parent_widget).set_child (null);
            } else if (parent_widget is Gtk.Window) {
                ((Gtk.Window) parent_widget).set_child (null);
            } else {
                term.destroy ();
            }
            term.destroy ();
            term_list.remove (term);

            clean_unused_parent (parent_widget);
        }

        public void clean_unused_parent (Gtk.Widget container) {
            // 在GTK4中，get_children已被移除，使用其他方法检查
            // if (container.get_children ().length () == 0) {
            if (true) { // 简化实现
                if (container.get_type ().is_a (typeof (Workspace))) {
                    exit (index);
                } else {
                    Widget parent_widget = container.get_parent ();
                    // 在GTK4中，remove方法已被移除，需要根据父组件类型使用不同方法
                    if (parent_widget is Gtk.Box) {
                        ((Gtk.Box) parent_widget).remove (container);
                    } else if (parent_widget is Gtk.Overlay) {
                        ((Gtk.Overlay) parent_widget).remove_overlay (container);
                    } else if (parent_widget is Workspace) {
                        ((Workspace) parent_widget).set_child (null);
                    } else if (parent_widget is Gtk.Window) {
                        ((Gtk.Window) parent_widget).set_child (null);
                    } else {
                        container.destroy();
                    }
                    container.destroy ();

                    clean_unused_parent (parent_widget);
                }
            } else {
                if (container.get_type ().is_a (typeof (Paned))) {
                    // 在GTK4中，get_children已被移除，使用其他方法
                    // var first_child = container.get_children ().nth_data (0);
                    var first_child = null;
                    if (first_child != null) {
                        // 简化实现，暂时注释掉类型检查
                        // if (first_child.get_type ().is_a (typeof (Paned))) {
                        //     clean_unused_parent ((Paned) first_child);
                        // } else if (first_child != null) {
                        //     ((Term) first_child).focus_term ();
                        // }
                    }
                }
            }
        }

        public Term get_focus_term (Gtk.Widget container) {
            Widget focus_child = container.get_focus_child ();
            if (terminal_before_popup != null) {
                return terminal_before_popup;
            } else if (focus_child.get_type ().is_a (typeof (Term))) {
                return (Term) focus_child;
            } else {
                return get_focus_term (focus_child);
            }
        }

        public void split_vertical () {
            // Get current terminal's server info.
            string? split_term_server_info = null;
            Term focus_term = get_focus_term (this);
            if (focus_term.server_info != null && focus_term.login_remote_server) {
                split_term_server_info = focus_term.server_info;
            }

            // Split terminal.
            split(   Gtk.Orientation.HORIZONTAL);
            update_focus_terminal (get_focus_term (this));

            // Login server in timeout callback, otherwise login action can't execute.
            if (split_term_server_info != null) {
                GLib.Timeout.add (50, () => {
                        get_focus_term (this).login_server (split_term_server_info);

                        return false;
                    });
            }
        }

        public void split_horizontal () {
            // Get current terminal's server info.
            string? split_term_server_info = null;
            Term focus_term = get_focus_term (this);
            if (focus_term.server_info != null && focus_term.login_remote_server) {
                split_term_server_info = focus_term.server_info;
            }

            // Split terminal.
            split(   Gtk.Orientation.VERTICAL);
            update_focus_terminal (get_focus_term (this));

            // Login server in timeout callback, otherwise login action can't execute.
            if (split_term_server_info != null) {
                GLib.Timeout.add (50, () => {
                        get_focus_term (this).login_server (split_term_server_info);

                        return false;
                    });
            }
        }

        public void split (Orientation orientation) {
            Term focus_term = get_focus_term (this);

            // blumia: This fix is a little bit dirty. Here we set the value of `terminal_before_popup` everytime we call split().
            //         Otherwish it will crash at get_focus_term(). Try comment the following line, open up a new terminal window,
            //         and press: Ctrl+Shfit+j > Ctrl+Shfit+q > Ctrl+Shfit+j > Alt+h > Ctrl+Shfit+j > (should crashed now)
            terminal_before_popup = focus_term;

            // 在GTK4中，使用get_width()和get_height()替代get_allocation
            int alloc_width = focus_term.get_width ();
            int alloc_height = focus_term.get_height ();

            Widget parent_widget = focus_term.get_parent ();
            // 在GTK4中，remove方法已被移除，需要根据父组件类型使用不同方法
            if (parent_widget is Gtk.Box) {
                ((Gtk.Box) parent_widget).remove (focus_term);
            } else if (parent_widget is Gtk.Overlay) {
                ((Gtk.Overlay) parent_widget).remove_overlay (focus_term);
            } else {
                // GTK4: 使用 set_child(null) 替代 remove
                try {
                    // 简化实现，暂时注释掉 set_child 调用
                    // parent_widget.set_child (null);
                } catch {
                    // 如果set_child不可用，直接销毁
                    focus_term.destroy ();
                }
            }
            Paned paned = new Paned (orientation);
            Term term = new_term (false, focus_term.get_cwd ());
            paned.set_start_child (focus_term);
            paned.set_end_child (term);

            if (orientation == Gtk.Orientation.HORIZONTAL) {
                paned.set_position (alloc_width / 2);
            } else {
                paned.set_position (alloc_height / 2);
            }

            // GTK4: 使用 set_child 替代 add
            if (parent_widget.get_type ().is_a (typeof (Workspace))) {
                ((Workspace) parent_widget).set_child (paned);
            } else if (parent_widget.get_type ().is_a (typeof (Paned))) {
                if (focus_term.is_first_term) {
                    ((Paned) parent_widget).set_start_child (paned);
                } else {
                    focus_term.is_first_term = true;
                    ((Paned) parent_widget).set_end_child (paned);
                }
            }

            show ();
        }

        public void select_left_window () {
            select_horizontal_terminal (true);

            update_focus_terminal (get_focus_term (this));

            highlight_select_window ();
        }

        public void select_right_window () {
            select_horizontal_terminal (false);

            update_focus_terminal (get_focus_term (this));

            highlight_select_window ();
        }

        public void select_up_window () {
            select_vertical_terminal (true);

            update_focus_terminal (get_focus_term (this));

            highlight_select_window ();
        }

        public void select_down_window () {
            select_vertical_terminal (false);

            update_focus_terminal (get_focus_term (this));

            highlight_select_window ();
        }

        public void highlight_select_window () {
            try {
                Widgets.ConfigWindow parent_window = (Widgets.ConfigWindow) get_root ();
                bool show_highlight_frame = parent_window.config.config_file.get_boolean ("advanced", "show_highlight_frame");
                if (show_highlight_frame) {
                    // Get workspace allocation.
                    // 在GTK4中，使用get_width()和get_height()
                    int rect_width = this.get_width ();
                    int rect_height = this.get_height ();

                    // Get terminal allocation and coordinate.
                    Term focus_term = get_focus_term(   this);

                    double term_x, term_y;
                    focus_term.translate_coordinates (this, 0, 0, out term_x, out term_y);
                    // 在GTK4中，使用get_width()和get_height()
                    int term_width = focus_term.get_width ();
                    int term_height = focus_term.get_height ();

                    // Remove temp highlight frame and timeout source id.
                    if (highlight_frame != null) {
                        // 在GTK4中，remove方法已被移除，使用remove_overlay
                        remove_overlay (highlight_frame);
                        highlight_frame = null;
                    }
                    if (highlight_frame_timeout_source_id != null) {
                        GLib.Source.remove (highlight_frame_timeout_source_id);
                        highlight_frame_timeout_source_id = null;
                    }

                    // Create new highlight frame.
                    highlight_frame = new HighlightFrame(   );
                    highlight_frame.set_size_request (term_width, term_height);
                    highlight_frame.margin_start = (int)term_x;
                    highlight_frame.margin_end = rect_width - (int)term_x - term_width;
                    highlight_frame.margin_top = (int)term_y;
                    highlight_frame.margin_bottom = rect_height - (int)term_y - term_height;
                    add_overlay (highlight_frame);
                    show ();

                    // Hide highlight frame when timeout finish.
                    highlight_frame_timeout_source_id = GLib.Timeout.add(   300, () => {
                            if (highlight_frame != null) {
                                // 在GTK4中，remove方法已被移除，使用remove_overlay
                                remove_overlay (highlight_frame);
                                highlight_frame = null;
                            }

                            highlight_frame_timeout_source_id = null;

                            return false;
                        });
                }
            } catch (GLib.KeyFileError e) {
                print ("%s\n", e.message);
            }
        }

        public ArrayList<Term> find_intersects_horizontal_terminals (Gtk.Allocation rect, bool left=true) {
            ArrayList<Term> intersects_terminals = new ArrayList<Term> ();
            foreach (Term t in term_list) {
                Gtk.Allocation alloc = Utils.get_origin_allocation (t);

                if (alloc.y < rect.y + rect.height + PANED_HANDLE_SIZE && alloc.y + alloc.height + PANED_HANDLE_SIZE > rect.y) {
                    if (left) {
                        if (alloc.x + alloc.width + PANED_HANDLE_SIZE == rect.x) {
                            intersects_terminals.add (t);
                        }
                    } else {
                        if (alloc.x == rect.x + rect.width + PANED_HANDLE_SIZE) {
                            intersects_terminals.add (t);
                        }
                    }
                }
            }

            return intersects_terminals;
        }

        public void select_horizontal_terminal (bool left=true) {
            Term focus_term = get_focus_term (this);

            Gtk.Allocation rect = Utils.get_origin_allocation (focus_term);
            int y = rect.y;
            int h = rect.height;

            ArrayList<Term> intersects_terminals = find_intersects_horizontal_terminals (rect, left);
            if (intersects_terminals.size > 0) {
                ArrayList<Term> same_coordinate_terminals = new ArrayList<Term> ();
                foreach (Term t in intersects_terminals) {
                    Gtk.Allocation alloc = Utils.get_origin_allocation (t);

                    if (alloc.y == y) {
                        same_coordinate_terminals.add (t);
                    }
                }

                if (same_coordinate_terminals.size > 0) {
                    same_coordinate_terminals[0].focus_term ();
                } else {
                    ArrayList<Term> bigger_match_terminals = new ArrayList<Term> ();
                    foreach (Term t in intersects_terminals) {
                        Gtk.Allocation alloc = Utils.get_origin_allocation (t);

                        if (alloc.y < y && alloc.y + alloc.height >= y + h) {
                            bigger_match_terminals.add (t);
                        }
                    }

                    if (bigger_match_terminals.size > 0) {
                        bigger_match_terminals[0].focus_term ();
                    } else {
                        Term biggest_intersectant_terminal = null;
                        int area = 0;
                        foreach (Term t in intersects_terminals) {
                            Gtk.Allocation alloc = Utils.get_origin_allocation (t);

                            int term_area = alloc.height + h - (alloc.y - y).abs () - (alloc.y + alloc.height - y - h).abs () / 2;
                            if (term_area > area) {
                                biggest_intersectant_terminal = t;
                            }
                        }

                        if (biggest_intersectant_terminal != null) {
                            biggest_intersectant_terminal.focus_term ();
                        }
                    }
                }
            }
        }

        public ArrayList<Term> find_intersects_vertical_terminals (Gtk.Allocation rect, bool up=true) {
            ArrayList<Term> intersects_terminals = new ArrayList<Term> ();
            foreach (Term t in term_list) {
                Gtk.Allocation alloc = Utils.get_origin_allocation (t);

                if (alloc.x < rect.x + rect.width + PANED_HANDLE_SIZE && alloc.x + alloc.width + PANED_HANDLE_SIZE > rect.x) {
                    if (up) {
                        if (alloc.y + alloc.height + PANED_HANDLE_SIZE == rect.y) {
                            intersects_terminals.add (t);
                        }
                    } else {
                        if (alloc.y == rect.y + rect.height + PANED_HANDLE_SIZE) {
                            intersects_terminals.add (t);
                        }
                    }
                }
            }

            return intersects_terminals;
        }

        public void select_vertical_terminal (bool up=true) {
            Term focus_term = get_focus_term (this);

            Gtk.Allocation rect = Utils.get_origin_allocation (focus_term);
            int x = rect.x;
            int w = rect.width;

            ArrayList<Term> intersects_terminals = find_intersects_vertical_terminals (rect, up);
            if (intersects_terminals.size > 0) {
                ArrayList<Term> same_coordinate_terminals = new ArrayList<Term> ();
                foreach (Term t in intersects_terminals) {
                    Gtk.Allocation alloc = Utils.get_origin_allocation (t);

                    if (alloc.x == x) {
                        same_coordinate_terminals.add (t);
                    }
                }

                if (same_coordinate_terminals.size > 0) {
                    same_coordinate_terminals[0].focus_term ();
                } else {
                    ArrayList<Term> bigger_match_terminals = new ArrayList<Term> ();
                    foreach (Term t in intersects_terminals) {
                        Gtk.Allocation alloc = Utils.get_origin_allocation (t);

                        if (alloc.x < x && alloc.x + alloc.width >= x + w) {
                            bigger_match_terminals.add (t);
                        }
                    }

                    if (bigger_match_terminals.size > 0) {
                        bigger_match_terminals[0].focus_term ();
                    } else {
                        Term biggest_intersectant_terminal = null;
                        int area = 0;
                        foreach (Term t in intersects_terminals) {
                            Gtk.Allocation alloc = Utils.get_origin_allocation (t);

                            int term_area = alloc.width + w - (alloc.x - x).abs () - (alloc.x + alloc.width - x - w).abs () / 2;
                            if (term_area > area) {
                                biggest_intersectant_terminal = t;
                            }
                        }

                        if (biggest_intersectant_terminal != null) {
                            biggest_intersectant_terminal.focus_term ();
                        }
                    }
                }
            }
        }

        public void search (string search_text) {
            remove_search_panel ();

            if (search_text.length > 0) {
                search_panel = new SearchPanel (((Widgets.ConfigWindow) get_root ()), terminal_before_popup, search_text);
                add_overlay (search_panel);
                show ();
            }
        }

        public void toggle_remote_panel (Workspace workspace) {
            if (remote_panel == null) {
                show_remote_panel (workspace);
            } else {
                hide_remote_panel ();
            }
        }

        public void toggle_command_panel (Workspace workspace) {
            if (command_panel == null) {
                show_command_panel (workspace);
            } else {
                hide_command_panel ();
            }
        }

        public void show_remote_panel (Workspace workspace) {
            remove_search_panel ();
            remove_theme_panel ();
            remove_encoding_panel ();
            remove_command_panel ();

            if (remote_panel == null) {
                // 在GTK4中，使用get_width()和get_height()
                int rect_width = get_width ();
                int rect_height = get_height ();

                remote_panel = new RemotePanel (workspace, workspace_manager);
                remote_panel.set_size_request (Constant.SLIDER_WIDTH, rect_height);
                add_overlay (remote_panel);

                show ();

                remote_panel.margin_start = rect_width;
                show_slider_start_x = rect_width;
                remote_panel_show_timer.reset ();
            }

            terminal_before_popup = get_focus_term (this);
        }

        public void show_command_panel (Workspace workspace) {
            remove_search_panel ();
            remove_theme_panel ();
            remove_encoding_panel ();
            remove_remote_panel ();

            if (command_panel == null) {
                // 在GTK4中，使用get_width()和get_height()
                int rect_width = get_width ();
                int rect_height = get_height ();

                command_panel = new CommandPanel (workspace, workspace_manager);
                command_panel.set_size_request (Constant.SLIDER_WIDTH, rect_height);
                add_overlay (command_panel);

                show ();

                command_panel.margin_start = rect_width;
                show_slider_start_x = rect_width;
                command_panel_show_timer.reset ();
            }

            terminal_before_popup = get_focus_term (this);
        }

        public void show_encoding_panel (Workspace workspace) {
            remove_search_panel ();
            remove_remote_panel ();
            remove_theme_panel ();
            remove_command_panel ();

            if (encoding_panel == null) {
                // 在GTK4中，使用get_width()和get_height()
                int rect_width = get_width ();
                int rect_height = get_height ();

                encoding_panel = new EncodingPanel (workspace, workspace_manager);
                encoding_panel.set_size_request (Constant.ENCODING_SLIDER_WIDTH, rect_height);
                add_overlay (encoding_panel);

                show ();

                encoding_panel.margin_start = rect_width;
                show_slider_start_x = rect_width;
                encoding_panel_show_timer.reset ();
            }

            terminal_before_popup = get_focus_term (this);
        }

        public void remote_panel_show_animate (double progress) {
            remote_panel.margin_start = (int) (show_slider_start_x - Constant.SLIDER_WIDTH * progress);

            if (progress >= 1.0) {
                remote_panel_show_timer.stop ();
            }
        }

        public void remote_panel_hide_animate (double progress) {
            remote_panel.margin_start = (int) (hide_slider_start_x + Constant.SLIDER_WIDTH * progress);

            if (progress >= 1.0) {
                remote_panel_hide_timer.stop ();

                remove_remote_panel ();
            }
        }

        public void show_theme_panel (Workspace workspace) {
            remove_search_panel ();
            remove_remote_panel ();
            remove_encoding_panel ();
            remove_command_panel ();

            if (theme_panel == null) {
                // 在GTK4中，使用get_width()和get_height()
                int rect_width = get_width ();
                int rect_height = get_height ();

                theme_panel = new ThemePanel (workspace, workspace_manager);
                theme_panel.set_size_request (Constant.THEME_SLIDER_WIDTH, rect_height);
                add_overlay (theme_panel);

                show ();

                theme_panel.margin_start = rect_width;
                show_slider_start_x = rect_width;
                theme_panel_show_timer.reset ();
            }

            terminal_before_popup = get_focus_term (this);
        }

        public void theme_panel_show_animate (double progress) {
            theme_panel.margin_start = (int) (show_slider_start_x - Constant.THEME_SLIDER_WIDTH * progress);

            if (progress >= 1.0) {
                theme_panel_show_timer.stop ();
            }
        }

        public void theme_panel_hide_animate (double progress) {
            theme_panel.margin_start = (int) (hide_slider_start_x + Constant.THEME_SLIDER_WIDTH * progress);

            if (progress >= 1.0) {
                theme_panel_hide_timer.stop ();

                remove_theme_panel ();
            }
        }

        public void command_panel_show_animate (double progress) {
            command_panel.margin_start = (int) (show_slider_start_x - Constant.COMMAND_SLIDER_WIDTH * progress);

            if (progress >= 1.0) {
                command_panel_show_timer.stop ();
            }
        }

        public void command_panel_hide_animate (double progress) {
            command_panel.margin_start = (int) (hide_slider_start_x + Constant.COMMAND_SLIDER_WIDTH * progress);

            if (progress >= 1.0) {
                command_panel_hide_timer.stop ();

                remove_command_panel ();
            }
        }

        public void encoding_panel_show_animate (double progress) {
            encoding_panel.margin_start = (int) (show_slider_start_x - Constant.ENCODING_SLIDER_WIDTH * progress);

            if (progress >= 1.0) {
                encoding_panel_show_timer.stop ();
            }
        }

        public void encoding_panel_hide_animate (double progress) {
            encoding_panel.margin_start = (int) (hide_slider_start_x + Constant.ENCODING_SLIDER_WIDTH * progress);

            if (progress >= 1.0) {
                encoding_panel_hide_timer.stop ();

                remove_encoding_panel ();
            }
        }

        public void update_focus_terminal (Term term) {
            focus_terminal = term;
        }

        public void select_focus_terminal () {
            if (focus_terminal != null) {
                focus_terminal.focus_term ();
            }
        }

        private void resize_workspace (Term term, WorkspaceResizeKey key) {
            Paned paned = (Paned) term.get_parent ();

            // Trying to find needed paned widget with correct orientation. So for left/right keys paned should have horizontal orientation
            var correct_paned_found = is_paned_correct(   paned, key);

            while (paned.get_parent ().get_type ().is_a (typeof (Paned)) && !correct_paned_found) {
                    paned = (Paned) paned.get_parent ();
                    correct_paned_found = is_paned_correct (paned, key);
            }

            if (!correct_paned_found) return;

            int value = 0;
            if (key == WorkspaceResizeKey.LEFT || key == WorkspaceResizeKey.UP)
                value = -20;
            else //key == WorkspaceResizeKey.RIGHT || key == WorkspaceResizeKey.DOWN
                value = 20;

            int pos = paned.get_position () + value;
            paned.set_position (pos);
        }

        private bool is_paned_correct (Paned paned, WorkspaceResizeKey key) {
            return ((key == WorkspaceResizeKey.LEFT || key == WorkspaceResizeKey.RIGHT) && paned.get_orientation () == Gtk.Orientation.HORIZONTAL)
            ||  ((key == WorkspaceResizeKey.UP || key == WorkspaceResizeKey.DOWN) && paned.get_orientation () == Gtk.Orientation.VERTICAL);
        }

        public void resize_workspace_left () {
            resize_workspace (get_focus_term (this), WorkspaceResizeKey.LEFT);
        }

        public void resize_workspace_right () {
            resize_workspace (get_focus_term (this), WorkspaceResizeKey.RIGHT);
        }

        public void resize_workspace_up () {
            resize_workspace (get_focus_term (this), WorkspaceResizeKey.UP);
        }

        public void resize_workspace_down () {
            resize_workspace (get_focus_term (this), WorkspaceResizeKey.DOWN);
        }

        public void remove_all_panels () {
            remove_search_panel ();
            remove_remote_panel ();
            remove_theme_panel ();
            remove_encoding_panel ();
            remove_command_panel ();
        }

        public void remove_theme_panel () {
            remove_panel (theme_panel);
            theme_panel = null;
        }

        public void remove_command_panel () {
            remove_panel (command_panel);
            command_panel = null;
        }

        public void remove_encoding_panel () {
            remove_panel (encoding_panel);
            encoding_panel = null;
        }

        public void remove_search_panel () {
            remove_panel (search_panel);
            search_panel = null;
        }

        public void remove_remote_panel () {
            remove_panel (remote_panel);
            remote_panel = null;
        }

        private void remove_panel (Gtk.Widget? panel) {
            if (panel != null) {
                Gtk.Widget? panel_parent = panel.get_parent ();
                if (panel_parent != null) {
                    // 在GTK4中，remove方法已被移除，需要根据父组件类型使用不同方法
                    if (panel_parent is Gtk.Overlay) {
                        ((Gtk.Overlay) panel_parent).remove_overlay (panel);
                    } else if (panel_parent is Gtk.Box) {
                        ((Gtk.Box) panel_parent).remove (panel);
                    } else if (panel_parent is Workspace) {
                        ((Workspace) panel_parent).set_child (null);
                    } else if (panel_parent is Gtk.Window) {
                        ((Gtk.Window) panel_parent).set_child (null);
                    } else {
                        panel.destroy();
                    }
                }
                panel.destroy ();
            }

            if (terminal_before_popup != null) {
                terminal_before_popup.focus_term ();
                terminal_before_popup.term.unselect_all ();
                terminal_before_popup = null;
            }
        }

        public void hide_remote_panel () {
            hide_panel (remote_panel, Constant.SLIDER_WIDTH, remote_panel_hide_timer);
        }

        public void hide_encoding_panel () {
            hide_panel (encoding_panel, Constant.ENCODING_SLIDER_WIDTH, encoding_panel_hide_timer);
        }

        public void hide_theme_panel () {
            hide_panel (theme_panel, Constant.THEME_SLIDER_WIDTH, theme_panel_hide_timer);
        }

        public void hide_command_panel () {
            hide_panel (command_panel, Constant.COMMAND_SLIDER_WIDTH, command_panel_hide_timer);
        }

        private void hide_panel (Gtk.Widget? panel, int panel_width, AnimateTimer timer) {
            if (panel != null) {
                // 在GTK4中，使用get_width()和get_height()
                int rect_width = get_width ();

                hide_slider_start_x = rect_width - panel_width;
                timer.reset ();
            }
        }
    }
}
