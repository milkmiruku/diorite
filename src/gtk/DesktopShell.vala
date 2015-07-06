/*
 * Copyright 2015 Jiří Janoušek <janousek.jiri@gmail.com>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met: 
 * 
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer. 
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution. 
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

namespace Diorite
{

public abstract class DesktopShell: GLib.Object
{
	private static DesktopShell? default_shell = null;
	public bool shows_app_menu {get; protected set; default = false;}
	public bool shows_menu_bar {get; protected set; default = false;}
	public bool client_side_decorations {get; protected set; default = false;}
	public string? wm_name {get; protected set; default = null;}
	public string? wm_name_exact {get; protected set; default = null;}
	public string? wm_version {get; protected set; default = null;}
	
	public static DesktopShell get_default()
	{
		if (DesktopShell.default_shell == null)
			DesktopShell.default_shell = new DefaultDesktopShell();
		return DesktopShell.default_shell;
	}
	
	internal static void set_default(DesktopShell? default_shell)
	{
		DesktopShell.default_shell = default_shell;
	}
	
	protected Gdk.X11.Window? inspect_window_manager()
	{
		var net_wm_check_window = X11.get_net_wm_check_window();
		if (net_wm_check_window != null)
		{
			wm_name_exact = X11.get_window_property_as_utf8(net_wm_check_window, "_NET_WM_NAME");
			if (wm_name_exact != null)
				wm_name = wm_name_exact.down();
			
			switch (wm_name)
			{
			case "gnome shell":
			case "mutter":
				wm_version = X11.get_window_property_as_utf8(net_wm_check_window, "_MUTTER_VERSION");
				break;
			}
		}
		return net_wm_check_window;
	}
}

private class DefaultDesktopShell: DesktopShell
{
	public DefaultDesktopShell()
	{
		inspect_window_manager();
		var gs = Gtk.Settings.get_default();
		shows_app_menu = gs.gtk_shell_shows_app_menu;
		shows_menu_bar = gs.gtk_shell_shows_menubar;
		
		switch (wm_name)
		{
		case "gnome shell":
		case "mutter":
			client_side_decorations = true;
			break;
		}
		
		debug("Shell: %s %s, CSD %s", wm_name, wm_version, client_side_decorations ? "on" : "off");
	}
}


private class GnomeDesktopShell: DesktopShell
{
	public GnomeDesktopShell()
	{
		inspect_window_manager();
		var gs = Gtk.Settings.get_default();
		shows_app_menu = gs.gtk_shell_shows_app_menu = true;
		shows_menu_bar = gs.gtk_shell_shows_menubar = false;
		client_side_decorations = true;
		debug("Shell (GNOME): %s %s, CSD %s", wm_name, wm_version, client_side_decorations ? "on" : "off");
	}
}


private class UnityDesktopShell: DesktopShell
{
	public UnityDesktopShell()
	{
		inspect_window_manager();
		var gs = Gtk.Settings.get_default();
		shows_app_menu = gs.gtk_shell_shows_app_menu = true;
		shows_menu_bar = gs.gtk_shell_shows_menubar = true;
		client_side_decorations = false;
		debug("Shell (Unity): %s %s, CSD %s", wm_name, wm_version, client_side_decorations ? "on" : "off");
	}
}


private class XfceDesktopShell: DesktopShell
{
	public XfceDesktopShell()
	{
		inspect_window_manager();
		var gs = Gtk.Settings.get_default();
		shows_app_menu = gs.gtk_shell_shows_app_menu = false;
		shows_menu_bar = gs.gtk_shell_shows_menubar = false;
		client_side_decorations = false;
		debug("Shell (XFCE): %s %s, CSD %s", wm_name, wm_version, client_side_decorations ? "on" : "off");
	}
}

} // namespace Diorite
