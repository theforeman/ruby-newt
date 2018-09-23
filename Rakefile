require 'io/console'
require 'rake/extensiontask'
require 'rake/testtask'
require 'rubygems'

Rake::ExtensionTask.new 'ruby_newt' do |ext|
  ext.lib_dir = 'lib/ruby_newt'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
end

task :test_interactive do
  scripts = FileList['examples/test*-e.rb', 'examples/test_method/*.rb']
            .select { |name| FileTest.executable?(name) }
  run_scripts(scripts)
end

task :test_interactive_jp do
  scripts = FileList['examples/test*-j.rb', 'examples/test_method/*.rb']
  run_scripts(scripts)
end

def run_scripts(scripts)
  scripts.each do |script|
    system('clear') || system('cls')
    system("ruby -Ilib #{script}")
    puts "\nExecuted '#{script}'"
    puts 'Press a key to continue or ESC to exit.'
    break if STDIN.getch == "\e"
  end
end

task :default => :compile
