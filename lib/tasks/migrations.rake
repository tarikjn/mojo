namespace :migrations do
  task :normalize_emails => :environment do
    
    User.all.each do |u|
      u[:email] = u.email.downcase
      u.save :validate => false
    end
    
    puts "done!"
    
  end
end
