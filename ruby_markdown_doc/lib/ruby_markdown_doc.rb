require "ruby_markdown_doc/version"
require 'yard'
require 'erb'

module RubyMarkdownDoc
  def self.generate(github_repo:)

    YARD::Registry.load

    repo = "govuk_schemas_gem"
    website_base = "https://github.com/#{github_repo}/blob/master/"
    classes = YARD::Registry.all(:class)

    template = File.read('ruby_markdown_doc/lib/ruby_markdown_doc/doc_template.erb')
    renderer = ERB.new(template)
    content = renderer.result(binding)

    content.gsub!("\n\n\n", "\n")
    content.strip!

    Dir.mkdir('docs') rescue nil
    File.write("docs/index.md", content)
  end
end
# require "yard"

# YARD::Rake::YardocTask.new do |t|
#   t.options = ['--no-private', '--markup', 'markdown', '--output-dir', 'docs']
# end
