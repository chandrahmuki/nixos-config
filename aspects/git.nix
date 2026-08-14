{den, ...}: {
  den.aspects.git = {user, ...}: {
    homeManager.programs.git = {
      enable = true;
      settings = {
        user = {
          name = user.userName;
        };
        alias = {
          s = "status";
          a = "add";
          c = "commit";
          cm = "commit -m";
          p = "push";
          lg = "log --graph --oneline --all";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
      };
    };
  };

}
