module Translator
  def self.translate(text, from: "uk", to: "en")
    path = AskAndStore.ask("Where is the credentials file for Google Cloud API?", '.creds-path')
    translate = Google::Cloud::Translate.new(credentials: path)

    translation = translate.translate text, to: to, from: from

    # translation.from #=> "en"
    # translation.origin #=> "Hello world!"
    # translation.to #=> "la"
    # translation.text #=> "Salve mundi!"
    #
    translation.text
  end
end
