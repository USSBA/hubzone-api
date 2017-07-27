namespace :hz do
  desc "generate the REVISION file"
  task :revision do
    `git describe --long > REVISION`
  end
end
