{ config, lib, pkgs, username, ... }:

{
  home-manager.users.${username} = { config, lib, ... }: {
    xdg.configFile."cliamp/config.toml" = {
      text = ''
        volume = 0
        repeat = "off"
        shuffle = false
        mono = false
        seek_large_step_sec = 30
        eq_preset = "Flat"
        eq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        visualizer = "Bars"
        compact = false
        theme = "Tokyo Night"
        log_level = "info"
        provider = "ytmusic"

        [ytmusic]
        client_id = ""
        client_secret = ""
      '';
    };

    xdg.configFile."cliamp/radios.toml" = {
      text = ''
        [[station]]
        name = "SomaFM Groove Salad"
        url = "https://ice1.somafm.com/groovesalad-128-mp3"

        [[station]]
        name = "SomaFM Groove Salad Classic"
        url = "https://ice1.somafm.com/gsclassic-128-mp3"

        [[station]]
        name = "SomaFM Drone Zone"
        url = "https://ice1.somafm.com/dronezone-128-mp3"

        [[station]]
        name = "SomaFM Drone Zone 2"
        url = "https://ice1.somafm.com/dz2-128-mp3"

        [[station]]
        name = "SomaFM Deep Space One"
        url = "https://ice1.somafm.com/deepspaceone-128-mp3"

        [[station]]
        name = "SomaFM Space Station Soma"
        url = "https://ice1.somafm.com/spacestation-128-mp3"

        [[station]]
        name = "SomaFM Beat Blender"
        url = "https://ice1.somafm.com/beatblender-128-mp3"

        [[station]]
        name = "SomaFM Fluid"
        url = "https://ice1.somafm.com/fluid-128-mp3"

        [[station]]
        name = "SomaFM Lush"
        url = "https://ice1.somafm.com/lush-128-mp3"

        [[station]]
        name = "SomaFM The Dark Zone"
        url = "https://ice1.somafm.com/darkzone-128-mp3"

        [[station]]
        name = "SomaFM SF 10-33"
        url = "https://ice1.somafm.com/sf1033-128-mp3"

        [[station]]
        name = "SomaFM Vaporwaves"
        url = "https://ice1.somafm.com/vaporwaves-128-mp3"

        [[station]]
        name = "NTS Radio"
        url = "https://stream-relay-geo.ntslive.net/stream"

        [[station]]
        name = "Radio Paradise"
        url = "https://stream.radioparadise.com/aac-128"

        [[station]]
        name = "SomaFM DEF CON Radio"
        url = "https://ice1.somafm.com/defcon-128-mp3"

        [[station]]
        name = "SomaFM Cliqhop IDM"
        url = "https://ice1.somafm.com/cliqhop-128-mp3"

        [[station]]
        name = "SomaFM Doomed"
        url = "https://ice1.somafm.com/doomed-128-mp3"
      '';
    };

    xdg.configFile."cliamp/playlists/ambi.toml" = {
      text = ''
        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Alien_3_92.m4a"
        title = "Alien 3 (1992) | Ambient Soundscape"
        artist = "A L I E N W O R L D S"
        genre = "Music"
        year = 2024

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Beno_NThoughts.m4a"
        title = "Brian Eno - Night Thoughts [Stretched]"
        artist = "Tato Schab"
        genre = "Music"
        year = 2025

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/BladeRunner.m4a"
        title = "BladeRunner"

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Boards_of_Canada_55_55_B_Sides_+_Rarities_Mix.m4a"
        title = "Boards of Canada ⬣ 55:55 (B Sides + Rarities Mix)"
        artist = "Nomis J"
        genre = "Music"
        year = 2026

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/BofCanada.m4a"
        title = "The Best Of Boards Of Canada"
        artist = "DJ Adelaide"
        genre = "People & Blogs"
        year = 2025

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Budd/Above_Chiangmai_Remastered_2004.m4a"
        title = "Above Chiangmai (Remastered 2004)"
        artist = "Harold Budd, Brian Eno"
        album = "Ambient 2: The Plateaux Of Mirror"
        genre = "Music"
        year = 2017

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Budd/Among_Fields_Of_Crystal_Remastered_2004.m4a"
        title = "Among Fields Of Crystal (Remastered 2004)"
        artist = "Harold Budd, Brian Eno"
        album = "Ambient 2: The Plateaux Of Mirror"
        genre = "Music"
        year = 2017

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Budd/An_Arc_Of_Doves_Remastered_2004.m4a"
        title = "An Arc Of Doves (Remastered 2004)"
        artist = "Harold Budd, Brian Eno"
        album = "Ambient 2: The Plateaux Of Mirror"
        genre = "Music"
        year = 2017

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Budd/Failing_Light_Remastered_2004.m4a"
        title = "Failing Light (Remastered 2004)"
        artist = "Harold Budd, Brian Eno"
        album = "Ambient 2: The Plateaux Of Mirror"
        genre = "Music"
        year = 2017

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Budd/First_Light_Remastered_2004.m4a"
        title = "First Light (Remastered 2004)"
        artist = "Harold Budd, Brian Eno"
        album = "Ambient 2: The Plateaux Of Mirror"
        genre = "Music"
        year = 2018

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Budd/Not_Yet_Remembered_Remastered_2004.m4a"
        title = "Not Yet Remembered (Remastered 2004)"
        artist = "Harold Budd, Brian Eno"
        album = "Ambient 2: The Plateaux Of Mirror"
        genre = "Music"
        year = 2017

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Budd/Steal_Away_Remastered_2004.m4a"
        title = "Steal Away (Remastered 2004)"
        artist = "Harold Budd, Brian Eno"
        album = "Ambient 2: The Plateaux Of Mirror"
        genre = "Music"
        year = 2017

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Budd/The_Chill_Air_Remastered_2004.m4a"
        title = "The Chill Air (Remastered 2004)"
        artist = "Harold Budd, Brian Eno"
        album = "Ambient 2: The Plateaux Of Mirror"
        genre = "Music"
        year = 2017

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Budd/The_Plateaux_Of_Mirror_Remastered_2004.m4a"
        title = "The Plateaux Of Mirror (Remastered 2004)"
        artist = "Harold Budd, Brian Eno"
        album = "Ambient 2: The Plateaux Of Mirror"
        genre = "Music"
        year = 2017

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Budd/Wind_In_Lonely_Fences_Remastered_2004.m4a"
        title = "Wind In Lonely Fences (Remastered 2004)"
        artist = "Harold Budd, Brian Eno"
        album = "Ambient 2: The Plateaux Of Mirror"
        genre = "Music"
        year = 2017

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/ET_Ambi.m4a"
        title = "E.T. the Extra-Terrestrial | Ambient Soundscape"
        artist = "A L I E N W O R L D S"
        genre = "Music"
        year = 2023

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/GTO_Study.m4a"
        title = "Study Hard with Onizuka Sensei || 1 hour of music for studying"
        artist = "Inuyasha Listens to music"
        year = 2022

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Ghost_In_The_Shell_Ambient_-_Cinematic_Sci_Fi_Music_By_SpaceWave.m4a"
        title = "Ghost In The Shell Ambient - Cinematic Sci Fi Music By SpaceWave"
        artist = "SpaceWave - Cosmic Relaxation"
        genre = "Music"
        year = 2022

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Lucid_Dreams.m4a"
        title = "Lucid_Dreams"

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Rebuild_Of_Evangelion_Sad_Calm_OST.m4a"
        title = "Rebuild Of Evangelion Sad/Calm OST"
        artist = "Sorikai _"
        genre = "Music"
        year = 2021

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Takashi_Barcelona.m4a"
        title = "Barcelona ～ Gaudi’s Dream ～ (バルセロナ～ガウディの夢～) (1992) [Full Album]"
        artist = "Takashi Kokubo (小久保隆)"
        year = 2019

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/The_Goonies_1985_Ambient_Soundscape.m4a"
        title = "The Goonies (1985) | Ambient Soundscape"
        artist = "A L I E N W O R L D S"
        genre = "Music"
        year = 2024

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/TwinPeaks_Cooper.m4a"
        title = "Twin Peaks Hotel Cafe Ambience | Morning Coffee with Agent Cooper | Calm Nostalgic 90s Soundtrack"
        artist = "George Ander (Books and Ambience)"
        genre = "Entertainment"
        year = 2026

        [[track]]
        path = "${config.home.homeDirectory}/Music/Likes/Ambi/Twin_Peaks_Into_The_Night_Ambient_Soundscape.m4a"
        title = "Twin Peaks | Into The Night | Ambient Soundscape"
        artist = "A L I E N W O R L D S"
        genre = "Music"
        year = 2026
      '';
    };

    home.activation.createCliampPlaylistsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD mkdir -p ${config.home.homeDirectory}/.config/cliamp/playlists
    '';
  };
}
