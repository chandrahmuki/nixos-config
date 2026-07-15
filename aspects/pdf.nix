{den, ...}: {
  den.aspects.pdf.homeManager.programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      recolor = true;
      recolor-keephue = true;
    };
  };

  den.aspects.david.includes = [den.aspects.pdf];
}
