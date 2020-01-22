require 'xcodeproj'


project_path = Dir.glob("*.xcodeproj").first
if project_path
  project = Xcodeproj::Project.open(project_path)

  non_test_targets = project.targets.reject do |t|
    t.respond_to?(:test_target_type?) && t.test_target_type?
  end

  if non_test_targets.count > 0
    target = non_test_targets.first

    marketing_version_key = "MARKETING_VERSION"
    target.build_configurations.each do |config|
      current_version = config.build_settings[marketing_version_key]
      puts current_version
      version_array = current_version.split(".").map(&:to_i)
      version_array[-1] = version_array[-1] + 1
      next_version_number = version_array.join(".")
      config.build_settings[marketing_version_key] = next_version_number
      current_version = config.build_settings[marketing_version_key]
      puts current_version
    end
  end
else
  puts "No project path."
end