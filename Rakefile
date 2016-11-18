require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "gem_publisher"

RSpec::Core::RakeTask.new(:spec)

task default: [:spec]

desc "Publish gem to RubyGems"
task :publish_gem do |_t|
  published_gem = GemPublisher.publish_if_updated("govuk_schemas.gemspec", :rubygems)
  puts "Published #{published_gem}" if published_gem
end

task :docs do
  require 'ruby_markdown_doc'
  RubyMarkdownDoc.generate(
    github_repo: "alphagov/govuk_schemas_gem",
  )
end
