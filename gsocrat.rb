#!/usr/bin/env ruby

require 'gtk2'
require 'net/http'
require 'cgi'
require 'json'


class Translator
  def initialize(lang_from, lang_to)
    @lang_from, @lang_to = lang_from, lang_to
  end

  def translate(string)
    request = "/ajax/services/language/translate?v=1.0&q=#{CGI.escape(string)}&langpair=#{@lang_from}%7C#{@lang_to}"
    begin
      response = Net::HTTP.get_response('ajax.googleapis.com', request)
    rescue Net::HTTPError
      "Can\'t connect to translate server."
    else
      json_response = JSON.parse(response.body)
      json_response && json_response['responseData'] ? json_response['responseData']['translatedText'] : "Translate error."
    end
  end
end


word_entry      = Gtk::Entry.new
button          = Gtk::Button.new("Translate!")
window          = Gtk::Window.new
window.title    = "GSocrat"
translator      = Translator.new('en', 'ru')
responseview    = Gtk::TextView.new
responseview.editable = false

window.signal_connect("delete_event") { Gtk.main_quit }
window.signal_connect("key_press_event") { |w, e| Gtk.main_quit if e.keyval == Gdk::Keyval::GDK_Escape }

main_box = Gtk::VBox.new(false, 5)
main_box.pack_start_defaults(word_entry)
main_box.pack_start_defaults(button)
main_box.pack_start_defaults(responseview)

button.signal_connect("clicked") { responseview.buffer.text = translator.translate(word_entry.text) }

window.add(main_box)
window.show_all
Gtk.main
