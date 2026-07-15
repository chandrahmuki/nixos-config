{den, ...}: {
  den.aspects.git = {user, ...}: {
    homeManager.programs.git = {
      enable = true;
      settings = {
        user = {
          name = user.userName;
          email = "amouyaljerome@gmail.com";
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

  den.aspects.david.includes = [den.aspects.git];
}
