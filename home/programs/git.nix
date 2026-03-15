# Migrated from dot_gitconfig.tmpl and dot_config/git/ignore
# hostname is passed via extraSpecialArgs to handle work vs personal email
{ hostname, ... }:

{
  programs.git = {
    enable = true;

    # https://blog.gitbutler.com/how-git-core-devs-configure-git/
    settings = {
      user = {
        name = "Chris Overcash";
        email =
          if hostname == "m-ry6wtc3pxk"
          then "c0o02bc@homeoffice.wal-mart.com"
          else "covercash2@gmail.com";
      };
      # core.pager is set automatically by programs.delta
      init.defaultBranch = "main";
      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };
      commit.verbose = true;
      push.autoSetupRemote = true;
      branch.sort = "committerdate";
      tag.sort = "version:refname";
      # interactive.diffFilter is set automatically by programs.delta
      delta.navigate = true;
      merge.conflictstyle = "diff3";
      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };
      diff = {
        colorMoved = "plain";
        algorithm = "histogram";
        mnemoniPrefix = true;
        rename = true;
      };
      # https://git-scm.com/book/en/v2/Git-Tools-Rerere
      rerere = {
        enabled = true;
        autoupdate = true;
      };
    };

    # Migrated from dot_config/git/ignore
    ignores = [
      ".idea/"
      "rusty-tags.*"
      ".dart*"
      ".packages"
      ".#*"
    ];
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };
}
