task :ci => [:jetty, 'jetty:config'] do
  Jettywrapper.wrap(Jettywrapper.load_config) do
    Rake::Task['spec'].invoke
  end
end

task :jetty do
  unless File.exist?('jetty')
    puts "Downloading jetty"
    `rails generate hydra:jetty`
  end
end
