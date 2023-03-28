#!/usr/bin/env python

import time

import gi
gi.require_version('Gio', '2.0')
gi.require_version('GLib', '2.0')
gi.require_version('GObject', '2.0')
from gi.repository import Nautilus, GObject, Gio

class ColumnExtension(GObject.GObject, Nautilus.ColumnProvider, Nautilus.InfoProvider):
    def __init__(self):
        pass
    
    def get_columns(self):
        return (
            Nautilus.Column(name="NautilusPython::access_time_column",
                            attribute="access_time",
                            label="Access time",
                            description="Access time in ISO8601 format"),
            Nautilus.Column(name="NautilusPython::modification_time_column",
                            attribute="modification_time", label="Last update",
                            description="Last modification time in ISO8601 format")
        )

    def update_file_info(self, file):
        if file.get_uri_scheme() != 'file':
            return
        
        file_info = file.get_location().query_info("time::*", flags=Gio.FileQueryInfoFlags(0), cancellable=None)
        format = "%Y-%m-%d %H:%M"
        
        file.add_string_attribute('access_time', time.strftime(format, time.localtime(file_info.get_attribute_uint64("time::access"))))
        file.add_string_attribute('modification_time', time.strftime(format, time.localtime(file_info.get_attribute_uint64("time::modified"))))

