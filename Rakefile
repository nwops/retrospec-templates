# encoding: utf-8

desc 'Run Validation'
task :validate do
  erb_files.each do |file|
    puts `./erb_template_syntax_check.sh #{file}`
    exit 1 unless $?.success?
  end
end

def erb_files
  Dir['**/**/.*erb'] + Dir['**/**/*.erb']
end