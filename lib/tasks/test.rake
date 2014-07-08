task :ci => ['jetty:clean', 'sufia:jetty:config'] do
  Jettywrapper.wrap(Jettywrapper.load_config) do
    Rake::Task['spec'].invoke
  end
end
