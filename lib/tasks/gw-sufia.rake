namespace 'gw-sufia' do
  desc "(Re-)Generate the secret token"
  task generate_secret: :environment do
    include ActiveSupport
    File.open("#{Rails.root}/config/initializers/secret_token.rb", 'w') do |f|
      f.puts "#{Rails.application.class.parent_name}::Application.config.secret_key_base = '#{SecureRandom.hex(64)}'"
    end
  end
end
