#!/usr/bin/env ruby

require 'gtk2'
require 'net/http'
require 'cgi'
require 'json'


class Translator
  GOOGLE_APIS = 'ajax.googleapis.com'
  TRANSLATE_ERROR = 'Translate error'

  attr_accessor :lang_to, :lang_from

  def initialize(lang_from, lang_to)
    self.lang_from, self.lang_to = lang_from, lang_to
  end

  def translate(string)
    request = "/ajax/services/language/translate?v=1.0&q=#{CGI.escape(string)}&langpair=#{@lang_from}%7C#{@lang_to}"
    begin
      response = Net::HTTP.get_response(GOOGLE_APIS, request)
    rescue
      "Can't connect to #{GOOGLE_APIS}."
    else
      json_response = JSON.parse(response.body)
      json_response && json_response['responseData'] ? json_response['responseData']['translatedText'] : TRANSLATE_ERROR
    end
  end
end


word_entry      = Gtk::Entry.new
window          = Gtk::Window.new
window.title    = "GSocrat"
window.resizable= false
window.border_width = 3

translator      = Translator.new('en', 'ru')
responseview    = Gtk::TextView.new
responseview.editable = false
responseview.indent   = 2

window.signal_connect('delete_event') { Gtk.main_quit }

window.signal_connect('key_press_event') do |w, e|
  case e.keyval
    when Gdk::Keyval::GDK_Escape
      Gtk.main_quit
    when Gdk::Keyval::GDK_Return
      responseview.buffer.text = translator.translate(word_entry.text) if not word_entry.text.empty?
  end
end

main_box = Gtk::VBox.new(false, 5)
main_box.pack_start_defaults(word_entry)
main_box.pack_start_defaults(responseview)

window.add(main_box)
window.show_all
Gtk.main

