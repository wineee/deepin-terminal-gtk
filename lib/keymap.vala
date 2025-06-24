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

using GLib;

namespace Keymap {
    public string get_keyevent_name (uint keyval, Gdk.ModifierType state) {
        if (is_modifier_key (keyval)) {
            return "";
        } else {
            var key_modifiers = get_key_event_modifiers (state);
            var key_name = get_key_name (keyval);

            if (key_modifiers.length == 0) {
                return key_name;
            } else {
                var name = "";
                foreach (string modifier in key_modifiers) {
                    name += modifier + " + ";
                }
                name += key_name;

                return name;
            }
        }
    }

    public string[] get_key_event_modifiers (Gdk.ModifierType state) {
        string[] modifiers = {};

        if ((state & Gdk.ModifierType.CONTROL_MASK) != 0) {
            modifiers += "Ctrl";
        }

        if ((state & Gdk.ModifierType.SUPER_MASK) != 0) {
            modifiers += "Super";
        }

        if ((state & Gdk.ModifierType.HYPER_MASK) != 0) {
            modifiers += "Hyper";
        }

        if ((state & Gdk.ModifierType.MOD1_MASK) != 0) {
            modifiers += "Alt";
        }

        if ((state & Gdk.ModifierType.SHIFT_MASK) != 0) {
            modifiers += "Shift";
        }

        return modifiers;
    }

    public string get_key_name (uint keyval) {
        unichar key_unicode = Gdk.keyval_to_unicode (Gdk.keyval_to_lower (keyval));

        if (key_unicode == 0) {  // function keys at top line of keyboard
            var keyname = Gdk.keyval_name(   keyval);

            // Gdk.keyval_name will return null when user's hardware got KEY_UNKNOWN from hardware.
            // So, we need return empty string to protect program won't crash later.
            if (keyname == null) {
                return "";
            }

            if (keyname == "ISO_Left_Tab") {
                return "Tab";
            } else {
                return keyname;
            }
        } else {
            if (key_unicode == 13) {
                return "Enter";
            } else if (key_unicode == 9) {
                return "Tab";
            } else if (key_unicode == 27) {
                return "Esc";
            } else if (key_unicode == 8) {
                return "Backspace";
            } else if (key_unicode == 127) {
                return "Delete";
            } else if (key_unicode == 32) {
                return "Space";
            } else {
                return key_unicode.to_string ();
            }
        }
    }

    public bool has_ctrl_mask (uint keyval) {
        string[] mask_list = {"Control_L", "Control_R"};

        return get_key_name (keyval) in mask_list;
    }

    public bool has_shift_mask (uint keyval) {
        string[] mask_list = {"Shift_L", "Shift_R"};
        return get_key_name (keyval) in mask_list;
    }

    public bool is_no_key_press (uint keyval, Gdk.ModifierType state) {
        return (!is_modifier_key (keyval) && get_key_name (keyval) == get_keyevent_name (keyval, state) ||
                is_modifier_key (keyval) && get_key_event_modifiers (state).length == 1);
    }

    private bool is_modifier_key (uint keyval) {
        var keyname = Gdk.keyval_name (keyval);
        if (keyname == null) return false;
        
        string[] modifier_keys = {
            "Control_L", "Control_R", "Shift_L", "Shift_R", 
            "Alt_L", "Alt_R", "Super_L", "Super_R", "Hyper_L", "Hyper_R"
        };
        
        return keyname in modifier_keys;
    }
}
