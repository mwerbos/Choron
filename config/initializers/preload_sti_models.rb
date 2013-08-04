# Initialize subclasses in the "dev" environment
# so that things don't look broken

if Rails.env.development?
  %w[chore shared_chore].each do |c|
    require_dependency File.join("app","models","#{c}.rb")
  end
end
