class DocumentTranslator < Struct.new(:translator, :doc)
  def start
    doc.paragraphs.first.parent.children.each do |p|
      new_p = p.dup
      new_p.content = ''
      p.after new_p
    end

    doc.paragraphs.each_slice(2) do |ps|
      text = ps.first.text
      ps.last.text = try_translate(text)
      print '.'
    end

    str = "#{doc.file_name.split('.docx').first} edit.docx"
    puts "Saving translation to #{str}"
    doc.save(str)
  end

  def try_translate(text)
    return text if url?(text)
    translator.translate(text)
  end

  def url?(text)
    text == text[URI::regexp] || ("http://" + text) == ("http://" + text)[URI::regexp]
  end
end
