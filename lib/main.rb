class Main
  def path
    "#{argv_path}/*.docx"
  end

  def argv_path
    ARGV[0]
  end

  def initialize
    fail "Please provide path to the documents where *.docx files are. \n E.g. if they are on desktop: bundle exec bin/run.rb ~/Desktop" unless argv_path
  end

  def start
    if files.empty?
      puts "No files .docx found"
      return
    end
    puts "Files to translate:"
    puts file_names
    files.each do |file|
      DocumentTranslator.new(translator, file).start
      puts ""
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

  def translator
    @translator ||= Translator
  end
end
