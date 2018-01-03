namespace :hz do
  desc "create the poirot precommit hooks"
  task :poirot_hooks do
    `cp #{Rails.root}/lib/tasks/pre-commit-poirot #{Rails.root}/.git/hooks/pre-commit-poirot`
    `chmod +x #{Rails.root}/.git/hooks/pre-commit-poirot`
    patterns = Rails.root.join("hubzone-poirot-patterns.txt")
    poirot_hook = ".git/hooks/pre-commit-poirot -p #{patterns}"
    pre_commit = ".git/hooks/pre-commit"
    if File.exist?(pre_commit) && File.open(pre_commit).read.match(poirot_hook)
      puts "Poirot pre-commit hook already detected in #{pre_commit}, not adding again"
    else
      puts "Adding Poirot pre-commit hook to #{pre_commit}"
      `echo #{poirot_hook} >> #{pre_commit}`
      `chmod +x #{pre_commit}`
    end
  end
end
