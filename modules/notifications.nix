{ pkgs, ... }:

{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "top";
      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 10;
      control-center-margin-left = 10;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      notification-window-width = 400;
      # Click on notification to execute default action (links/apps)
      mpris-shortcut-next = "n";
      mpris-shortcut-prev = "p";
      mpris-shortcut-play-pause = "space";
    };
    style = ''
      .notification-default-action,
      .notification-action {
        padding: 4px;
        margin: 4px;
        border-radius: 8px;
        background: rgba(30, 30, 46, 0.9);
        color: #cdd6f4;
      }

      .notification-default-action:hover,
      .notification-action:hover {
        background: #313244;
      }
    '';
  };
}
