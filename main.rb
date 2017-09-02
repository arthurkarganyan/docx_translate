require 'docx'
require 'pry'
require 'ruby-progressbar'
require 'capybara'
require 'capybara-webkit'
require 'selenium-webdriver'

class GoogleTranslate
  include Capybara::DSL

  URL = 'https://translate.google.com/#uk/en'
  BLANK_RE = /\A[[:space:]]*\z/

  def initialize
    Capybara::Webkit.configure { |config| config.allow_url("*")  }
    Capybara.run_server = false
    Capybara.current_driver = :webkit
  end

  def translate(source_text)
    return source_text if BLANK_RE.match source_text
    visit URL unless current_url.start_with? URL
    fill_in 'source', with: source_text
    find('#gt-submit').click
    sleep 8
    find('#result_box').text
  end
end

class Main
  def path
    "#{argv_path}/*.docx"
  end

  def argv_path
    ARGV[0]
  end

  def initialize
    fail 'First argument required!' unless argv_path
  end

  def start
    progress_bar = ProgressBar.create(title: 'Progress', total: files.flat_map(&:paragraphs).size)
    if files.empty?
      puts "No files .docx found"
      return
    end
    puts "Files to translate:"
    puts file_names
    files.each do |file|
      DocumentTranslator.new(gt, file, progress_bar).start
      #progress_bar.increment
    end
  end

  def file_names
    @file_names ||= Dir[path].select {|f| !f["transl"] && !f["edit"]}.reject do |f|
      Dir[path].include?(f.gsub(".", " edit.")) || Dir[path].include?(f.gsub(".", " transl."))
    end
  end

  def files
    @files ||= file_names.map { |file_name| new_doc(file_name)}
  end

  def new_doc(file_name)
    x = Docx::Document.open(file_name) 
    x.define_singleton_method(:file_name) {file_name}
    x
  end	

  def gt
    @gt ||= GoogleTranslate.new
  end
end

class DocumentTranslator < Struct.new(:gt, :doc, :progress_bar)
  def start
    doc.paragraphs.first.parent.children.each do |p|
      new_p = p.dup
      new_p.content = ''
      p.after new_p
    end

    doc.paragraphs.each_slice(2) do |ps|
      text = ps.first.text
      ps.last.text = try_translate(text)
      progress_bar.increment
    end

    str = "#{doc.file_name.split('.docx').first} edit.docx"
    puts "Saving translation to #{str}"
    doc.save(str)
  end

  def try_translate(text)
    return text if url?(text)
    gt.translate(text)
  end

  def url?(text)
    text == text[URI::regexp] || ("http://" + text) == ("http://" + text)[URI::regexp]
  end
end

Main.new.start
