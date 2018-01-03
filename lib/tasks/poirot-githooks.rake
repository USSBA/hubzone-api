namespace :hz do
  desc "create the poirot precommit hooks"
  task :poirot_hooks do
    `cp #{Rails.root}/lib/tasks/pre-commit-poirot #{Rails.root}/.git/hooks/pre-commit-poirot`
    `chmod +x #{Rails.root}/.git/hooks/pre-commit-poirot`
    `echo '.git/hooks/pre-commit-poirot -p \"#{Rails.root}/\hubzone-poirot-patterns.txt"' > .git/hooks/pre-commit`
    `chmod +x .git/hooks/pre-commit`
  end
end
