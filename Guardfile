guard 'bundler' do
  watch('Gemfile')
  watch('contraband.gemspec')
end

guard 'rspec' do
  watch(%r{^spec/app/.+\.rb$}) { 'spec' }
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }
end

guard 'yard' do
  watch(%r{app/.+\.rb})
  watch(%r{lib/.+\.rb})
end