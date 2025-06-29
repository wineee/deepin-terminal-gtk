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
    public class DropdownTextButton : Gtk.Box {
        public Gtk.DropDown dropdown;
        public Gtk.StringList string_list;

        public DropdownTextButton () {
            Object (orientation: Gtk.Orientation.HORIZONTAL);
            string_list = new Gtk.StringList (null);
            dropdown = new Gtk.DropDown (string_list, null);
            append (dropdown);
            
            dropdown.notify["selected"].connect (() => {
                changed ();
            });
        }

        public void add_item (string text) {
            string_list.append (text);
        }

        public uint selected {
            get { return dropdown.selected; }
            set { dropdown.selected = value; }
        }

        public signal void changed ();
    }
}
