require_relative "#{Rails.root}/app/jobs/generate_dist"

every 1.hour do
  runner "Jobs::GenerateDist.perform_async"
end
